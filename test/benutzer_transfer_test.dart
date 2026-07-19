import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/logic/benutzer_transfer.dart';

/// Legt einen Benutzer samt Settings an und liefert dessen Id.
Future<int> _anlegen(
  ZeitexaDb db, {
  required String username,
  String passwordHash = 'HASH',
  String displayName = 'Name',
  bool isAdmin = false,
  String email = '',
  double sollTag = 8,
  double urlaub = 0,
  DateTime? stichtag,
  int standardBeginn = 7 * 60,
}) async {
  final id = await db.into(db.users).insert(UsersCompanion.insert(
        username: username,
        passwordHash: passwordHash,
        displayName: displayName,
        isAdmin: Value(isAdmin),
        mustChangePassword: const Value(true),
        mitarbeiterEmail: Value(email),
      ));
  await db.into(db.userSettings).insert(UserSettingsCompanion.insert(
        userId: Value(id),
        sollModus: SollModus.gleich,
        sollStundenTag: Value(sollTag),
        standardBeginnMin: Value(standardBeginn),
        anfangsstandStichtag: Value(stichtag),
        anfangsstandUrlaubTage: Value(urlaub),
      ));
  return id;
}

void main() {
  test('neuer Benutzer wird mit vollem Profil + Passwort-Hash angelegt',
      () async {
    final quelle = ZeitexaDb.forTesting(NativeDatabase.memory());
    final ziel = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(quelle.close);
    addTearDown(ziel.close);

    final stichtag = DateTime(2026, 1, 1);
    await _anlegen(quelle,
        username: 'max',
        passwordHash: 'GEHEIM-HASH',
        displayName: 'Max Mustermann',
        isAdmin: true,
        email: 'max@firma.at',
        sollTag: 7.5,
        urlaub: 25,
        stichtag: stichtag,
        standardBeginn: 8 * 60);

    final json = await BenutzerTransfer(quelle).exportiere();
    final r = await BenutzerTransfer(ziel).importiere(json);

    expect(r.neu, 1);
    expect(r.aktualisiert, 0);
    final u = await ziel.userByName('max');
    expect(u, isNotNull);
    expect(u!.passwordHash, 'GEHEIM-HASH');
    expect(u.displayName, 'Max Mustermann');
    expect(u.isAdmin, isTrue);
    expect(u.mitarbeiterEmail, 'max@firma.at');
    final s = await ziel.settingsFor(u.id);
    expect(s.sollStundenTag, 7.5);
    expect(s.anfangsstandUrlaubTage, 25);
    expect(s.anfangsstandStichtag, stichtag);
    expect(s.standardBeginnMin, 8 * 60);
  });

  test(
      'bestehender Benutzer: nur Stundeneinteilung/E-Mail geändert, '
      'Passwort + Anfangsstände bleiben', () async {
    final quelle = ZeitexaDb.forTesting(NativeDatabase.memory());
    final ziel = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(quelle.close);
    addTearDown(ziel.close);

    // Quelle: max mit Soll 9 h, Urlaub-Anfangsstand 25, neuer E-Mail.
    await _anlegen(quelle,
        username: 'max',
        passwordHash: 'NEUER-HASH',
        email: 'neu@firma.at',
        sollTag: 9,
        urlaub: 25,
        stichtag: DateTime(2026, 1, 1),
        standardBeginn: 6 * 60);

    // Ziel: max existiert schon mit anderem Passwort/Anfangsstand.
    final zielStichtag = DateTime(2025, 3, 1);
    await _anlegen(ziel,
        username: 'max',
        passwordHash: 'ALTER-HASH',
        email: 'alt@firma.at',
        sollTag: 8,
        urlaub: 10,
        stichtag: zielStichtag,
        standardBeginn: 7 * 60);

    final json = await BenutzerTransfer(quelle).exportiere();
    final r = await BenutzerTransfer(ziel).importiere(json);

    expect(r.neu, 0);
    expect(r.aktualisiert, 1);
    final u = await ziel.userByName('max');
    // Login/Passwort unangetastet, E-Mail aktualisiert.
    expect(u!.passwordHash, 'ALTER-HASH');
    expect(u.mitarbeiterEmail, 'neu@firma.at');
    final s = await ziel.settingsFor(u.id);
    // Stundeneinteilung aktualisiert ...
    expect(s.sollStundenTag, 9);
    expect(s.standardBeginnMin, 6 * 60);
    // ... aber Anfangsstände unverändert.
    expect(s.anfangsstandUrlaubTage, 10);
    expect(s.anfangsstandStichtag, zielStichtag);
  });

  test('Version 2: Adminpasswort-Hash reist mit, aber nur auf Anforderung',
      () async {
    final quelle = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(quelle.close);
    await _anlegen(quelle, username: 'chef', isAdmin: true);
    await quelle.setSetting(SettingsKeys.adminPasswordHash, 'ADMIN-HASH');
    final json = await BenutzerTransfer(quelle).exportiere();

    // Ersteinrichtung: Flag gesetzt → Adminpasswort wird übernommen.
    final neu = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(neu.close);
    final r = await BenutzerTransfer(neu)
        .importiere(json, adminPasswortUebernehmen: true);
    expect(r.adminGesetzt, isTrue);
    expect(await neu.getSetting(SettingsKeys.adminPasswordHash), 'ADMIN-HASH');

    // Laufender Betrieb: ohne Flag bleibt das eigene Adminpasswort stehen.
    final bestand = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(bestand.close);
    await bestand.setSetting(SettingsKeys.adminPasswordHash, 'EIGENER-HASH');
    final r2 = await BenutzerTransfer(bestand).importiere(json);
    expect(r2.adminGesetzt, isFalse);
    expect(await bestand.getSetting(SettingsKeys.adminPasswordHash),
        'EIGENER-HASH');
  });

  test('Firmenurlaub und Freitagszeiten reisen mit', () async {
    final quelle = ZeitexaDb.forTesting(NativeDatabase.memory());
    final ziel = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(quelle.close);
    addTearDown(ziel.close);

    final id = await _anlegen(quelle, username: 'max');
    await (quelle.update(quelle.userSettings)
          ..where((t) => t.userId.equals(id)))
        .write(const UserSettingsCompanion(
      firmenurlaubAktiv: Value(true),
      anfangsstandFirmenurlaubTage: Value(5),
      standardBeginnFrMin: Value(7 * 60),
      standardEndeFrMin: Value(12 * 60),
      standardPauseFrMin: Value(0),
    ));

    final json = await BenutzerTransfer(quelle).exportiere();
    await BenutzerTransfer(ziel).importiere(json);

    final u = await ziel.userByName('max');
    final s = await ziel.settingsFor(u!.id);
    expect(s.firmenurlaubAktiv, isTrue);
    expect(s.anfangsstandFirmenurlaubTage, 5);
    expect(s.standardEndeFrMin, 12 * 60);
    expect(s.standardPauseFrMin, 0);
  });

  test('Datei der Version 1 bleibt importierbar', () async {
    final ziel = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(ziel.close);
    // Bewusst hart hinterlegt: so sah die Datei in v1.2.5 aus – ohne
    // adminPasswortHash, ohne Firmenurlaub, ohne Freitagszeiten.
    const alt = '''
{
  "typ": "zeitexa-benutzer",
  "version": 1,
  "erstellt": "2026-07-19T10:00:00.000",
  "firma": "Muster GmbH",
  "benutzer": [
    {
      "username": "max",
      "displayName": "Max Mustermann",
      "passwordHash": "ALT-HASH",
      "isAdmin": false,
      "mustChangePassword": false,
      "mitarbeiterEmail": "max@firma.at",
      "settings": {
        "sollModus": 1,
        "sollStundenTag": 8.0,
        "sollStundenMoDo": 8.0,
        "sollStundenFr": 5.0,
        "standardBeginnMin": 420,
        "standardEndeMin": 960,
        "standardPauseMin": 30,
        "anfangsstandStichtag": "2026-01-01T00:00:00.000",
        "anfangsstandUrlaubTage": 25.0,
        "anfangsstandZeitausgleichMin": 0,
        "urlaubFrGetrennt": false,
        "anfangsstandUrlaubFrTage": 0.0
      }
    }
  ]
}
''';
    final r =
        await BenutzerTransfer(ziel).importiere(alt, adminPasswortUebernehmen: true);
    expect(r.neu, 1);
    // Kein Adminpasswort in der Datei → der Setup-Screen fragt es weiter ab.
    expect(r.adminGesetzt, isFalse);
    final u = await ziel.userByName('max');
    final s = await ziel.settingsFor(u!.id);
    expect(s.anfangsstandUrlaubTage, 25);
    expect(s.firmenurlaubAktiv, isFalse);
    expect(s.standardBeginnFrMin, isNull);
  });

  test('fremde Datei wird abgelehnt', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    expect(() => BenutzerTransfer(db).importiere('{"typ":"anders"}'),
        throwsA(isA<FormatException>()));
    expect(() => BenutzerTransfer(db).importiere('kein json'),
        throwsA(isA<FormatException>()));
  });
}
