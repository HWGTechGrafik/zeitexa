import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/logic/backup_service.dart';

void main() {
  test('istSqliteDatei erkennt den SQLite-Header', () {
    final gueltig = Uint8List.fromList(
        [...utf8.encode('SQLite format 3'), 0, 1, 2, 3]);
    expect(istSqliteDatei(gueltig), isTrue);

    expect(istSqliteDatei(Uint8List(0)), isFalse);
    expect(istSqliteDatei(Uint8List.fromList(utf8.encode('SQLite form'))),
        isFalse);
    expect(
        istSqliteDatei(
            Uint8List.fromList(utf8.encode('{"kein":"sqlite"}xxxx'))),
        isFalse);
  });

  test('VACUUM INTO erzeugt eine vollständige, eigenständige Kopie der '
      'Datenbank (Grundlage der Sicherung)', () async {
    final tempDir = await Directory.systemTemp.createTemp('zeitexa_test');
    addTearDown(() => tempDir.delete(recursive: true));

    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await (db.update(db.brandings)..where((t) => t.id.equals(1)))
        .write(const BrandingsCompanion(firmenname: Value('Muster GmbH')));
    await db.into(db.users).insert(UsersCompanion.insert(
          username: 'chef',
          passwordHash: 'hash',
          displayName: 'Der Chef',
          isAdmin: const Value(true),
        ));

    final zielPfad =
        '${tempDir.path}${Platform.pathSeparator}sicherung.zeitexadb';
    await db.customStatement('VACUUM INTO ?', [zielPfad]);

    final bytes = await File(zielPfad).readAsBytes();
    expect(istSqliteDatei(bytes), isTrue);

    final kopie = ZeitexaDb.forTesting(NativeDatabase(File(zielPfad)));
    addTearDown(kopie.close);
    expect((await kopie.branding()).firmenname, 'Muster GmbH');
    final users = await kopie.allUsers();
    expect(users, hasLength(1));
    expect(users.single.username, 'chef');
  });

  test('nur Sicherungen mit Zeitexa-Kennung werden angenommen', () async {
    final tempDir = await Directory.systemTemp.createTemp('zeitexa_test');
    addTearDown(() => tempDir.delete(recursive: true));

    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    // beforeOpen läuft erst beim ersten Zugriff – Kennung setzen wie im
    // laufenden Betrieb.
    await db.setSetting(SettingsKeys.produktKennung, kProduktKennung);

    final zielPfad =
        '${tempDir.path}${Platform.pathSeparator}sicherung.zeitexadb';
    await db.customStatement('VACUUM INTO ?', [zielPfad]);
    final eigene = await File(zielPfad).readAsBytes();
    expect(istZeitexaSicherung(eigene), isTrue);

    // Eine Datenbank ohne Kennung steht für die Firmenversion Zeitrax.
    final fremd = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(fremd.close);
    await fremd.into(fremd.users).insert(UsersCompanion.insert(
          username: 'chef',
          passwordHash: 'hash',
          displayName: 'Der Chef',
        ));
    await fremd.loescheSetting(SettingsKeys.produktKennung);
    final fremdPfad =
        '${tempDir.path}${Platform.pathSeparator}fremd.zeitraxdb';
    await fremd.customStatement('VACUUM INTO ?', [fremdPfad]);
    final fremdBytes = await File(fremdPfad).readAsBytes();

    expect(istSqliteDatei(fremdBytes), isTrue, reason: 'ist eine SQLite-Datei');
    expect(istZeitexaSicherung(fremdBytes), isFalse,
        reason: 'aber ohne Zeitexa-Kennung');
  });
}
