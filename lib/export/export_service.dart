import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../logic/backup_json.dart';
import '../logic/backup_service.dart' show sicherungsDateiname;
import '../logic/berechnung.dart';
import 'excel_export.dart';
import 'json_export.dart';
import 'mail_smtp_stub.dart' if (dart.library.io) 'mail_smtp_io.dart'
    as plattform;
import 'monats_daten.dart';
import 'pdf_export.dart';

/// Standard-Betreffvorlage, änderbar in Verwaltung → Optionen. Platzhalter:
/// {Mitarbeiter} {Monat} {Jahr} {Firma} {Zeitraum}.
const kBetreffVorlageStandard = 'Zeiterfassung – {Mitarbeiter} – {Monat} {Jahr}';

/// Baut die reine [SollRegel] (inkl. Wochentags-Soll und Pausenregel) aus
/// den gespeicherten Benutzereinstellungen. Die EINE Stelle, an der aus
/// [UserSetting] eine Rechenregel wird – damit erben alle Aufrufer (Konten,
/// Auswertung, Export, Eintragsdialog) automatisch dieselben Werte.
SollRegel sollRegelAus(UserSetting s) => SollRegel(
      modus: s.sollModus,
      stundenTag: s.sollStundenTag,
      stundenMoDo: s.sollStundenMoDo,
      stundenFr: s.sollStundenFr,
      proWochentag: [
        s.sollStundenMo,
        s.sollStundenDi,
        s.sollStundenMi,
        s.sollStundenDo,
        s.sollStundenFrTag,
        s.sollStundenSa,
        s.sollStundenSo,
      ],
      pausenregel: Pausenregel(
        aktiv: s.pausenregelAktiv,
        schwelleMin: s.pausenSchwelleMin,
        mindestMin: s.pausenMindestMin,
      ),
    );

class ExportDateien {
  final String basisname; // Zeitexa_<Benutzer>_<JJJJ-MM>
  final String betreff;
  final Uint8List jsonBytes;
  final Uint8List xlsxBytes;
  final Uint8List pdfBytes;

  ExportDateien({
    required this.basisname,
    required this.betreff,
    required this.jsonBytes,
    required this.xlsxBytes,
    required this.pdfBytes,
  });

  List<(String, Uint8List)> get alsListe => [
        ('$basisname.json', jsonBytes),
        ('$basisname.xlsx', xlsxBytes),
        ('$basisname.pdf', pdfBytes),
      ];

  (String, Uint8List) get xlsxDatei => ('$basisname.xlsx', xlsxBytes);
}

class ExportService {
  final ZeitexaDb db;
  ExportService(this.db);

  Future<SollRegel> regelFuer(int userId) async {
    final s = await db.settingsFor(userId);
    return sollRegelAus(s);
  }

  /// Erzeugt alle drei Exportdateien für einen Monat.
  Future<ExportDateien> erzeuge(User user, int jahr, int monat) async {
    final eintraege = await db.entriesForMonth(user.id, jahr, monat);
    final orte = {
      for (final p in await db.select(db.places).get()) p.id: p.name
    };
    final regel = await regelFuer(user.id);
    final branding = await db.branding();
    final bloecke = tagBloeckeAus(await db.bloeckeFuerMonat(user.id, jahr, monat));
    final zeilen = monatsZeilen(
        jahr: jahr,
        monat: monat,
        eintraege: eintraege,
        ortNamen: orte,
        regel: regel,
        bloecke: bloecke);
    final summe = monatsSumme(eintraege, regel, bloecke: bloecke);

    final jsonText = ZeitexaJson.export(
        user: user,
        regel: regel,
        monat: monatsKey(jahr, monat),
        eintraege: eintraege,
        ortNamen: orte);
    final xlsx = excelExport(
        branding: branding,
        jahr: jahr,
        monat: monat,
        zeilen: zeilen,
        summe: summe);
    final pdf = await pdfExport(
        branding: branding,
        jahr: jahr,
        monat: monat,
        zeilen: zeilen,
        summe: summe);
    final betreff = await berechneBetreff(user, jahr, monat, branding: branding);

    return ExportDateien(
      basisname: 'Zeitexa_${user.username}_${monatsKey(jahr, monat)}',
      betreff: betreff,
      jsonBytes: Uint8List.fromList(utf8.encode(jsonText)),
      xlsxBytes: xlsx,
      pdfBytes: pdf,
    );
  }

