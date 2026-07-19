/// Gemeinsame Logik fuer das Zeitexa-Lizenzsystem.
///
/// Dieses Paket ist reines Dart (keine Flutter-Abhaengigkeit) und wird von
/// zwei Seiten verwendet:
///  - der Zeitexa-App: prueft Lizenzen mit dem OEFFENTLICHEN Schluessel.
///  - dem separaten Lizenzgenerator (tools/lizenz_generator): erzeugt
///    Lizenzen mit dem PRIVATEN Schluessel, der NICHT in diesem Paket liegt.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Version des kompakten Lizenz-Payload-Formats (Freischaltcode und
/// Lizenzdateien ohne Entwickler-Passwort). Bei inkompatiblen Aenderungen
/// erhoehen.
const int lizenzFormatVersion = 1;

/// Payload-Version fuer Lizenzdateien MIT eingebettetem
/// Entwickler-Passwort-Hash (bcrypt). Nur im Datei-Format verwendet -
/// der Freischaltcode bleibt beim kompakten Version-1-Payload, damit er
/// zum Abtippen kurz bleibt.
const int lizenzFormatVersionMitPasswort = 2;

/// Laenge des Firmen-Identifikator-Hashes in Bytes (im Payload enthalten).
const int firmenIdHashLaenge = 8;

/// Laenge einer Ed25519-Signatur in Bytes.
const int signaturLaenge = 64;

/// Laenge des Version-1-Payloads in Bytes (Version + Firmen-Hash).
/// Version-2-Payloads sind laenger (zusaetzlich der Passwort-Hash).
const int payloadLaenge = 1 + firmenIdHashLaenge;

