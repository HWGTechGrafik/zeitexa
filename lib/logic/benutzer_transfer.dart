import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/database.dart';

/// Export/Import der Mitarbeiter als eine JSON-Datei – damit der Chef alle
/// Benutzer einmal an seinem Rechner anlegt und danach auf jedem weiteren
/// Gerät (nach der Lizenz-Freischaltung) einspielt, statt überall Passwörter
/// und Profile neu einzutippen. Enthält KEINE Zeiteinträge (die bleiben pro
/// Gerät). Läuft dateibasiert auf allen Plattformen inkl. iPhone-PWA.
///
/// Ab Version 2 bringt die Datei zusätzlich den bcrypt-Hash des
/// Adminpassworts mit. Beim Einrichten eines neuen Geräts entfällt damit der
/// Setup-Screen komplett: Lizenz eingeben, Datei wählen, anmelden. Dateien
/// der Version 1 bleiben lesbar – dort fragt der Setup-Screen das
/// Adminpasswort weiterhin ab.
class BenutzerTransfer {
  final ZeitexaDb db;
  BenutzerTransfer(this.db);

  static const _typ = 'zeitexa-benutzer';
  static const _version = 2;

  /// Baut den JSON-Inhalt der Benutzerdatei (alle Mitarbeiter mit vollem
  /// Profil und dem – bereits verschlüsselten – Passwort-Hash).
  Future<String> exportiere() async {
    final users = await db.allUsers();
    final benutzer = <Map<String, dynamic>>[];
    for (final u in users) {
      final s = await db.settingsFor(u.id);
      benutzer.add({
        'username': u.username,
        'displayName': u.displayName,
        'passwordHash': u.passwordHash,
        'isAdmin': u.isAdmin,
        'mustChangePassword': u.mustChangePassword,
        'mitarbeiterEmail': u.mitarbeiterEmail,
        'settings': {
          'sollModus': s.sollModus.index,
          'sollStundenTag': s.sollStundenTag,
          'sollStundenMoDo': s.sollStundenMoDo,
          'sollStundenFr': s.sollStundenFr,
          'standardBeginnMin': s.standardBeginnMin,
          'standardEndeMin': s.standardEndeMin,
          'standardPauseMin': s.standardPauseMin,
          'standardBeginnFrMin': s.standardBeginnFrMin,
          'standardEndeFrMin': s.standardEndeFrMin,
          'standardPauseFrMin': s.standardPauseFrMin,
          'anfangsstandStichtag': s.anfangsstandStichtag?.toIso8601String(),
          'anfangsstandUrlaubTage': s.anfangsstandUrlaubTage,
          'anfangsstandZeitausgleichMin': s.anfangsstandZeitausgleichMin,
          'urlaubFrGetrennt': s.urlaubFrGetrennt,
          'anfangsstandUrlaubFrTage': s.anfangsstandUrlaubFrTage,
          'firmenurlaubAktiv': s.firmenurlaubAktiv,
          'anfangsstandFirmenurlaubTage': s.anfangsstandFirmenurlaubTage,
        },
      });
    }
    final firmenname = (await db.branding()).firmenname;
    return const JsonEncoder.withIndent('  ').convert({
      'typ': _typ,
      'version': _version,
      'erstellt': DateTime.now().toIso8601String(),
      'firma': firmenname,
      // Bereits gehasht (bcrypt) – das Klartext-Passwort verlässt das Gerät
      // nie. Wer die Datei hat, hat ohnehin alle Benutzer-Hashes.
      'adminPasswortHash': await db.getSetting(SettingsKeys.adminPasswordHash),
      'benutzer': benutzer,
    });
  }

