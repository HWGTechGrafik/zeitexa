import 'dart:typed_data';

/// Web-Variante: kein Dateisystem-Zugriff auf die Datenbankdatei,
/// Backup/Restore stehen dort nicht zur Verfügung.
const backupVerfuegbar = false;

Never _nichtVerfuegbar() => throw UnsupportedError(
    'Datensicherung ist auf diesem Gerät nicht verfügbar.');

Future<String> tempSicherungsPfad() async => _nichtVerfuegbar();

Future<void> loescheFallsVorhanden(String pfad) async => _nichtVerfuegbar();

Future<Uint8List> liesUndLoesche(String pfad) async => _nichtVerfuegbar();

Future<String?> speichereSicherung(String dateiname, Uint8List bytes) async =>
    _nichtVerfuegbar();

Future<String?> speichereDatei(String dialogTitel, String dateiname,
        List<String> endungen, Uint8List bytes) async =>
    _nichtVerfuegbar();

Future<void> ersetzeDatenbank(Uint8List bytes) async => _nichtVerfuegbar();
