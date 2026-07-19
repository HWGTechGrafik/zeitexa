// Entwickler-CLI zum Erzeugen von Zeitexa-Firmenlizenzen.
//
// Befehle:
//   dart run bin/lizenz_generator.dart keygen
//     Erzeugt einmalig ein Ed25519-Schluesselpaar. Der private Schluessel
//     wird lokal in schluessel/privater_schluessel.json gespeichert (NICHT
//     committen!). Der oeffentliche Schluessel wird ausgegeben und muss
//     danach EINMALIG in packages/lizenz_shared/lib/oeffentlicher_schluessel.dart
//     eingetragen werden.
//
//   dart run bin/lizenz_generator.dart erzeugen --firma "Muster GmbH"
//       [--entwickler-passwort "<geheim>"]
//     Erzeugt fuer den angegebenen Firmennamen einen Freischaltcode und eine
//     signierte Lizenzdatei (ausgabe/<firma>.zeitexalizenz.json). Mit
//     --entwickler-passwort wird der bcrypt-Hash des Passworts mitsigniert
//     in die DATEI eingebettet - die App uebernimmt ihn beim Import als
//     Entwickler-/Branding-Passwort (der Freischaltcode bleibt ohne).

import 'dart:convert';
import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:cryptography/cryptography.dart';
import 'package:lizenz_shared/lizenz_shared.dart';

final _schluesselDatei =
    File('${Directory.current.path}/schluessel/privater_schluessel.json');
final _ausgabeVerzeichnis = Directory('${Directory.current.path}/ausgabe');

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    _hilfe();
    exit(1);
  }
  switch (args.first) {
    case 'keygen':
      await _keygen();
      break;
    case 'erzeugen':
      await _erzeugen(args.skip(1).toList());
      break;
    default:
      _hilfe();
      exit(1);
  }
}

void _hilfe() {
  stdout.writeln('''
Zeitexa Lizenzgenerator

Befehle:
  keygen                        Neues Schluesselpaar erzeugen (einmalig!)
  erzeugen --firma "<Name>"     Freischaltcode + Lizenzdatei fuer eine Firma erzeugen
    [--entwickler-passwort "<geheim>"]
                                Bettet zusaetzlich den Hash des
                                Entwickler-Passworts in die Lizenzdatei ein
''');
}

Future<void> _keygen() async {
  if (await _schluesselDatei.exists()) {
    stderr.writeln(
        'Es existiert bereits ein Schluesselpaar unter ${_schluesselDatei.path}.');
    stderr.writeln(
        'Abbruch, um bestehende Lizenzen nicht ungueltig zu machen. '
        'Datei manuell loeschen/umbenennen, falls wirklich ein neues Paar noetig ist.');
    exit(1);
  }
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPair();
  final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
  final publicKey = await keyPair.extractPublicKey();

  await _schluesselDatei.parent.create(recursive: true);
  await _schluesselDatei.writeAsString(const JsonEncoder.withIndent('  ')
      .convert({'privateKeyBase64': base64.encode(privateKeyBytes)}));

  final publicKeyDartListe = publicKey.bytes.join(', ');

  stdout.writeln('Neues Schluesselpaar erzeugt.');
  stdout.writeln('Privater Schluessel gespeichert in: ${_schluesselDatei.path}');
  stdout.writeln('  -> GEHEIM HALTEN, NIEMALS committen oder weitergeben!');
  stdout.writeln('');
  stdout.writeln(
      'Naechster Schritt: Trage den folgenden oeffentlichen Schluessel EINMALIG in');
  stdout.writeln(
      '  packages/lizenz_shared/lib/oeffentlicher_schluessel.dart ein:');
  stdout.writeln('');
  stdout.writeln('const List<int> oeffentlicherSchluesselBytes = [');
  stdout.writeln('  $publicKeyDartListe,');
  stdout.writeln('];');
}

Future<void> _erzeugen(List<String> args) async {
  String? firma;
  String? entwicklerPasswort;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--firma' && i + 1 < args.length) {
      firma = args[i + 1];
    }
    if (args[i] == '--entwickler-passwort' && i + 1 < args.length) {
      entwicklerPasswort = args[i + 1];
    }
  }
  if (firma == null || firma.trim().isEmpty) {
    stderr.writeln('Bitte Firmennamen angeben: erzeugen --firma "Muster GmbH"');
    exit(1);
  }
  if (entwicklerPasswort != null && entwicklerPasswort.length < 12) {
    stderr.writeln('Das Entwickler-Passwort muss mindestens 12 Zeichen haben.');
    exit(1);
  }

  if (!await _schluesselDatei.exists()) {
    stderr.writeln(
        'Kein Schluesselpaar gefunden. Zuerst "keygen" ausfuehren.');
    exit(1);
  }
  final schluesselJson =
      jsonDecode(await _schluesselDatei.readAsString()) as Map;
  final privateKeyBytes =
      base64.decode(schluesselJson['privateKeyBase64'] as String);

  final erzeugt = await erzeugeLizenz(
    privateKeyBytes,
    firma,
    entwicklerPasswortHash: entwicklerPasswort == null
        ? null
        : BCrypt.hashpw(entwicklerPasswort, BCrypt.gensalt()),
  );

  await _ausgabeVerzeichnis.create(recursive: true);
  final zielDatei = File('${_ausgabeVerzeichnis.path}/${erzeugt.dateiName}');
  await zielDatei.writeAsString(erzeugt.dateiJson);

  stdout.writeln('Firma: $firma');
  stdout.writeln('Firmen-Id-Hash: ${erzeugt.lizenz.firmenIdHashHex}');
  stdout.writeln('');
  stdout.writeln('Freischaltcode (in der App eintippen):');
  stdout.writeln(erzeugt.freischaltcode);
  stdout.writeln('');
  stdout.writeln('Signierte Lizenzdatei gespeichert unter: ${zielDatei.path}');
  stdout.writeln(entwicklerPasswort == null
      ? 'Hinweis: Datei OHNE Entwickler-Passwort erzeugt '
          '(--entwickler-passwort fehlt).'
      : 'Entwickler-Passwort ist als Hash in der Datei enthalten.');
}
