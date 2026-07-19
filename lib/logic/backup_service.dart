import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../data/database.dart';
import 'backup_stub.dart' if (dart.library.io) 'backup_io.dart' as plattform;

/// Prüft den SQLite-Magic-Header ("SQLite format 3\0", 16 Bytes).
bool istSqliteDatei(Uint8List bytes) {
  const magic = 'SQLite format 3';
  if (bytes.length < 16) return false;
  for (var i = 0; i < magic.length; i++) {
    if (bytes[i] != magic.codeUnitAt(i)) return false;
  }
  return bytes[15] == 0;
}

/// Steckt die Zeitexa-Produktkennung in der Datei? SQLite legt Textwerte
/// unverschluesselt ab, der Marker ist also direkt in den Bytes zu finden.
/// Damit fliegt eine Sicherung der Firmenversion Zeitrax auf, bevor sie
/// eingespielt wird - sonst saesse hier eine Datenbank mit fremden
/// Mitarbeitern in einer App ohne Benutzerauswahl.
bool istZeitexaSicherung(Uint8List bytes) {
  final marker = kProduktKennung.codeUnits;
  final grenze = bytes.length - marker.length;
  for (var start = 0; start <= grenze; start++) {
    var passt = true;
    for (var i = 0; i < marker.length; i++) {
      if (bytes[start + i] != marker[i]) {
        passt = false;
        break;
      }
    }
    if (passt) return true;
  }
  return false;
}

/// Komplettsicherung der Datenbank (Benutzer, Passwörter, Einträge,
/// Branding, Lizenz) als eine Datei — zum Übertragen auf einen anderen
/// PC oder als Datensicherung. Auf Web nicht verfügbar.
class BackupService {
  final ZeitexaDb db;
  BackupService(this.db);

  bool get verfuegbar => plattform.backupVerfuegbar;

  /// Konsistenter Snapshot der kompletten Datenbank als Bytes
  /// (VACUUM INTO eine Temp-Datei, auch bei geöffneter App sicher).
  Future<Uint8List> _snapshot() async {
    final tempPfad = await plattform.tempSicherungsPfad();
    // VACUUM INTO schlägt fehl, wenn die Zieldatei schon existiert.
    await plattform.loescheFallsVorhanden(tempPfad);
    await db.customStatement('VACUUM INTO ?', [tempPfad]);
    return plattform.liesUndLoesche(tempPfad);
  }

  /// Erstellt eine Sicherungsdatei am vom Nutzer gewählten Ort.
  /// Liefert den Zielpfad oder null, wenn der Dialog abgebrochen wurde.
  Future<String?> sichern() async {
    final heute = DateTime.now();
    final datum = '${heute.year}-'
        '${heute.month.toString().padLeft(2, '0')}-'
        '${heute.day.toString().padLeft(2, '0')}';
    final bytes = await _snapshot();
    return plattform.speichereSicherung(
        'Zeitexa_Sicherung_$datum.zeitexadb', bytes);
  }

  /// Lässt den Nutzer eine Sicherungsdatei auswählen.
  /// Liefert deren Inhalt oder null, wenn der Dialog abgebrochen wurde.
  Future<Uint8List?> waehleSicherung() async {
    final ergebnis = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zeitexadb', 'sqlite'],
      withData: true,
    );
    return ergebnis?.files.firstOrNull?.bytes;
  }

  /// Ersetzt die Datenbank durch die Sicherung. Schließt dabei die
  /// Datenbank — der Aufrufer muss danach alle Provider neu aufbauen
  /// (dbProvider invalidieren) bzw. zum StartGate zurückkehren.
  Future<void> wiederherstellen(Uint8List bytes) async {
    if (!istSqliteDatei(bytes)) {
      throw const FormatException(
          'Das ist keine gültige Zeitexa-Sicherungsdatei.');
    }
    if (!istZeitexaSicherung(bytes)) {
      throw const FormatException(
          'Diese Datei stammt nicht aus Zeitexa (z.B. aus der '
          'Firmenversion Zeitrax) und kann hier nicht eingespielt werden.');
    }
    await db.close();
    await plattform.ersetzeDatenbank(bytes);
  }
}
