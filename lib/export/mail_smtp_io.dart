import 'dart:io';
import 'dart:typed_data';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';

/// Android/Windows/iOS-Variante mit echtem SMTP-Versand.
const smtpVerfuegbar = true;

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
  final server = SmtpServer(host,
      port: port, ssl: ssl, username: benutzer, password: passwort);

  final tmp = await getTemporaryDirectory();
  final attachments = <FileAttachment>[];
  for (final (name, bytes) in anhaenge) {
    final f = File('${tmp.path}/$name');
    await f.writeAsBytes(bytes);
    attachments.add(FileAttachment(f));
  }

  final nachricht = Message()
    ..from = Address(benutzer, 'Zeitexa')
    ..recipients.add(ziel)
    ..subject = betreff
    ..text = text
    ..attachments = attachments;

  await send(nachricht, server);
}

/// Speichert Dateien in Dokumente/Zeitexa-Exporte und liefert die Pfade.
Future<List<String>> speichereDateien(
    String basisname, List<(String, Uint8List)> dateien) async {
  final dir = await getApplicationDocumentsDirectory();
  final ordner = Directory('${dir.path}${Platform.pathSeparator}Zeitexa-Exporte');
  await ordner.create(recursive: true);
  final pfade = <String>[];
  for (final (name, bytes) in dateien) {
    final pfad = '${ordner.path}${Platform.pathSeparator}$name';
    await File(pfad).writeAsBytes(bytes);
    pfade.add(pfad);
  }
  return pfade;
}