  /// Setzt die Betreff-Vorlage (Verwaltung → Optionen) mit den Platzhaltern
  /// {Mitarbeiter} {Monat} {Jahr} {Firma} {Zeitraum} um.
  Future<String> berechneBetreff(User user, int jahr, int monat,
      {Branding? branding}) async {
    final vorlage =
        await db.getSetting(SettingsKeys.betreffVorlage) ?? kBetreffVorlageStandard;
    final b = branding ?? await db.branding();
    return vorlage
        .replaceAll('{Mitarbeiter}', user.displayName)
        .replaceAll('{Monat}', monatsNamen[monat - 1])
        .replaceAll('{Jahr}', jahr.toString())
        .replaceAll('{Firma}', b.firmenname)
        .replaceAll('{Zeitraum}', monatsTitel(jahr, monat));
  }

  bool get smtpMoeglich => plattform.smtpVerfuegbar;

  Future<bool> smtpKonfiguriert() async {
    if (!smtpMoeglich) return false;
    final host = await db.getSetting(SettingsKeys.smtpHost);
    final user = await db.getSetting(SettingsKeys.smtpUser);
    return (host ?? '').isNotEmpty && (user ?? '').isNotEmpty;
  }

  /// Speichert die Dateien in Dokumente/Zeitexa-Exporte (nicht auf Web).
  Future<List<String>> speichereLokal(ExportDateien dateien) =>
      plattform.speichereDateien(dateien.basisname, dateien.alsListe);

  Future<({String host, int port, bool ssl, String user, String pass, String ziel})>
      _smtpDaten() async => (
            host: await db.getSetting(SettingsKeys.smtpHost) ?? '',
            port: int.tryParse(
                    await db.getSetting(SettingsKeys.smtpPort) ?? '') ??
                465,
            ssl: await db.getBoolSetting(SettingsKeys.smtpSsl, fallback: true),
            user: await db.getSetting(SettingsKeys.smtpUser) ?? '',
            pass: await db.getSetting(SettingsKeys.smtpPass) ?? '',
            ziel: await db.getSetting(SettingsKeys.zielEmail) ?? '',
          );

  /// Optionaler vierter Anhang der Monats-Mail: die komplette
  /// Datensicherung (Schalter „Sicherung an die Export-Mail anhängen" in
  /// Verwaltung → Optionen). So liegt jeden Monat automatisch eine
  /// aktuelle Sicherung im Mail-Postfach. Liefert null, wenn der Schalter
  /// aus ist (Standard).
  Future<(String, Uint8List)?> _sicherungsAnhang() async {
    if (!await db.getBoolSetting(SettingsKeys.sicherungMitMail)) return null;
    return (sicherungsDateiname(), await erzeugeJsonSicherung(db));
  }