/// Normalisiert einen Firmennamen zu einer stabilen, vergleichbaren Form:
/// Kleinschreibung, deutsche Umlaute ausgeschrieben, ohne Sonderzeichen,
/// mehrfache Leerzeichen zusammengefasst.
///
/// Diese Normalisierung ist die Grundlage der Firmenbindung: Sowohl der
/// Generator (beim Erzeugen der Lizenz) als auch die App (beim Pruefen)
/// muessen exakt dasselbe Ergebnis liefern.
String normalisiereFirmenname(String firmenname) {
  var s = firmenname.trim().toLowerCase();
  const ersetzungen = {
    'ä': 'ae',
    'ö': 'oe',
    'ü': 'ue',
    'ß': 'ss',
  };
  final buffer = StringBuffer();
  for (final rune in s.runes) {
    final zeichen = String.fromCharCode(rune);
    buffer.write(ersetzungen[zeichen] ?? zeichen);
  }
  s = buffer.toString();
  // Nur Buchstaben, Ziffern und Leerzeichen behalten.
  s = s.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  // Mehrfache Leerzeichen zu einem zusammenfassen.
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

/// Berechnet den Firmen-Identifikator-Hash (SHA-256, auf
/// [firmenIdHashLaenge] Bytes gekuerzt) aus dem normalisierten Firmennamen.
///
/// Die Kuerzung dient nur der Kompaktheit des Freischaltcodes; die
/// eigentliche Sicherheit kommt aus der Ed25519-Signatur, nicht aus der
/// Hash-Laenge (ein Angreifer ohne privaten Schluessel kann ohnehin keine
/// gueltige Signatur faelschen).
Future<Uint8List> berechneFirmenIdHash(String firmenname) async {
  final normalisiert = normalisiereFirmenname(firmenname);
  final algorithm = Sha256();
  final hash = await algorithm.hash(utf8.encode(normalisiert));
  return Uint8List.fromList(hash.bytes.sublist(0, firmenIdHashLaenge));
}

/// Baut den (unsignierten) Version-1-Payload fuer einen Firmennamen.
Future<Uint8List> erstellePayload(String firmenname) async {
  final hash = await berechneFirmenIdHash(firmenname);
  return Uint8List.fromList([lizenzFormatVersion, ...hash]);
}

/// Baut den (unsignierten) Version-2-Payload: Firmenbindung PLUS
/// Entwickler-Passwort-Hash (bcrypt-String, z.B. "$2a$10$...").
///
/// Der Hash ist Teil der signierten Daten - eine manipulierte Datei mit
/// ausgetauschtem Passwort-Hash faellt bei der Signaturpruefung durch.
Future<Uint8List> erstellePayloadMitPasswort(
    String firmenname, String entwicklerPasswortHash) async {
  if (entwicklerPasswortHash.isEmpty) {
    throw ArgumentError('Entwickler-Passwort-Hash darf nicht leer sein.');
  }
  final hash = await berechneFirmenIdHash(firmenname);
  return Uint8List.fromList([
    lizenzFormatVersionMitPasswort,
    ...hash,
    ...utf8.encode(entwicklerPasswortHash),
  ]);
}

/// Ergebnis einer Signaturpruefung bzw. Baustein fuer Code/Datei-Export.
class SignierteLizenz {
  final Uint8List payload;
  final Uint8List signatur;

  SignierteLizenz({required this.payload, required this.signatur}) {
    final gueltigV1 =
        payload.length == payloadLaenge && payload[0] == lizenzFormatVersion;
    final gueltigV2 = payload.length > payloadLaenge &&
        payload[0] == lizenzFormatVersionMitPasswort;
    if (!gueltigV1 && !gueltigV2) {
      throw ArgumentError('Payload hat ein unbekanntes Format.');
    }
    if (signatur.length != signaturLaenge) {
      throw ArgumentError('Signatur muss $signaturLaenge Bytes lang sein.');
    }
  }

  Uint8List get firmenIdHash => payload.sublist(1, payloadLaenge);

  String get firmenIdHashHex =>
      firmenIdHash.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  /// Der im Version-2-Payload eingebettete Entwickler-Passwort-Hash
  /// (bcrypt-String), sonst null.
  String? get entwicklerPasswortHash {
    if (payload[0] != lizenzFormatVersionMitPasswort) return null;
    try {
      return utf8.decode(payload.sublist(payloadLaenge));
    } on FormatException {
      return null;
    }
  }
}

/// Signiert einen Payload mit dem privaten Schluessel. Wird NUR vom
/// Generator-Tool verwendet (dort liegt der private Schluessel).
Future<Uint8List> signierePayload(
    Uint8List payload, SimpleKeyPair privaterSchluessel) async {
  final algorithm = Ed25519();
  final signatur = await algorithm.sign(payload, keyPair: privaterSchluessel);
  return Uint8List.fromList(signatur.bytes);
}

/// Ergebnis von [erzeugeLizenz]: alles, was Generator-Werkzeuge (CLI/GUI)
/// fuer die Ausgabe brauchen.
class ErzeugteLizenz {
  final SignierteLizenz lizenz;

  /// Freischaltcode zum Eintippen in der App.
  final String freischaltcode;

  /// JSON-Inhalt der signierten Lizenzdatei.
  final String dateiJson;

  /// Vorgeschlagener Dateiname (z. B. muster_gmbh.zeitexalizenz.json).
  final String dateiName;

  ErzeugteLizenz({
    required this.lizenz,
    required this.freischaltcode,
    required this.dateiJson,
    required this.dateiName,
  });
}

/// Erzeugt eine vollstaendige Lizenz fuer [firmenname]: Payload bauen,
/// mit dem privaten Schluessel (Ed25519-Seed, 32 Bytes) signieren und
/// Freischaltcode + Lizenzdatei-JSON ableiten.
///
/// Mit [entwicklerPasswortHash] (bcrypt-String) wird der Hash zusaetzlich
/// in die LIZENZDATEI eingebettet (Version-2-Payload, mitsigniert) - der
/// Freischaltcode bleibt davon unberuehrt (kompakter Version-1-Payload).
///
/// Wird NUR von den Generator-Werkzeugen verwendet (dort liegt der
/// private Schluessel) - die App selbst prueft nur mit [pruefeLizenz].
Future<ErzeugteLizenz> erzeugeLizenz(
    List<int> privaterSchluesselSeed, String firmenname,
    {String? entwicklerPasswortHash}) async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(privaterSchluesselSeed);

  final payload = await erstellePayload(firmenname);
  final signatur = await signierePayload(payload, keyPair);
  final lizenz = SignierteLizenz(payload: payload, signatur: signatur);

  // Die Datei traegt - falls angegeben - den Entwickler-Passwort-Hash im
  // mitsignierten Version-2-Payload.
  var dateiLizenz = lizenz;
  if (entwicklerPasswortHash != null && entwicklerPasswortHash.isNotEmpty) {
    final dateiPayload =
        await erstellePayloadMitPasswort(firmenname, entwicklerPasswortHash);
    dateiLizenz = SignierteLizenz(
      payload: dateiPayload,
      signatur: await signierePayload(dateiPayload, keyPair),
    );
  }

  return ErzeugteLizenz(
    lizenz: lizenz,
    freischaltcode: formatiereFreischaltcode(lizenz),
    dateiJson: erstelleLizenzdateiJson(dateiLizenz, firmenname),
    dateiName: lizenzDateiName(firmenname),
  );
}

