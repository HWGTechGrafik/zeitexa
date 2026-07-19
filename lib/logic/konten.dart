/// Kontenführung für Resturlaub, Firmenurlaub, Zeitausgleich, Sonderurlaub
/// und Kranktage.
///
/// Urlaub wird anteilig verbraucht: maßgeblich ist der Urlaubsanteil des
/// Tages im Verhältnis zum Tagessoll (siehe `tagesAnteil` in
/// lib/logic/berechnung.dart), ein ganzer Tag also 1,0, ein halber 0,5 und
/// 6,25 h bei 8 h Soll 0,78.
///
/// Sonderurlaub (Pflegefreistellung, Umzug, …) wird bewusst nur GEZÄHLT –
/// es gibt kein Kontingent und keinen Restsaldo. Firmenurlaub dagegen hat
/// ein eigenes, nicht verfallendes Kontingent je Mitarbeiter.
///
/// Zeitausgleich ist EIN Topf mit den Überstunden: der Kontostand ist der
/// Anfangsstand plus alle seither aufgelaufenen Überstunden (Ist − Soll je
/// Tag) inklusive der als „Zeitausgleich" genommenen Tage (die laut
/// [berechneTag] mit −Soll eingehen). Der Saldo läuft automatisch und
/// unbegrenzt über den Jahreswechsel weiter, es gibt keinen Verfall/Deckel.
///
/// Bewusst ohne DB-Abhängigkeit gehalten, damit die reine Rechenlogik
/// isoliert testbar bleibt.
library;

import '../data/database.dart' show TimeEntry, Tagesart;
import 'berechnung.dart';

/// Konten-Stand zu einem Stichtag, jeweils für den aktuellen Monat und die
/// gesamte Laufzeit (seit dem Anfangsstand-Stichtag).
class KontenStand {
  /// Genommene Urlaubstage im aktuellen Monat (anteilig, siehe oben).
  /// Monatswerte zählen IMMER den vollen angezeigten Monat – der
  /// Anfangsstand-Stichtag beeinflusst nur die Laufzeit-Werte.
  ///
  /// Bei getrenntem Freitags-Urlaub ([urlaubFrGetrennt] in den
  /// Benutzereinstellungen) enthalten [urlaubMonat]/[urlaubGesamt] nur
  /// Mo–Do (Sa/So zählen zur Sicherheit ebenfalls hierher) und
  /// [urlaubFrMonat]/[urlaubFrGesamt] die Freitage. Ohne Trennung landet
  /// alles in [urlaubMonat]/[urlaubGesamt] und die Fr-Werte bleiben 0.
  final double urlaubMonat;

  /// Resturlaub-Saldo: Anfangsstand − alle genommenen Urlaubstage seit dem
  /// Anfangsstand-Stichtag.
  final double urlaubGesamt;

  /// Freitags-Urlaub im aktuellen Monat (nur bei getrennter Führung).
  final double urlaubFrMonat;

  /// Freitags-Resturlaub-Saldo (nur bei getrennter Führung).
  final double urlaubFrGesamt;

  /// Zeitausgleich-Veränderung im aktuellen Monat (kann negativ sein).
  final double zeitausgleichMonat;

  /// Zeitausgleich-Kontostand: Anfangsstand + alle Überstunden seit dem
  /// Anfangsstand-Stichtag.
  final double zeitausgleichGesamt;

  /// Kranktage im aktuellen Monat.
  final int krankMonat;

  /// Kranktage insgesamt (unabhängig vom Anfangsstand-Stichtag, da es dafür
  /// keinen Anfangsstand gibt).
  final int krankGesamt;

  /// Sonderurlaub (Pflegefreistellung, Umzug, Hochzeit, …) im aktuellen
  /// Monat bzw. insgesamt. Reiner ZÄHLER: Sonderurlaub hat bewusst kein
  /// Kontingent und belastet kein Konto.
  final double sonderurlaubMonat;
  final double sonderurlaubGesamt;

  /// Interner Firmenurlaub im aktuellen Monat (nur bei aktivem Konto).
  final double firmenurlaubMonat;

  /// Firmenurlaub-Saldo: Anfangsstand − Verbrauch seit dem Stichtag. Das
  /// Kontingent verfällt nicht, der Chef erhöht den Anfangsstand jährlich.
  final double firmenurlaubGesamt;

  const KontenStand({
    required this.urlaubMonat,
    required this.urlaubGesamt,
    this.urlaubFrMonat = 0,
    this.urlaubFrGesamt = 0,
    required this.zeitausgleichMonat,
    required this.zeitausgleichGesamt,
    required this.krankMonat,
    required this.krankGesamt,
    this.sonderurlaubMonat = 0,
    this.sonderurlaubGesamt = 0,
    this.firmenurlaubMonat = 0,
    this.firmenurlaubGesamt = 0,
  });
}

