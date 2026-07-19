import 'dart:convert';

import 'package:file_picker/file_picker.dart';

/// Öffnet die Dateiauswahl für eine Zeitexa-Benutzerdatei und liefert deren
/// JSON-Inhalt; null bei Abbruch oder wenn die Datei nicht lesbar war.
///
/// Wird an zwei Stellen gebraucht: im Chef-Bereich (Benutzer nachträglich
/// einspielen) und beim Einrichten eines neuen Geräts im Setup-Screen.
Future<String?> waehleBenutzerdatei() async {
  final ergebnis = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
    withData: true,
  );
  final bytes = ergebnis?.files.firstOrNull?.bytes;
  return bytes == null ? null : utf8.decode(bytes);
}
