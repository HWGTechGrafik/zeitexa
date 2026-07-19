import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lizenz_shared/lizenz_shared.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/logic/auth.dart';
import 'package:zeitexa/logic/benutzer_transfer.dart';
import 'package:zeitexa/logic/lizenz_service.dart';
import 'package:zeitexa/main.dart';

/// Kompletter Start-Ablauf auf Provider-Ebene: erst Lizenz, dann
/// Ersteinrichtung, dann bereit.
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

    // Lizenz einlösen (setzt auch den Firmennamen) → Einrichtung fehlt noch.
    final payload = await erstellePayload('Muster GmbH');
    final signatur = await signierePayload(payload, keyPair);
    final code = formatiereFreischaltcode(
        SignierteLizenz(payload: payload, signatur: signatur));
    final ergebnis = await container
        .read(lizenzProvider)
        .codeEinloesen(code, 'Muster GmbH');
    expect(ergebnis, isA<LizenzOk>());
    container.invalidate(gateStatusProvider);
    expect(await container.read(gateStatusProvider.future),
        GateStatus.nichtEingerichtet);

    // Ersteinrichtung (ohne Firmenname – der steht schon fest) → bereit.
    await container.read(authProvider).ersteinrichtung(
          adminPasswort: 'admin',
          username: 'chef',
          anzeigename: 'Der Chef',
          benutzerPasswort: 'geheim',
        );
    container.invalidate(gateStatusProvider);
    expect(await container.read(gateStatusProvider.future), GateStatus.bereit);
    expect((await db.branding()).firmenname, 'Muster GmbH');
  });

  test('Benutzerdatei mit Adminpasswort ersetzt die Ersteinrichtung',
      () async {
    // Quelle: ein bereits eingerichtetes Gerät.
    final quelle = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(quelle.close);
    await AuthService(quelle).ersteinrichtung(
      adminPasswort: 'admin',
      username: 'chef',
      anzeigename: 'Der Chef',
      benutzerPasswort: 'geheim',
    );
    final datei = await BenutzerTransfer(quelle).exportiere();

    // Neues Gerät: frische Datenbank mit Lizenz, aber ohne Einrichtung.
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

    final payload = await erstellePayload('Muster GmbH');
    final signatur = await signierePayload(payload, keyPair);
    await container.read(lizenzProvider).codeEinloesen(
        formatiereFreischaltcode(
            SignierteLizenz(payload: payload, signatur: signatur)),
        'Muster GmbH');
    container.invalidate(gateStatusProvider);
    expect(await container.read(gateStatusProvider.future),
        GateStatus.nichtEingerichtet);

    // Datei übernehmen – ohne ersteinrichtung() ist das Gerät fertig.
    final r = await container
        .read(benutzerTransferProvider)
        .importiere(datei, adminPasswortUebernehmen: true);
    expect(r.neu, 1);
    expect(r.adminGesetzt, isTrue);
    container.invalidate(gateStatusProvider);
    expect(await container.read(gateStatusProvider.future), GateStatus.bereit);

    // Der Chef meldet sich mit seinem gewohnten Passwort an.
    expect(await container.read(authProvider).login('chef', 'geheim'),
        isA<LoginOk>());
  });
}
