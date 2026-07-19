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

BiometrieService _service(ZeitexaDb db, {bool authErfolg = true}) =>
    BiometrieService(
      db,
      authentifizierer: (_) async => authErfolg,
      geraeteCheck: () async => true,
    );

void main() {
  test('aktivieren/deaktivieren setzt bzw. löscht das Opt-in-Flag', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final userId = await _legeBenutzerAn(db, 'max');

    final biometrie = _service(db);
    expect(await biometrie.istAktiviertFuer(userId), isFalse);
    await biometrie.aktivierenFuer(userId);
    expect(await biometrie.istAktiviertFuer(userId), isTrue);
    await biometrie.deaktivierenFuer(userId);
    expect(await biometrie.istAktiviertFuer(userId), isFalse);
  });

  test('benutzerMitBiometrie liefert nur Benutzer mit gesetztem Flag',
      () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final maxId = await _legeBenutzerAn(db, 'max');
    await _legeBenutzerAn(db, 'moritz');

    final biometrie = _service(db);
    expect(await biometrie.benutzerMitBiometrie(), isEmpty);
    await biometrie.aktivierenFuer(maxId);
    final benutzer = await biometrie.benutzerMitBiometrie();
    expect(benutzer.map((u) => u.username), ['max']);
  });

  test('Admin-Schalter aus → keine biometrischen Anmeldungen, '
      'obwohl Flags gesetzt sind', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final userId = await _legeBenutzerAn(db, 'max');

    final biometrie = _service(db);
    await biometrie.aktivierenFuer(userId);
    expect(await biometrie.istErlaubt(), isTrue); // Default: erlaubt
    await biometrie.setErlaubt(false);
    expect(await biometrie.benutzerMitBiometrie(), isEmpty);
    await biometrie.setErlaubt(true);
    expect(await biometrie.benutzerMitBiometrie(), hasLength(1));
  });

  test('Gerät ohne Biometrie-Unterstützung → keine Anmelde-Buttons',
      () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final userId = await _legeBenutzerAn(db, 'max');

    final biometrie = BiometrieService(
      db,
      authentifizierer: (_) async => true,
      geraeteCheck: () async => false,
    );
    await biometrie.aktivierenFuer(userId);
    expect(await biometrie.benutzerMitBiometrie(), isEmpty);
  });
}
