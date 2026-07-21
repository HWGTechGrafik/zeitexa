import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/logic/backup_json.dart';

ZeitexaDb _db() => ZeitexaDb.forTesting(NativeDatabase.memory());

Future<int> _userMitTag(ZeitexaDb db, DateTime tag) async {
  final userId = await db.into(db.users).insert(UsersCompanion.insert(
        username: 'u',
        passwordHash: 'h',
        displayName: 'U',
      ));
  await db.settingsFor(userId);
  await db.upsertEntry(TimeEntriesCompanion.insert(
    userId: userId,
    datum: tag,
    tagesart: Tagesart.arbeit,
    beginnMin: const Value(8 * 60),
    endeMin: const Value(17 * 60),
    pauseMin: const Value(60),
  ));
  return userId;
}

void main() {
  final tag = DateTime(2026, 7, 13);

  test('setzeBloecke speichert erst ab zwei Blöcken; einer bleibt flach',
      () async {
    final db = _db();
    final userId = await _userMitTag(db, tag);
    final id = (await db.eintragId(userId, tag))!;

    // Ein Block → keine Zeilen.
    await db.setzeBloecke(id, [(beginnMin: 8 * 60, endeMin: 16 * 60)]);
    expect(await db.bloeckeFuer(id), isEmpty);

    // Zwei Blöcke → gespeichert, aufsteigend sortiert.
    await db.setzeBloecke(id, [
      (beginnMin: 13 * 60, endeMin: 17 * 60),
      (beginnMin: 8 * 60, endeMin: 12 * 60),
    ]);
    final blk = await db.bloeckeFuer(id);
    expect(blk.length, 2);
    expect(blk.first.beginnMin, 8 * 60);
    expect(blk.last.endeMin, 17 * 60);
    await db.close();
  });

  test('watchBlockAnzahlFuerMonat zählt nur Tage mit ≥2 Blöcken', () async {
    final db = _db();
    final userId = await _userMitTag(db, tag);
    final id = (await db.eintragId(userId, tag))!;
    await db.setzeBloecke(id, [
      (beginnMin: 8 * 60, endeMin: 12 * 60),
      (beginnMin: 13 * 60, endeMin: 17 * 60),
    ]);
    final anzahl =
        await db.watchBlockAnzahlFuerMonat(userId, 2026, 7).first;
    expect(anzahl[id], 2);
    await db.close();
  });

  test('deleteEntry entfernt auch die Blöcke', () async {
    final db = _db();
    final userId = await _userMitTag(db, tag);
    final id = (await db.eintragId(userId, tag))!;
    await db.setzeBloecke(id, [
      (beginnMin: 8 * 60, endeMin: 12 * 60),
      (beginnMin: 13 * 60, endeMin: 17 * 60),
    ]);
    await db.deleteEntry(userId, tag);
    expect(await db.bloeckeFuer(id), isEmpty);
    await db.close();
  });

  test('Vollsicherung nimmt Blöcke mit und stellt sie wieder her', () async {
    final db = _db();
    final userId = await _userMitTag(db, tag);
    final id = (await db.eintragId(userId, tag))!;
    await db.setzeBloecke(id, [
      (beginnMin: 8 * 60, endeMin: 12 * 60),
      (beginnMin: 13 * 60, endeMin: 17 * 60),
    ]);
    final bytes = await erzeugeJsonSicherung(db);

    final db2 = _db();
    await db2.settingsFor(await db2.into(db2.users).insert(
        UsersCompanion.insert(username: 'x', passwordHash: 'h', displayName: 'X')));
    await spieleJsonSicherungEin(db2, bytes);
    final blk = await db2.bloeckeFuer(id);
    expect(blk.length, 2);
    expect(blk.first.beginnMin, 8 * 60);
    await db.close();
    await db2.close();
  });
}
