import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:lizenz_shared/lizenz_shared.dart';
import 'package:test/test.dart';

Future<SignierteLizenz> _signiereFuer(String firmenname, SimpleKeyPair schluesselpaar) async {
  final payload = await erstellePayload(firmenname);
  final signatur = await signierePayload(payload, schluesselpaar);
  return SignierteLizenz(payload: payload, signatur: signatur);
}

void main() {
  group('pruefeLizenz (End-zu-Ende mit einem Test-Schlüsselpaar)', () {
    test('gültige Signatur + exakt passender Firmenname -> gültig', () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final oeffentlich = await schluesselpaar.extractPublicKey();
      final lizenz = await _signiereFuer('Muster GmbH', schluesselpaar);

      expect(
        await pruefeLizenz(lizenz, 'Muster GmbH', oeffentlich.bytes),
        isTrue,
      );
    });

    test('Groß-/Kleinschreibung, Umlaut-Schreibweise und Leerzeichen spielen '
        'keine Rolle', () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final oeffentlich = await schluesselpaar.extractPublicKey();
      final lizenz = await _signiereFuer('Müller & Söhne GmbH', schluesselpaar);

      expect(
        await pruefeLizenz(
            lizenz, '  mueller   soehne   GMBH  ', oeffentlich.bytes),
        isTrue,
      );
    });

    test('falscher Firmenname -> ungültig', () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final oeffentlich = await schluesselpaar.extractPublicKey();
      final lizenz = await _signiereFuer('Muster GmbH', schluesselpaar);

      expect(
        await pruefeLizenz(lizenz, 'Andere Firma AG', oeffentlich.bytes),
        isFalse,
      );
    });

    test('falscher öffentlicher Schlüssel (fremdes Schlüsselpaar) -> ungültig',
        () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final fremderSchluesselpaar = await Ed25519().newKeyPair();
      final fremderOeffentlich = await fremderSchluesselpaar.extractPublicKey();
      final lizenz = await _signiereFuer('Muster GmbH', schluesselpaar);

      expect(
        await pruefeLizenz(lizenz, 'Muster GmbH', fremderOeffentlich.bytes),
        isFalse,
      );
    });

    test('manipulierte Signatur -> ungültig', () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final oeffentlich = await schluesselpaar.extractPublicKey();
      final lizenz = await _signiereFuer('Muster GmbH', schluesselpaar);
      final manipuliert = SignierteLizenz(
        payload: lizenz.payload,
        signatur: Uint8List(64),
      );

      expect(
        await pruefeLizenz(manipuliert, 'Muster GmbH', oeffentlich.bytes),
        isFalse,
      );
    });
  });

  group('Freischaltcode', () {
    test('formatieren -> parsen ist verlustfrei', () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final lizenz = await _signiereFuer('Muster GmbH', schluesselpaar);

      final code = formatiereFreischaltcode(lizenz);
      expect(code, matches(RegExp(r'^[A-Z2-7]{5}(-[A-Z2-7]{1,5})*$')));

      final geparst = parseFreischaltcode(code);
      expect(geparst.payload, equals(lizenz.payload));
      expect(geparst.signatur, equals(lizenz.signatur));
    });

    test('tolerant gegenüber Leerzeichen, Kleinschreibung und Zeilenumbrüchen',
        () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final lizenz = await _signiereFuer('Muster GmbH', schluesselpaar);
      final code = formatiereFreischaltcode(lizenz);

      final unordentlich = code.toLowerCase().replaceAll('-', '\n  ');
      final geparst = parseFreischaltcode(unordentlich);
      expect(geparst.payload, equals(lizenz.payload));
      expect(geparst.signatur, equals(lizenz.signatur));
    });

    test('falsches Format wirft FormatException', () {
      expect(() => parseFreischaltcode('zu-kurz'), throwsFormatException);
    });
  });

  group('erzeugeLizenz (gemeinsame Funktion fuer CLI und GUI)', () {
    test('erzeugter Code und Datei sind gültig und prüfbar', () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final oeffentlich = await schluesselpaar.extractPublicKey();
      final seed = await schluesselpaar.extractPrivateKeyBytes();

      final erzeugt = await erzeugeLizenz(seed, 'Müller & Söhne GmbH');

      final ausCode = parseFreischaltcode(erzeugt.freischaltcode);
      expect(
        await pruefeLizenz(ausCode, 'Müller & Söhne GmbH', oeffentlich.bytes),
        isTrue,
      );

      final ausDatei = parseLizenzdateiJson(erzeugt.dateiJson);
      expect(
        await pruefeLizenz(ausDatei, 'mueller soehne gmbh', oeffentlich.bytes),
        isTrue,
      );

      expect(erzeugt.dateiName, 'm_ller_s_hne_gmbh.zeitexalizenz.json');
    });

    test('deterministisch: gleicher Name + Schlüssel -> gleicher Code',
        () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final seed = await schluesselpaar.extractPrivateKeyBytes();

      final a = await erzeugeLizenz(seed, 'Muster GmbH');
      final b = await erzeugeLizenz(seed, 'Muster GmbH');
      expect(a.freischaltcode, equals(b.freischaltcode));
    });
  });

  group('Entwickler-Passwort in der Lizenzdatei (Version-2-Payload)', () {
    // Beispielhafter bcrypt-Hash (Inhalt egal, nur das Format zaehlt).
    const passwortHash =
        r'$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';

    test('Datei traegt den Hash mitsigniert, Code bleibt Version 1', () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final oeffentlich = await schluesselpaar.extractPublicKey();
      final seed = await schluesselpaar.extractPrivateKeyBytes();

      final erzeugt = await erzeugeLizenz(seed, 'Muster GmbH',
          entwicklerPasswortHash: passwortHash);

      // Datei: Version 2, Hash enthalten, Signatur und Firmenbindung gueltig.
      final ausDatei = parseLizenzdateiJson(erzeugt.dateiJson);
      expect(ausDatei.payload[0], lizenzFormatVersionMitPasswort);
      expect(ausDatei.entwicklerPasswortHash, passwortHash);
      expect(
        await pruefeLizenz(ausDatei, 'Muster GmbH', oeffentlich.bytes),
        isTrue,
      );

      // Code: unveraendert kompakt, ohne Passwort.
      final ausCode = parseFreischaltcode(erzeugt.freischaltcode);
      expect(ausCode.payload.length, payloadLaenge);
      expect(ausCode.entwicklerPasswortHash, isNull);
    });

    test('manipulierter Passwort-Hash macht die Signatur ungueltig', () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final oeffentlich = await schluesselpaar.extractPublicKey();
      final seed = await schluesselpaar.extractPrivateKeyBytes();

      final erzeugt = await erzeugeLizenz(seed, 'Muster GmbH',
          entwicklerPasswortHash: passwortHash);
      final original = parseLizenzdateiJson(erzeugt.dateiJson);

      // Ein Byte im eingebetteten Hash kippen -> Signatur passt nicht mehr.
      final payload = Uint8List.fromList(original.payload);
      payload[payload.length - 1] ^= 0x01;
      final manipuliert =
          SignierteLizenz(payload: payload, signatur: original.signatur);

      expect(
        await pruefeLizenz(manipuliert, 'Muster GmbH', oeffentlich.bytes),
        isFalse,
      );
    });

    test('Version-1-Lizenz liefert keinen Passwort-Hash (Altbestand)',
        () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final lizenz = await _signiereFuer('Muster GmbH', schluesselpaar);
      expect(lizenz.entwicklerPasswortHash, isNull);
    });

    test('Freischaltcode aus Version-2-Payload wird verweigert', () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final payload =
          await erstellePayloadMitPasswort('Muster GmbH', passwortHash);
      final lizenz = SignierteLizenz(
        payload: payload,
        signatur: await signierePayload(payload, schluesselpaar),
      );
      expect(() => formatiereFreischaltcode(lizenz), throwsArgumentError);
    });
  });

  group('Lizenzdatei (JSON)', () {
    test('erstellen -> parsen ist verlustfrei', () async {
      final schluesselpaar = await Ed25519().newKeyPair();
      final lizenz = await _signiereFuer('Muster GmbH', schluesselpaar);

      final json = erstelleLizenzdateiJson(lizenz, 'Muster GmbH');
      final geparst = parseLizenzdateiJson(json);
      expect(geparst.payload, equals(lizenz.payload));
      expect(geparst.signatur, equals(lizenz.signatur));
    });

    test('ungültiges JSON wirft FormatException', () {
      expect(() => parseLizenzdateiJson('{"foo": "bar"}'), throwsFormatException);
    });
  });
}
