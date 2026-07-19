import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/logic/biometrie_service.dart';

Future<int> _legeBenutzerAn(ZeitexaDb db, String username) =>
    db.into(db.users).insert(UsersCompanion.insert(
          username: username,
          passwordHash: 'hash',
          displayName: username,
        ));

BiometrieService _service(ZeitexaDb db, {bool geraetKann = true}) =>
    BiometrieService(
      db,
      authentifizierer: (_) async => true,
      geraeteCheck: () async => geraetKann,
    );

void main() {
  test('aktivieren/deaktivieren setzt bzw. löscht das Opt-in-Flag', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final userId = await _legeBenutzerAn(db, 'ich');

    final biometrie = _service(db);
    expect(await biometrie.istAktiviertFuer(userId), isFalse);
    await biometrie.aktivierenFuer(userId);
    expect(await biometrie.istAktiviertFuer(userId), isTrue);
    await biometrie.deaktivierenFuer(userId);
    expect(await biometrie.istAktiviertFuer(userId), isFalse);
  });

  test('entsperrenMoeglich nur mit Opt-in', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final userId = await _legeBenutzerAn(db, 'ich');

    final biometrie = _service(db);
    expect(await biometrie.entsperrenMoeglich(userId), isFalse);
    await biometrie.aktivierenFuer(userId);
    expect(await biometrie.entsperrenMoeglich(userId), isTrue);
  });

  test('Gerät ohne Biometrie-Unterstützung → kein Entsperren per Finger',
      () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final userId = await _legeBenutzerAn(db, 'ich');

    final biometrie = _service(db, geraetKann: false);
    await biometrie.aktivierenFuer(userId);
    expect(await biometrie.entsperrenMoeglich(userId), isFalse);
  });
}