/// Berechnet den Konten-Stand aus ALLEN Zeiteinträgen eines Benutzers
/// (nicht nur dem angezeigten Monat).
KontenStand berechneKonten({
  required List<TimeEntry> alleEintraege,
  required SollRegel regel,
  required int jahr,
  required int monat,
  required double anfangsstandUrlaubTage,
  required double anfangsstandZeitausgleichStunden,
  required DateTime? anfangsstandStichtag,
  bool urlaubFrGetrennt = false,
  double anfangsstandUrlaubFrTage = 0,
  bool firmenurlaubAktiv = false,
  double anfangsstandFirmenurlaubTage = 0,
}) {
  var urlaubMonat = 0.0;
  var urlaubGenommenGesamt = 0.0;
  var urlaubFrMonat = 0.0;
  var urlaubFrGenommenGesamt = 0.0;
  var sonderurlaubMonat = 0.0;
  var sonderurlaubGesamt = 0.0;
  var firmenurlaubMonat = 0.0;
  var firmenurlaubGenommenGesamt = 0.0;
  var zeitausgleichMonat = 0.0;
  var zeitausgleichSummeGesamt = 0.0;
  var krankMonat = 0;
  var krankGesamt = 0;

  for (final e in alleEintraege) {
    final istAktuellerMonat = e.datum.year == jahr && e.datum.month == monat;
    final istFrUrlaub =
        urlaubFrGetrennt && e.datum.weekday == DateTime.friday;
    final tagDaten = TagDaten(
      datum: e.datum,
      tagesart: e.tagesart,
      beginnMin: e.beginnMin,
      pauseMin: e.pauseMin,
      endeMin: e.endeMin,
      urlaubMinuten: e.urlaubMinuten,
      halberTag: e.halberTag,
    );
    final ergebnis = berechneTag(tagDaten, regel);
    final ueberstunden = ergebnis.ueberstunden;

    // Verbrauchte Tage: anteilig zum Tagessoll (halber Tag = 0,5; 6,25 h
    // bei 8 h Soll = 0,78).
    final verbrauch = urlaubsArten.contains(e.tagesart)
        ? tagesAnteil(tagDaten, ergebnis.soll)
        : 0.0;
    final urlaubTage = e.tagesart == Tagesart.urlaub && !istFrUrlaub
        ? verbrauch
        : 0.0;
    final urlaubFrTage =
        e.tagesart == Tagesart.urlaub && istFrUrlaub ? verbrauch : 0.0;
    final sonderTage =
        e.tagesart == Tagesart.sonderurlaub ? verbrauch : 0.0;
    final firmenTage =
        e.tagesart == Tagesart.firmenurlaub ? verbrauch : 0.0;

    // Monatswerte: immer der volle angezeigte Monat, ohne Stichtag-Filter.
    if (istAktuellerMonat) {
      if (e.tagesart == Tagesart.krank) krankMonat++;
      urlaubMonat += urlaubTage;
      urlaubFrMonat += urlaubFrTage;
      sonderurlaubMonat += sonderTage;
      firmenurlaubMonat += firmenTage;
      zeitausgleichMonat += ueberstunden;
    }

    if (e.tagesart == Tagesart.krank) krankGesamt++;

    // Laufzeit-Werte: nur Einträge ab dem Anfangsstand-Stichtag – alles
    // davor steckt bereits im Anfangsstand.
    final nachStichtag = anfangsstandStichtag == null ||
        !e.datum.isBefore(anfangsstandStichtag);
    if (!nachStichtag) continue;

    urlaubGenommenGesamt += urlaubTage;
    urlaubFrGenommenGesamt += urlaubFrTage;
    sonderurlaubGesamt += sonderTage;
    firmenurlaubGenommenGesamt += firmenTage;
    zeitausgleichSummeGesamt += ueberstunden;
  }

  return KontenStand(
    urlaubMonat: urlaubMonat,
    urlaubGesamt: anfangsstandUrlaubTage - urlaubGenommenGesamt,
    urlaubFrMonat: urlaubFrMonat,
    urlaubFrGesamt: urlaubFrGetrennt
        ? anfangsstandUrlaubFrTage - urlaubFrGenommenGesamt
        : 0,
    zeitausgleichMonat: zeitausgleichMonat,
    zeitausgleichGesamt:
        anfangsstandZeitausgleichStunden + zeitausgleichSummeGesamt,
    krankMonat: krankMonat,
    krankGesamt: krankGesamt,
    sonderurlaubMonat: sonderurlaubMonat,
    sonderurlaubGesamt: sonderurlaubGesamt,
    firmenurlaubMonat: firmenurlaubMonat,
    firmenurlaubGesamt: firmenurlaubAktiv
        ? anfangsstandFirmenurlaubTage - firmenurlaubGenommenGesamt
        : 0,
  );
}
