import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lizenz_shared/lizenz_shared.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/logic/auth.dart';
import 'package:zeitexa/logic/lizenz_service.dart';

Future<(SignierteLizenz, List<int>)> _erzeugeTestLizenz(String name) async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPair();
  final payload = await erstellePayload(name);
  final signatur = await signierePayload(payload, keyPair);
  final publicKey = await keyPair.extractPublicKey();
  return (SignierteLizenz(payload: payload, signatur: signatur), publicKey.bytes);
}

void main() {
  test('ohne gespeicherte Lizenz ist die App gesperrt', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await (db.update(db.brandings)..where((t) => t.id.equals(1)))
        .write(const BrandingsCompanion(firmenname: Value('Max Muster')));

    final service = LizenzService(db);
    expect(await service.istFreigeschaltet(), isFalse);
  });

  test('mit einem fremden (nicht vom echten Entwickler-Schlüssel signierten) '
      'Schlüssel signierte Lizenzen werden abgelehnt, selbst bei passendem '
      'Namen', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final service = LizenzService(db);
    final (fremdeLizenz, _) = await _erzeugeTestLizenz('Lisa Beispiel');
    final ergebnis = await service
        .dateiEinloesen(erstelleLizenzdateiJson(fremdeLizenz, 'Lisa Beispiel'));
    expect(ergebnis, isA<LizenzFehler>());
    expect(await service.istFreigeschaltet(), isFalse);
    // Ein fehlgeschlagenes Einlösen darf den Lizenznamen nicht verändern.
    expect((await db.branding()).firmenname, 'Zeitexa');
  });

  test('erfolgreiches Einlösen per Code übernimmt den Namen und schaltet '
      'die App frei', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final (lizenz, publicKey) = await _erzeugeTestLizenz('Max Muster');
    final service = LizenzService(db, oeffentlicherSchluessel: publicKey);
    final ergebnis = await service.codeEinloesen(
        formatiereFreischaltcode(lizenz), '  Max Muster ');
    expect(ergebnis, isA<LizenzOk>());
    expect((await db.branding()).firmenname, 'Max Muster');
    expect(await service.istFreigeschaltet(), isTrue);
  });

  test('Datei-Import liest den Namen aus der Datei selbst', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final (lizenz, publicKey) = await _erzeugeTestLizenz('Max Muster');
    final service = LizenzService(db, oeffentlicherSchluessel: publicKey);
    final ergebnis = await service
        .dateiEinloesen(erstelleLizenzdateiJson(lizenz, 'Max Muster'));
    expect(ergebnis, isA<LizenzOk>());
    expect((await db.branding()).firmenname, 'Max Muster');
    expect(await service.istFreigeschaltet(), isTrue);
  });

  test('Datei mit manipuliertem Klartext-Namen wird abgelehnt', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final (lizenz, publicKey) = await _erzeugeTestLizenz('Max Muster');
    final service = LizenzService(db, oeffentlicherSchluessel: publicKey);
    // Angreifer tauscht den Klartext-Namen aus - die Signatur bindet aber
    // den Hash des echten Namens.
    final ergebnis = await service
        .dateiEinloesen(erstelleLizenzdateiJson(lizenz, 'Lisa Beispiel'));
    expect(ergebnis, isA<LizenzFehler>());
    expect(await service.istFreigeschaltet(), isFalse);
  });

  test('neue Lizenz mit anderem Namen aktualisiert auch den Anzeigenamen '
      'des Profils', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final (lizenz, publicKey) = await _erzeugeTestLizenz('Max Muster');
    final service = LizenzService(db, oeffentlicherSchluessel: publicKey);
    await service.dateiEinloesen(erstelleLizenzdateiJson(lizenz, 'Max Muster'));
    final auth = AuthService(db);
    await auth.ersteinrichtung(anzeigename: 'Max Muster');

    // Korrigierte Lizenz (z.B. Tippfehler oder Namensänderung).
    final (neueLizenz, neuerKey) = await _erzeugeTestLizenz('Max Mustermann');
    final service2 = LizenzService(db, oeffentlicherSchluessel: neuerKey);
    final ergebnis = await service2
        .dateiEinloesen(erstelleLizenzdateiJson(neueLizenz, 'Max Mustermann'));
    expect(ergebnis, isA<LizenzOk>());
    expect((await db.branding()).firmenname, 'Max Mustermann');
    expect((await auth.einzelUser())!.displayName, 'Max Mustermann');
  });

  test('synchronisiereAnzeigename gleicht Altinstallationen an den '
      'Lizenznamen an', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await (db.update(db.brandings)..where((t) => t.id.equals(1)))
        .write(const BrandingsCompanion(firmenname: Value('Max Muster')));
    final auth = AuthService(db);
    await auth.ersteinrichtung(anzeigename: 'Alter Freitext-Name');

    await LizenzService(db).synchronisiereAnzeigename();
    expect((await auth.einzelUser())!.displayName, 'Max Muster');
  });

  test('Datei mit Version-2-Payload (Entwickler-Passwort) bleibt einlösbar; '
      'der Passwort-Hash wird ignoriert und nicht gespeichert', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    const passwortHash =
        r'$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final seed = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    final erzeugt = await erzeugeLizenz(seed, 'Max Muster',
        entwicklerPasswortHash: passwortHash);

    final service = LizenzService(db, oeffentlicherSchluessel: publicKey.bytes);
    final ergebnis = await service.dateiEinloesen(erzeugt.dateiJson);
    expect(ergebnis, isA<LizenzOk>());
    expect(await service.istFreigeschaltet(), isTrue);
    expect(await db.getSetting('brandingPasswordHash'), isNull);
  });

  test('leerer Name oder leerer Code werden abgewiesen', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final service = LizenzService(db);
    expect(await service.codeEinloesen('ABC', '  '), isA<LizenzFehler>());
    expect(await service.codeEinloesen('', 'Max Muster'), isA<LizenzFehler>());
    expect(await service.dateiEinloesen('{}'), isA<LizenzFehler>());
  });

  test('Lizenzdatei ohne Klartext-Namen wird mit klarer Meldung abgewiesen',
      () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final (lizenz, publicKey) = await _erzeugeTestLizenz('Max Muster');
    final service = LizenzService(db, oeffentlicherSchluessel: publicKey);
    final ohneName = erstelleLizenzdateiJson(lizenz, '');
    final ergebnis = await service.dateiEinloesen(ohneName);
    expect(ergebnis, isA<LizenzFehler>());
    expect((ergebnis as LizenzFehler).meldung, contains('keinen Namen'));
  });

  test('Freischaltcode-Format ist stabil (Parsen und Formatieren invers)', () async {
    final (lizenz, _) = await _erzeugeTestLizenz('Lisa Beispiel');
    final code = formatiereFreischaltcode(lizenz);
    expect(code, contains('-'));
    final geparst = parseFreischaltcode(code);
    expect(geparst.payload, equals(lizenz.payload));
    expect(geparst.signatur, equals(lizenz.signatur));
  });

  test('Namens-Normalisierung ignoriert Groß-/Kleinschreibung und Leerzeichen',
      () {
    expect(normalisiereFirmenname('Jörg Müller-Lüdenscheidt'),
        normalisiereFirmenname('  jörg   MÜLLER lüdenscheidt  '));
  });
}