  /// Verschickt die vollen Daten (JSON+Excel+PDF, optional plus
  /// Datensicherung) per SMTP an den Hauptempfänger.
  Future<void> sendeSmtp(ExportDateien dateien) async {
    final smtp = await _smtpDaten();
    if (smtp.host.isEmpty || smtp.ziel.isEmpty) {
      throw StateError('SMTP oder Ziel-Mailadresse ist nicht konfiguriert '
          '(Verwaltung → Optionen → Mailversand).');
    }
    final sicherung = await _sicherungsAnhang();
    await plattform.sendeSmtpMail(
      host: smtp.host,
      port: smtp.port,
      ssl: smtp.ssl,
      benutzer: smtp.user,
      passwort: smtp.pass,
      ziel: smtp.ziel,
      betreff: dateien.betreff,
      text: 'Automatischer Export aus Zeitexa.\n\nDatei: ${dateien.basisname}\n'
          '${sicherung == null ? '' : '\nMit angehängter Datensicherung '
              '(${sicherung.$1}) – einspielbar unter Verwaltung → Optionen → '
              '„Sicherung wiederherstellen".\n'}',
      anhaenge: [...dateien.alsListe, ?sicherung],
    );
  }

  /// Verschickt NUR die Excel-Liste als eigene, separate Mail (kein CC) an
  /// die Mitarbeiter-Adresse aus dem Profil – für die eigenen Unterlagen.
  Future<void> sendeSmtpMitarbeiterKopie(
      ExportDateien dateien, String mitarbeiterEmail) async {
    final smtp = await _smtpDaten();
    if (smtp.host.isEmpty || mitarbeiterEmail.isEmpty) {
      throw StateError('SMTP ist nicht konfiguriert oder keine '
          'Mitarbeiter-Mailadresse hinterlegt.');
    }
    await plattform.sendeSmtpMail(
      host: smtp.host,
      port: smtp.port,
      ssl: smtp.ssl,
      benutzer: smtp.user,
      passwort: smtp.pass,
      ziel: mitarbeiterEmail,
      betreff: dateien.betreff,
      text: 'Deine Stundenliste aus Zeitexa.\n\nDatei: ${dateien.basisname}\n',
      anhaenge: [dateien.xlsxDatei],
    );
  }

  /// Testmail ohne Anhang (für den „Testmail senden"-Button).
  Future<void> sendeTestmail() async {
    final smtp = await _smtpDaten();
    await plattform.sendeSmtpMail(
      host: smtp.host,
      port: smtp.port,
      ssl: smtp.ssl,
      benutzer: smtp.user,
      passwort: smtp.pass,
      ziel: smtp.ziel,
      betreff: 'Zeitexa Testmail',
      text: 'Die SMTP-Einstellungen funktionieren.',
      anhaenge: const [],
    );
  }

  /// Fallback: Dateien über den Teilen-Dialog (Mail-App) weitergeben –
  /// bei aktivem Schalter ebenfalls mit Datensicherung als Anhang.
  Future<void> teilePerMailApp(ExportDateien dateien) async {
    final ziel = await db.getSetting(SettingsKeys.zielEmail) ?? '';
    final sicherung = await _sicherungsAnhang();
    await SharePlus.instance.share(ShareParams(
      files: [
        XFile.fromData(dateien.jsonBytes,
            name: '${dateien.basisname}.json', mimeType: 'application/json'),
        XFile.fromData(dateien.xlsxBytes,
            name: '${dateien.basisname}.xlsx',
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        XFile.fromData(dateien.pdfBytes,
            name: '${dateien.basisname}.pdf', mimeType: 'application/pdf'),
        if (sicherung != null)
          XFile.fromData(sicherung.$2,
              name: sicherung.$1, mimeType: 'application/json'),
      ],
      subject: dateien.betreff,
      text: ziel.isEmpty
          ? 'Zeitexa-Monatsexport'
          : 'Bitte an $ziel senden – Zeitexa-Monatsexport',
    ));
  }

  /// Markiert einen Monat als versendet (für die Sende-Sperre).
  Future<void> markiereVersendet(int userId, String monat) =>
      db.setSetting(SettingsKeys.versendet(userId, monat), '1');

  Future<bool> istVersendet(int userId, String monat) async =>
      await db.getSetting(SettingsKeys.versendet(userId, monat)) == '1';

  /// Sende-Sperre: Liefert den Monats-Key des Vormonats, wenn dieser noch
  /// nicht versendet wurde, Einträge enthält und die Sperre aktiv ist –
  /// sonst null (keine Sperre).
  Future<String?> sperrGrund(User user, DateTime heute) async {
    final aktiv =
        await db.getBoolSetting(SettingsKeys.sendeSperreAktiv, fallback: false);
    if (!aktiv) return null;
    final vormonatJahr = heute.month == 1 ? heute.year - 1 : heute.year;
    final vormonat = heute.month == 1 ? 12 : heute.month - 1;
    final key = monatsKey(vormonatJahr, vormonat);
    if (await istVersendet(user.id, key)) return null;
    final eintraege = await db.entriesForMonth(user.id, vormonatJahr, vormonat);
    if (eintraege.isEmpty) return null; // nichts zu senden (z.B. neuer Benutzer)
    return key;
  }
}
