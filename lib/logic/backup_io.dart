import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Android/Windows/iOS-Variante mit echtem Dateisystem-Zugriff — kann
/// deshalb auch alte SQLite-Sicherungen (Kopie der Datenbankdatei)
/// wiederherstellen.
const datenbankDateiZugriff = true;

Future<void> _loescheFallsVorhanden(String pfad) async {
  final f = File(pfad);
  if (await f.exists()) await f.delete();
}

/// „Speichern unter"-Dialog. Auf Android schreibt file_picker die Bytes
/// selbst (Storage Access Framework), auf dem Desktop liefert es nur den
/// Pfad und wir schreiben die Datei.
Future<String?> speichereSicherung(String dateiname, Uint8List bytes) =>
    speichereDatei('Sicherung speichern', dateiname, ['zeitexadb'], bytes);

/// „Speichern unter" für beliebige einzelne Dateien (z.B. die Lizenzdatei
/// aus dem Entwickler-Bereich). Verhalten wie [speichereSicherung].
Future<String?> speichereDatei(String dialogTitel, String dateiname,
    List<String> endungen, Uint8List bytes) async {
  final pfad = await FilePicker.platform.saveFile(
    dialogTitle: dialogTitel,
    fileName: dateiname,
    type: FileType.custom,
    allowedExtensions: endungen,
    bytes: bytes,
  );
  if (pfad == null) return null;
  if (!Platform.isAndroid && !Platform.isIOS) {
    await File(pfad).writeAsBytes(bytes, flush: true);
  }
  return pfad;
}

/// Überschreibt die Datenbankdatei (zeitexa.sqlite in den App-Dokumenten,
/// siehe drift_flutter-Default) mit einer alten SQLite-Sicherung. Die
/// Datenbank muss vorher geschlossen worden sein; WAL-Reste werden mit
/// entfernt.
Future<void> ersetzeDatenbank(Uint8List bytes) async {
  final dir = await getApplicationDocumentsDirectory();
  final basis = '${dir.path}${Platform.pathSeparator}zeitexa.sqlite';
  for (final anhang in ['-wal', '-shm']) {
    await _loescheFallsVorhanden('$basis$anhang');
  }
  await File(basis).writeAsBytes(bytes, flush: true);
}
