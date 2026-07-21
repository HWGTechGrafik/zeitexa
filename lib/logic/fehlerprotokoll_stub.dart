/// Web-Variante: kein Dateisystem. Fehler landen nur in der
/// Browser-Konsole (über den Standard-Handler), es wird keine Datei
/// geschrieben. Siehe lib/logic/fehlerprotokoll.dart.
Future<void> schreibeFehler(String eintrag) async {}

Future<String?> fehlerprotokollPfad() async => null;
