import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lizenz_shared/lizenz_shared.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/logic/lizenz_service.dart';
import 'package:zeitexa/main.dart';

/// Kompletter Start-Ablauf auf Provider-Ebene: erst Lizenz, dann
/// Ersteinrichtung (Profil mit dem Lizenznamen), dann bereit – ohne jede
/// Anmeldung.
void main() {
  test('StartGate-Reihenfolge: keineLizenz → nichtEingerichtet → bereit',
      () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();

    final container = ProviderContainer(overrides: [
      dbProvider.overrideWithValue(db),
      lizenzProvider.overrideWithValue(
          LizenzService(db, oeffentlicherSchluessel: publicKey.bytes)),
    ]);
    addTearDown(container.dispose);

    // Frische Datenbank: zuerst die Lizenz-Freischaltung.
    expect(await container.read(gateStatusProvider.future),
        GateStatus.keineLizenz);

    // Lizenz einlösen (setzt auch den Lizenznamen) → Einrichtung fehlt noch.
    final payload = await erstellePayload('Max Muster');
    final signatur = await signierePayload(payload, keyPair);
    final code = formatiereFreischaltcode(
        SignierteLizenz(payload: payload, signatur: signatur));
    final ergebnis =
        await container.read(lizenzProvider).codeEinloesen(code, 'Max Muster');
    expect(ergebnis, isA<LizenzOk>());
    container.invalidate(gateStatusProvider);
    expect(await container.read(gateStatusProvider.future),
        GateStatus.nichtEingerichtet);

    // Ersteinrichtung: Profil mit dem Lizenznamen anlegen.
    await container
        .read(authProvider)
        .ersteinrichtung(anzeigename: 'Max Muster');
    container.invalidate(gateStatusProvider);
    expect(await container.read(gateStatusProvider.future), GateStatus.bereit);
    expect((await db.branding()).firmenname, 'Max Muster');

    // Genau ein Profil, und es ist ohne Anmeldung erreichbar.
    final user = await container.read(authProvider).einzelUser();
    expect(user?.displayName, 'Max Muster');
    expect(await db.allUsers(), hasLength(1));

    // Selbst wenn der Anzeigename in der Datenbank abweichen sollte
    // (Altinstallation), zieht ihn das Gate beim Start auf den Lizenznamen.
    await db.update(db.users).write(
        const UsersCompanion(displayName: drift.Value('Fremder Name')));
    container.invalidate(gateStatusProvider);
    expect(await container.read(gateStatusProvider.future), GateStatus.bereit);
    expect((await container.read(authProvider).einzelUser())?.displayName,
        'Max Muster');
  });

  test('App-Sperre ist standardmäßig aus und lässt sich setzen und entfernen',
      () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    final auth = container.read(authProvider);

    expect(await auth.appSperreAktiv(), isFalse);

    await auth.setzeAppSperre('geheim');
    expect(await auth.appSperreAktiv(), isTrue);
    expect(await auth.pruefeAppSperre('geheim'), isTrue);
    expect(await auth.pruefeAppSperre('falsch'), isFalse);

    await auth.entferneAppSperre();
    expect(await auth.appSperreAktiv(), isFalse);
    // Ohne gesetzte Sperre darf keine Eingabe als gültig durchgehen.
    expect(await auth.pruefeAppSperre('geheim'), isFalse);
  });

  test('Hinweiskarte gilt bis die Einstellungen einmal bestätigt sind',
      () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container =
        ProviderContainer(overrides: [dbProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    expect(await container.read(einstellungenGeprueftProvider.future), isFalse);
    await db.setBoolSetting(SettingsKeys.einstellungenGeprueft, true);
    container.invalidate(einstellungenGeprueftProvider);
    expect(await container.read(einstellungenGeprueftProvider.future), isTrue);
  });
}