  /// Spielt eine Benutzerdatei ein. Neue Benutzer werden komplett angelegt
  /// (inkl. Anfangsstände). Bereits vorhandene Benutzer bleiben mit Login,
  /// Passwort und Anfangsständen unangetastet – nur ihre Stundeneinteilung
  /// (Sollstunden, Standardzeiten) und die Mitarbeiter-E-Mail werden
  /// aktualisiert. Liefert die Anzahl neu angelegter und aktualisierter
  /// Benutzer. Wirft [FormatException] bei fremden Dateien.
  ///
  /// [adminPasswortUebernehmen] nur bei der Ersteinrichtung setzen: dann
  /// wird – falls die Datei einen Adminpasswort-Hash mitbringt – auch der
  /// Chef-Bereich freigeschaltet. Der reguläre Import im Chef-Bereich ruft
  /// ohne das Flag auf und rührt das Adminpasswort nie an.
  Future<({int neu, int aktualisiert, bool adminGesetzt})> importiere(
    String jsonText, {
    bool adminPasswortUebernehmen = false,
  }) async {
    final Object? raw = json.decode(jsonText);
    if (raw is! Map<String, dynamic> || raw['typ'] != _typ) {
      throw const FormatException('Das ist keine Zeitexa-Benutzerdatei.');
    }
    final liste = (raw['benutzer'] as List).cast<Map<String, dynamic>>();
    var neu = 0, aktualisiert = 0;
    for (final b in liste) {
      final username = (b['username'] as String).trim();
      if (username.isEmpty) continue;
      final s = (b['settings'] as Map).cast<String, dynamic>();
      final vorhanden = await db.userByName(username);
      if (vorhanden == null) {
        final id = await db.into(db.users).insert(UsersCompanion.insert(
              username: username,
              passwordHash: b['passwordHash'] as String,
              displayName: (b['displayName'] as String?) ?? username,
              isAdmin: Value((b['isAdmin'] as bool?) ?? false),
              mustChangePassword:
                  Value((b['mustChangePassword'] as bool?) ?? false),
              mitarbeiterEmail:
                  Value((b['mitarbeiterEmail'] as String?) ?? ''),
            ));
        await db.into(db.userSettings).insert(UserSettingsCompanion.insert(
              userId: Value(id),
              sollModus: _modus(s['sollModus']),
              sollStundenTag: Value(_d(s['sollStundenTag'], 8)),
              sollStundenMoDo: Value(_d(s['sollStundenMoDo'], 8)),
              sollStundenFr: Value(_d(s['sollStundenFr'], 5)),
              standardBeginnMin: Value(_i(s['standardBeginnMin'], 7 * 60)),
              standardEndeMin: Value(_i(s['standardEndeMin'], 16 * 60)),
              standardPauseMin: Value(_i(s['standardPauseMin'], 30)),
              standardBeginnFrMin: Value(_iOderNull(s['standardBeginnFrMin'])),
              standardEndeFrMin: Value(_iOderNull(s['standardEndeFrMin'])),
              standardPauseFrMin: Value(_iOderNull(s['standardPauseFrMin'])),
              anfangsstandStichtag: Value(_datum(s['anfangsstandStichtag'])),
              anfangsstandUrlaubTage: Value(_d(s['anfangsstandUrlaubTage'], 0)),
              anfangsstandZeitausgleichMin:
                  Value(_i(s['anfangsstandZeitausgleichMin'], 0)),
              urlaubFrGetrennt:
                  Value((s['urlaubFrGetrennt'] as bool?) ?? false),
              anfangsstandUrlaubFrTage:
                  Value(_d(s['anfangsstandUrlaubFrTage'], 0)),
              firmenurlaubAktiv:
                  Value((s['firmenurlaubAktiv'] as bool?) ?? false),
              anfangsstandFirmenurlaubTage:
                  Value(_d(s['anfangsstandFirmenurlaubTage'], 0)),
            ));
        neu++;
      } else {
        // Sicherstellen, dass eine Settings-Zeile existiert, dann nur die
        // Stundeneinteilung + E-Mail aktualisieren (Anfangsstände bleiben).
        await db.settingsFor(vorhanden.id);
        await (db.update(db.userSettings)
              ..where((t) => t.userId.equals(vorhanden.id)))
            .write(UserSettingsCompanion(
          sollModus: Value(_modus(s['sollModus'])),
          sollStundenTag: Value(_d(s['sollStundenTag'], 8)),
          sollStundenMoDo: Value(_d(s['sollStundenMoDo'], 8)),
          sollStundenFr: Value(_d(s['sollStundenFr'], 5)),
          standardBeginnMin: Value(_i(s['standardBeginnMin'], 7 * 60)),
          standardEndeMin: Value(_i(s['standardEndeMin'], 16 * 60)),
          standardPauseMin: Value(_i(s['standardPauseMin'], 30)),
          standardBeginnFrMin: Value(_iOderNull(s['standardBeginnFrMin'])),
          standardEndeFrMin: Value(_iOderNull(s['standardEndeFrMin'])),
          standardPauseFrMin: Value(_iOderNull(s['standardPauseFrMin'])),
        ));
        await (db.update(db.users)..where((t) => t.id.equals(vorhanden.id)))
            .write(UsersCompanion(
                mitarbeiterEmail:
                    Value((b['mitarbeiterEmail'] as String?) ?? '')));
        aktualisiert++;
      }
    }

    // Adminpasswort nur bei der Ersteinrichtung und nur, wenn die Datei
    // eines mitbringt (Version 1 tut das nicht).
    var adminGesetzt = false;
    final adminHash = raw['adminPasswortHash'];
    if (adminPasswortUebernehmen && adminHash is String && adminHash.isNotEmpty) {
      await db.setSetting(SettingsKeys.adminPasswordHash, adminHash);
      adminGesetzt = true;
    }
    return (neu: neu, aktualisiert: aktualisiert, adminGesetzt: adminGesetzt);
  }

  static SollModus _modus(Object? v) {
    final i = v is int ? v : int.tryParse('$v');
    return (i != null && i >= 0 && i < SollModus.values.length)
        ? SollModus.values[i]
        : SollModus.moDoFrGetrennt;
  }

  static double _d(Object? v, double fallback) =>
      v is num ? v.toDouble() : fallback;

  static int _i(Object? v, int fallback) => v is num ? v.toInt() : fallback;

  /// Für die optionalen Freitagszeiten: fehlt der Wert oder ist er null,
  /// bleibt es bei „wie Mo–Do".
  static int? _iOderNull(Object? v) => v is num ? v.toInt() : null;

  static DateTime? _datum(Object? v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
}
