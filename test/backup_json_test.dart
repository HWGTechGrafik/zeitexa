import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/logic/backup_json.dart';
import 'package:zeitexa/logic/backup_service.dart';

ZeitexaDb _neueDb() => ZeitexaDb.forTesting(NativeDatabase.memory());

/// Baut eine Datenbank mit Daten in allen Tabellen (wie im echten Betrieb).
Future<({ZeitexaDb db, int userId, int ortId})> _gefuellteDb() async {
  final db = _neueDb();
  await (db.update(db.brandings)..where((t) => t.id.equals(1)))
      .write(const BrandingsCompanion(firmenname: Value('Muster GmbH')));
  final userId = await db.into(db.users).insert(UsersCompanion.insert(
        username: 'moser',
        passwordHash: 'geheimer-hash',
        displayName: 'Florian Moser',
      ));
  await db.settingsFor(userId);
  final ortId = await db.touchPlace('Büro');
  await db.upsertEntry(TimeEntriesCompanion.insert(
    userId: userId,
    datum: DateTime(2026, 7, 1),
    tagesart: Tagesart.arbeit,
    ortId: Value(ortId),
    beginnMin: const Value(7 * 60),
    pauseMin: const Value(30),
    endeMin: const Value(16 * 60),
    notiz: const Value('Roundtrip-Test'),
  ));
  await db.setSetting(SettingsKeys.zielEmail, 'chef@example.com');
  await db.mergeImport('moser', '2026-06', [
    ImportedEntriesCompanion.insert(
      quellUsername: 'moser',
      quellDisplayName: 'Florian Moser',
      monat: '2026-06',
      datum: DateTime(2026, 6, 15),
      tagesart: Tagesart.urlaub,
      sollStunden: 8,
    ),
  ]);
  return (db: db, userId: userId, ortId: ortId);
}