/// Vorgeschlagener Dateiname fuer die Lizenzdatei einer Firma
/// (kleingeschrieben, Sonderzeichen durch Unterstriche ersetzt).
String lizenzDateiName(String firmenname) {
  final normal = firmenname
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return '$normal.zeitexalizenz.json';
}

/// Prueft, ob [lizenz] mit [oeffentlicherSchluessel] gueltig signiert ist
/// UND zum angegebenen [firmenname] passt (Firmenbindung).
Future<bool> pruefeLizenz(
  SignierteLizenz lizenz,
  String firmenname,
  List<int> oeffentlicherSchluessel,
) async {
  final algorithm = Ed25519();
  final publicKey =
      SimplePublicKey(oeffentlicherSchluessel, type: KeyPairType.ed25519);
  final gueltigeSignatur = await algorithm.verify(
    lizenz.payload,
    signature: Signature(lizenz.signatur, publicKey: publicKey),
  );
  if (!gueltigeSignatur) return false;

  // Firmenbindung: Version-Byte kennen wir (sonst haette der
  // SignierteLizenz-Konstruktor abgelehnt), verglichen wird der
  // Firmen-Hash - fuer Version 1 und 2 identisch aufgebaut.
  final erwarteterHash = await berechneFirmenIdHash(firmenname);
  final tatsaechlicherHash = lizenz.firmenIdHash;
  if (erwarteterHash.length != tatsaechlicherHash.length) return false;
  for (var i = 0; i < erwarteterHash.length; i++) {
    if (erwarteterHash[i] != tatsaechlicherHash[i]) return false;
  }
  return true;
}

// ---------- Freischaltcode (Base32, RFC 4648, ohne Padding) ----------

const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

String _base32Encode(List<int> bytes) {
  final output = StringBuffer();
  var bitBuffer = 0;
  var bitCount = 0;
  for (final byte in bytes) {
    bitBuffer = (bitBuffer << 8) | byte;
    bitCount += 8;
    while (bitCount >= 5) {
      bitCount -= 5;
      output.write(_base32Alphabet[(bitBuffer >> bitCount) & 0x1F]);
    }
  }
  if (bitCount > 0) {
    output.write(_base32Alphabet[(bitBuffer << (5 - bitCount)) & 0x1F]);
  }
  return output.toString();
}

