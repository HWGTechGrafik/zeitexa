import 'dart:typed_data';

/// Web-Variante: SMTP und lokales Speichern sind im Browser nicht möglich.
const smtpVerfuegbar = false;

Future<void> sendeSmtpMail({
  required String host,
  required int port,
  required bool ssl,
  required String benutzer,
  required String passwort,
  required String ziel,
  required String betreff,
  required String text,
  required List<(String, Uint8List)> anhaenge,
}) async {
  throw StateError('SMTP-Versand ist im Browser nicht möglich – '
      'bitte „Per Mail-App teilen" verwenden.');
}

Future<List<String>> speichereDateien(
        String basisname, List<(String, Uint8List)> dateien) async =>
    [];
