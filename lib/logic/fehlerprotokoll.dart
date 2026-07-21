import 'package:flutter/foundation.dart';

import 'fehlerprotokoll_stub.dart'
    if (dart.library.io) 'fehlerprotokoll_io.dart' as plattform;

/// Stilles Fehlerprotokoll: fängt nicht behandelte Ausnahmen ab und schreibt
/// sie (auf Windows/Android/iOS) in eine Datei im App-Datenordner. Die
/// Oberfläche bleibt unverändert – tritt der bekannte „weiße Bildschirm"
/// erneut auf, lässt sich die Ursache aus dieser Datei nachvollziehen,
/// statt sie zu raten.
///
/// Bewusst KEIN Fehlerbildschirm/„Neu laden": nach Rücksprache soll die App
/// nach außen unverändert fertig wirken.
void installiereFehlerprotokoll() {
  final vorher = FlutterError.onError;
  FlutterError.onError = (details) {
    vorher?.call(details);
    _protokolliere(details.exceptionAsString(), details.stack);
  };
  PlatformDispatcher.instance.onError = (fehler, stack) {
    _protokolliere(fehler.toString(), stack);
    return false; // Standardverhalten (Konsole) NICHT unterdrücken.
  };
}

void _protokolliere(String meldung, StackTrace? stack) {
  final zeit = DateTime.now().toIso8601String();
  final text = '[$zeit] $meldung${stack == null ? '' : '\n$stack'}';
  // Feuer und vergessen – ein fehlgeschlagenes Protokoll darf nie stören.
  plattform.schreibeFehler(text);
}

/// Pfad der Protokolldatei (für den Hinweis in der Verwaltung), oder null.
Future<String?> fehlerprotokollPfad() => plattform.fehlerprotokollPfad();