Uint8List _base32Decode(String input) {
  final output = <int>[];
  var bitBuffer = 0;
  var bitCount = 0;
  for (final rune in input.runes) {
    final zeichen = String.fromCharCode(rune);
    final index = _base32Alphabet.indexOf(zeichen);
    if (index == -1) {
      throw FormatException('Ungueltiges Zeichen im Freischaltcode: $zeichen');
    }
    bitBuffer = (bitBuffer << 5) | index;
    bitCount += 5;
    if (bitCount >= 8) {
      bitCount -= 8;
      output.add((bitBuffer >> bitCount) & 0xFF);
    }
  }
  return Uint8List.fromList(output);
}

/// Formatiert Payload + Signatur als kompakten, in 5er-Gruppen
/// gegliederten Freischaltcode (Base32, Grossbuchstaben, mit Bindestrichen).
/// Nur fuer Version-1-Payloads - der Passwort-Hash gehoert nicht in den
/// Abtipp-Code.
String formatiereFreischaltcode(SignierteLizenz lizenz) {
  if (lizenz.payload.length != payloadLaenge) {
    throw ArgumentError(
        'Freischaltcodes werden nur aus Version-1-Payloads erzeugt.');
  }
  final bytes = [...lizenz.payload, ...lizenz.signatur];
  final roh = _base32Encode(bytes);
  final gruppen = <String>[];
  for (var i = 0; i < roh.length; i += 5) {
    gruppen.add(roh.substring(i, i + 5 > roh.length ? roh.length : i + 5));
  }
  return gruppen.join('-');
}

/// Parst einen vom Nutzer eingegebenen Freischaltcode (tolerant gegenueber
/// Leerzeichen, Bindestrichen, Zeilenumbruechen und Gross-/Kleinschreibung).
/// Wirft [FormatException], wenn der Code nicht das erwartete Format hat.
SignierteLizenz parseFreischaltcode(String eingabe) {
  final bereinigt =
      eingabe.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
  final bytes = _base32Decode(bereinigt);
  if (bytes.length != payloadLaenge + signaturLaenge) {
    throw FormatException(
        'Freischaltcode hat die falsche Laenge (${bytes.length} Bytes).');
  }
  return SignierteLizenz(
    payload: Uint8List.fromList(bytes.sublist(0, payloadLaenge)),
    signatur: Uint8List.fromList(bytes.sublist(payloadLaenge)),
  );
}

// ---------- Signierte Lizenzdatei (JSON, fuer Export/Import) ----------

/// Erstellt den JSON-Inhalt einer exportierbaren Lizenzdatei.
///
/// [firmenname] wird nur zur Anzeige mitgespeichert (nicht mitsigniert) -
/// massgeblich fuer die Pruefung ist ausschliesslich der Firmen-Hash im
/// signierten Payload, verglichen mit dem in der App eingegebenen Namen.
String erstelleLizenzdateiJson(SignierteLizenz lizenz, String firmenname) {
  final map = {
    'formatVersion': lizenz.payload[0],
    'payloadBase64': base64.encode(lizenz.payload),
    'signaturBase64': base64.encode(lizenz.signatur),
    'firmenname': firmenname,
    'firmenIdHashHex': lizenz.firmenIdHashHex,
    'erzeugtAm': DateTime.now().toIso8601String(),
  };
  return const JsonEncoder.withIndent('  ').convert(map);
}

/// Liest eine signierte Lizenzdatei (siehe [erstelleLizenzdateiJson]) ein.
/// Wirft [FormatException] bei ungueltigem Format.
SignierteLizenz parseLizenzdateiJson(String json) {
  final map = jsonDecode(json);
  if (map is! Map || map['payloadBase64'] is! String || map['signaturBase64'] is! String) {
    throw const FormatException('Ungueltige Lizenzdatei.');
  }
  final payload = base64.decode(map['payloadBase64'] as String);
  final signatur = base64.decode(map['signaturBase64'] as String);
  return SignierteLizenz(
    payload: Uint8List.fromList(payload),
    signatur: Uint8List.fromList(signatur),
  );
}
