import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lizenz_shared/lizenz_shared.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/logic/lizenz_service.dart';

Future<(SignierteLizenz, List<int>)> _erzeugeTestLizenz(
    String firmenname) async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPair();
  final payload = await erstellePayload(firmenname);
  final signatur = await signierePayload(payload, keyPair);
  final publicKey = await keyPair.extractPublicKey();
  return (SignierteLizenz(payload: payload, signatur: signatur), publicKey.bytes);
}

void main() {
  test('ohne gespeicherte Lizenz ist die App gesperrt', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await (db.update(db.brandings)..where((t) => t.id.equals(1)))
        .write(const BrandingsCompanion(firmenname: Value('Muster GmbH')));

    final service = LizenzService(db);
    expect(await service.istFreigeschaltet(), isFalse);
  });

  test('mit einem fremden (nicht vom echten Entwickler-Schlüssel signierten) '
      'Schlüssel signierte Lizenzen werden abgelehnt, selbst bei passendem '
      'Firmennamen', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final service = LizenzService(db);
    final (fremdeLizenz, _) = await _erzeugeTestLizenz('Andere Firma AG');
    final ergebnis = await service.dateiEinloesen(
        erstelleLizenzdateiJson(fremdeLizenz, 'Andere Firma AG'),
        'Andere Firma AG');
    expect(ergebnis, isA<LizenzFehler>());
    expect(await service.istFreigeschaltet(), isFalse);
    // Ein fehlgeschlagenes Einlösen darf den Firmennamen nicht verändern.
    expect((await db.branding()).firmenname, 'Zeitexa');
  });

  test('erfolgreiches Einlösen übernimmt den Firmennamen ins Branding und '
      'schaltet die App frei', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final (lizenz, publicKey) = await _erzeugeTestLizenz('Muster GmbH');
    final service = LizenzService(db, oeffentlicherSchluessel: publicKey);
    final ergebnis = await service.codeEinloesen(
        formatiereFreischaltcode(lizenz), '  Muster GmbH ');
    expect(ergebnis, isA<LizenzOk>());
    expect((await db.branding()).firmenname, 'Muster GmbH');
    expect(await service.istFreigeschaltet(), isTrue);
  });

  test('Datei-Import mit Version-2-Payload übernimmt das Entwickler-Passwort',
      () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    const passwortHash =
        r'$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final seed = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    final erzeugt = await erzeugeLizenz(seed, 'Muster GmbH',
        entwicklerPasswortHash: passwortHash);

    final service = LizenzService(db, oeffentlicherSchluessel: publicKey.bytes);
    final ergebnis =
        await service.dateiEinloesen(erzeugt.dateiJson, 'Muster GmbH');
    expect(ergebnis, isA<LizenzOk>());
    expect(await service.istFreigeschaltet(), isTrue);
    expect(await db.getSetting(SettingsKeys.brandingPasswordHash),
        passwortHash);

    // Der Freischaltcode derselben Lizenz bringt KEIN Passwort mit und darf
    // einen vorhandenen Hash nicht überschreiben.
    await db.setSetting(SettingsKeys.brandingPasswordHash, 'alter-hash');
    final ergebnisCode = await service.codeEinloesen(
        erzeugt.freischaltcode, 'Muster GmbH');
    expect(ergebnisCode, isA<LizenzOk>());
    expect(
        await db.getSetting(SettingsKeys.brandingPasswordHash), 'alter-hash');
  });

  test('leerer Firmenname oder leerer Code werden abgewiesen', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final service = LizenzService(db);
    expect(await service.codeEinloesen('ABC', '  '), isA<LizenzFehler>());
    expect(await service.codeEinloesen('', 'Muster GmbH'), isA<LizenzFehler>());
    expect(await service.dateiEinloesen('{}', ''), isA<LizenzFehler>());
  });

  test('Freischaltcode-Format ist stabil (Parsen und Formatieren invers)', () async {
    final (lizenz, _) = await _erzeugeTestLizenz('Beispiel KG');
    final code = formatiereFreischaltcode(lizenz);
    expect(code, contains('-'));
    final geparst = parseFreischaltcode(code);
    expect(geparst.payload, equals(lizenz.payload));
    expect(geparst.signatur, equals(lizenz.signatur));
  });

  test('Firmenname-Normalisierung ignoriert Groß-/Kleinschreibung und Leerzeichen',
      () {
    expect(normalisiereFirmenname('Müller & Söhne GmbH'),
        normalisiereFirmenname('  müller   SÖHNE gmbh  '));
  });
}