void main() {
  test('erkenneSicherungsFormat unterscheidet SQLite, JSON und Fremdes', () {
    final sqlite = Uint8List.fromList(
        [...utf8.encode('SQLite format 3'), 0, 1, 2, 3]);
    expect(erkenneSicherungsFormat(sqlite), SicherungsFormat.sqlite);

    expect(erkenneSicherungsFormat(Uint8List.fromList(utf8.encode('{"a":1}'))),
        SicherungsFormat.json);
    // Auch mit UTF-8-BOM und führendem Leerraum.
    expect(
        erkenneSicherungsFormat(Uint8List.fromList(
            [0xEF, 0xBB, 0xBF, ...utf8.encode('  \n{"a":1}')])),
        SicherungsFormat.json);

    expect(erkenneSicherungsFormat(Uint8List(0)), isNull);
    expect(erkenneSicherungsFormat(Uint8List.fromList(utf8.encode('PK-zip'))),
        isNull);
  });

  test('JSON-Sicherung: Roundtrip stellt alle Tabellen wieder her', () async {
    final quelle = await _gefuellteDb();
    addTearDown(quelle.db.close);

    final bytes = await erzeugeJsonSicherung(quelle.db);
    expect(erkenneSicherungsFormat(bytes), SicherungsFormat.json);
    expect(istZeitexaSicherung(bytes), isTrue,
        reason: 'Produktkennung steckt auch im JSON-Format in den Bytes');

    // Zieldatenbank enthält bereits eigene Daten – die müssen ersetzt werden.
    final ziel = _neueDb();
    addTearDown(ziel.close);
    await ziel.into(ziel.users).insert(UsersCompanion.insert(
          username: 'alterNutzer',
          passwordHash: 'x',
          displayName: 'Wird ersetzt',
        ));
    await ziel.setSetting(SettingsKeys.zielEmail, 'falsch@example.com');

    await spieleJsonSicherungEin(ziel, bytes);

    expect((await ziel.branding()).firmenname, 'Muster GmbH');

    final users = await ziel.allUsers();
    expect(users, hasLength(1));
    expect(users.single.username, 'moser');
    expect(users.single.passwordHash, 'geheimer-hash');
    expect(users.single.id, quelle.userId, reason: 'Ids bleiben erhalten');

    final eintraege = await ziel.allEntries(quelle.userId);
    expect(eintraege, hasLength(1));
    expect(eintraege.single.datum, DateTime(2026, 7, 1));
    expect(eintraege.single.tagesart, Tagesart.arbeit);
    expect(eintraege.single.beginnMin, 7 * 60);
    expect(eintraege.single.endeMin, 16 * 60);
    expect(eintraege.single.notiz, 'Roundtrip-Test');
    expect(eintraege.single.ortId, quelle.ortId);

    final orte = await ziel.recentPlaces();
    expect(orte, hasLength(1));
    expect(orte.single.name, 'Büro');

    final einstellungen = await ziel.settingsFor(quelle.userId);
    expect(einstellungen.sollModus, SollModus.moDoFrGetrennt);

    expect(await ziel.getSetting(SettingsKeys.zielEmail), 'chef@example.com');
    expect(await ziel.getSetting(SettingsKeys.produktKennung),
        kProduktKennung);

    final importiert = await ziel.allImported();
    expect(importiert, hasLength(1));
    expect(importiert.single.monat, '2026-06');
    expect(importiert.single.tagesart, Tagesart.urlaub);

    // Neue Einträge nach dem Einspielen kollidieren nicht mit alten Ids.
    await ziel.into(ziel.users).insert(UsersCompanion.insert(
          username: 'neu',
          passwordHash: 'x',
          displayName: 'Neu',
        ));
    expect(await ziel.allUsers(), hasLength(2));
  });

  test('fremde, kaputte und zu neue Dateien werden abgelehnt '
      '(Bestand bleibt unangetastet)', () async {
    final eigene = await _gefuellteDb();
    addTearDown(eigene.db.close);
    final gueltig = await erzeugeJsonSicherung(eigene.db);

    final db = _neueDb();
    addTearDown(db.close);
    await db.setSetting(SettingsKeys.zielEmail, 'bleibt@example.com');

    Uint8List abgewandelt(void Function(Map<String, dynamic>) aendere) {
      final wurzel =
          json.decode(utf8.decode(gueltig)) as Map<String, dynamic>;
      aendere(wurzel);
      return Uint8List.fromList(utf8.encode(json.encode(wurzel)));
    }

    // Kein JSON.
    await expectLater(
        spieleJsonSicherungEin(
            db, Uint8List.fromList(utf8.encode('kein json'))),
        throwsFormatException);
    // JSON, aber keine Zeitexa-Sicherung.
    await expectLater(
        spieleJsonSicherungEin(
            db, Uint8List.fromList(utf8.encode('{"app":"Fremd"}'))),
        throwsFormatException);
    // Ohne Produktkennung (z.B. Firmenversion Zeitrax).
    await expectLater(
        spieleJsonSicherungEin(
            db, abgewandelt((w) => w['produktKennung'] = 'ZEITRAX')),
        throwsFormatException);
    // Aus einer neueren App-Version.
    await expectLater(
        spieleJsonSicherungEin(db,
            abgewandelt((w) => w['schemaVersion'] = (w['schemaVersion'] as int) + 1)),
        throwsFormatException);

    expect(await db.getSetting(SettingsKeys.zielEmail), 'bleibt@example.com',
        reason: 'abgelehnte Dateien dürfen nichts verändern');
  });

  test('Sicherung einer älteren App-Version: fehlende Spalten bekommen '
      'ihre Standardwerte', () async {
    final quelle = await _gefuellteDb();
    addTearDown(quelle.db.close);
    final wurzel = json.decode(utf8.decode(await erzeugeJsonSicherung(quelle.db)))
        as Map<String, dynamic>;
    // So sah eine Sicherung vor Schema 4 aus: ohne Firmenurlaub-Spalten.
    wurzel['schemaVersion'] = 3;
    final tabellen = wurzel['tabellen'] as Map<String, dynamic>;
    for (final zeile
        in (tabellen['user_settings'] as List).cast<Map<String, dynamic>>()) {
      zeile.remove('firmenurlaub_aktiv');
      zeile.remove('anfangsstand_firmenurlaub_tage');
    }

    final ziel = _neueDb();
    addTearDown(ziel.close);
    await spieleJsonSicherungEin(
        ziel, Uint8List.fromList(utf8.encode(json.encode(wurzel))));

    final einstellungen = await ziel.settingsFor(quelle.userId);
    expect(einstellungen.firmenurlaubAktiv, isFalse);
    expect(einstellungen.anfangsstandFirmenurlaubTage, 0);
  });
}
