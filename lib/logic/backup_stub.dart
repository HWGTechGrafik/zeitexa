import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

/// Web-Variante: kein Zugriff auf die Datenbankdatei selbst (die liegt
/// hinter dem Drift-Worker im Browser-Speicher). Deshalb lassen sich hier
/// keine alten SQLite-Sicherungen einspielen — die JSON-Vollsicherung
/// (Erstellen UND Wiederherstellen) funktioniert dagegen uneingeschränkt.
const datenbankDateiZugriff = false;

/// Gibt die Sicherung über den Teilen-Dialog weiter (iPhone/Android-
/// Browser: „In Dateien sichern", Mail, AirDrop, …) — wie beim
/// Monatsversand. Browser ohne Teilen-Dialog (z.B. Firefox am PC) laden
/// die Datei stattdessen direkt herunter (share_plus-Download-Fallback).
Future<String?> speichereSicherung(String dateiname, Uint8List bytes) async {
  final ergebnis = await SharePlus.instance.share(ShareParams(
    files: [
      XFile.fromData(bytes, name: dateiname, mimeType: 'application/json'),
    ],
    fileNameOverrides: [dateiname],
    subject: 'Zeitexa Datensicherung',
    text: 'Zeitexa-Datensicherung – auf dem neuen Gerät unter '
        'Verwaltung → Optionen → „Sicherung wiederherstellen" einspielen.',
  ));
  return ergebnis.status == ShareResultStatus.dismissed ? null : dateiname;
}

/// „Speichern unter" für beliebige einzelne Dateien: löst im Browser einen
/// Download mit dem gegebenen Dateinamen aus.
Future<String?> speichereDatei(String dialogTitel, String dateiname,
        List<String> endungen, Uint8List bytes) =>
    FilePicker.platform.saveFile(
      dialogTitle: dialogTitel,
      fileName: dateiname,
      type: FileType.custom,
      allowedExtensions: endungen,
      bytes: bytes,
    );

/// Nur für das alte SQLite-Sicherungsformat relevant; durch
/// [datenbankDateiZugriff] = false wird das hier nie aufgerufen.
Future<void> ersetzeDatenbank(Uint8List bytes) async =>
    throw UnsupportedError(
        'SQLite-Sicherungen lassen sich im Browser nicht einspielen.');
