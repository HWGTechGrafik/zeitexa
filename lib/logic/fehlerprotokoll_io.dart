import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Android/Windows/iOS: hängt einen Fehler an die Protokolldatei im
/// App-Datenordner an und hält sie auf die letzten ~200 Zeilen kurz.
Future<void> schreibeFehler(String eintrag) async {
  try {
    final datei = File(await _pfad());
    final alt = await datei.exists() ? await datei.readAsLines() : <String>[];
    final neu = [...alt, ...eintrag.trimRight().split('\n')];
    final gekuerzt =
        neu.length > 200 ? neu.sublist(neu.length - 200) : neu;
    await datei.writeAsString('${gekuerzt.join('\n')}\n');
  } catch (_) {
    // Protokollieren darf die App nie stören – Fehler hier bewusst schlucken.
  }
}

Future<String?> fehlerprotokollPfad() async {
  try {
    return await _pfad();
  } catch (_) {
    return null;
  }
}

Future<String> _pfad() async {
  final ordner = await getApplicationSupportDirectory();
  return '${ordner.path}${Platform.pathSeparator}zeitexa_fehler.log';
}
