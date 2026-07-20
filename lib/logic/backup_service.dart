import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../data/database.dart';
import 'backup_json.dart';
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

/// Format einer ausgewählten Sicherungsdatei.
enum SicherungsFormat {
  /// Altes Format (bis v1.2): Kopie der SQLite-Datenbankdatei. Wird nicht
  /// mehr erstellt, bleibt aber auf Windows/Android einspielbar.
  sqlite,

  /// Aktuelles Format: JSON-Vollsicherung, auf allen Geräten nutzbar
  /// (siehe lib/logic/backup_json.dart).
  json,
}

/// Erkennt das Format anhand der ersten Bytes; null = keine Sicherung.
SicherungsFormat? erkenneSicherungsFormat(Uint8List bytes) {
  if (istSqliteDatei(bytes)) return SicherungsFormat.sqlite;
  // JSON darf mit UTF-8-BOM und Leerraum beginnen.
  var i = 0;
  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    i = 3;
  }
  while (i < bytes.length &&
      (bytes[i] == 0x20 ||
          bytes[i] == 0x09 ||
          bytes[i] == 0x0A ||
          bytes[i] == 0x0D)) {
    i++;
  }
  if (i < bytes.length && bytes[i] == 0x7B /* '{' */) {
    return SicherungsFormat.json;
  }
  return null;
}

/// Dateiname einer Sicherung mit Datumsstempel, z.B.
/// „Zeitexa_Sicherung_2026-07-20.zeitexadb" – auch für den optionalen
/// Sicherungs-Anhang der Monats-Mail (lib/export/export_service.dart).
String sicherungsDateiname([DateTime? datum]) {
  final d = datum ?? DateTime.now();
  return 'Zeitexa_Sicherung_${d.year}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}.zeitexadb';
}

/// Komplettsicherung aller Daten (Profil, Einträge, Einstellungen, Lizenz)
/// als eine Datei — zum Übertragen auf ein anderes Gerät oder als
/// Datensicherung. Seit v1.3 im JSON-Format, das auf ALLEN Plattformen
/// (auch in der Web-App) erstellt und eingespielt werden kann; alte
/// SQLite-Sicherungen bleiben auf Windows/Android einspielbar.
class BackupService {
  final ZeitexaDb db;
  BackupService(this.db);

  /// Erstellt eine Sicherungsdatei am vom Nutzer gewählten Ort (auf Web
  /// über den Teilen-Dialog bzw. als Browser-Download).
  /// Liefert Zielpfad/Dateiname oder null, wenn abgebrochen wurde.
  Future<String?> sichern() async {
    final bytes = await erzeugeJsonSicherung(db);
    return plattform.speichereSicherung(sicherungsDateiname(), bytes);
  }

  /// Lässt den Nutzer eine Sicherungsdatei auswählen.
  /// Liefert deren Inhalt oder null, wenn der Dialog abgebrochen wurde.
  Future<Uint8List?> waehleSicherung() async {
    final ergebnis = await FilePicker.platform.pickFiles(
      // Im Browser (v.a. iPhone) macht ein Endungsfilter Dateien mit
      // unbekannter Endung mitunter gar nicht erst auswählbar – dort
      // deshalb ohne Filter.
      type: kIsWeb ? FileType.any : FileType.custom,
      allowedExtensions: kIsWeb ? null : ['zeitexadb', 'sqlite'],
      withData: true,
    );
    return ergebnis?.files.firstOrNull?.bytes;
  }

  /// Ersetzt alle Daten durch die Sicherung. Schließt dabei die
  /// Datenbank — der Aufrufer muss danach alle Provider neu aufbauen
  /// (dbProvider invalidieren) bzw. zum StartGate zurückkehren.
  Future<void> wiederherstellen(Uint8List bytes) async {
    switch (erkenneSicherungsFormat(bytes)) {
      case SicherungsFormat.json:
        await spieleJsonSicherungEin(db, bytes);
        await db.close();
      case SicherungsFormat.sqlite:
        if (!plattform.datenbankDateiZugriff) {
          throw const FormatException(
              'Diese Sicherung stammt von einer älteren Windows- oder '
              'Android-Version und lässt sich im Browser nicht einspielen. '
              'Bitte dort die App aktualisieren und eine neue Sicherung '
              'erstellen – die funktioniert dann auf allen Geräten.');
        }
        if (!istZeitexaSicherung(bytes)) {
          throw const FormatException(
              'Diese Datei stammt nicht aus Zeitexa (z.B. aus der '
              'Firmenversion Zeitrax) und kann hier nicht eingespielt '
              'werden.');
        }
        await db.close();
        await plattform.ersetzeDatenbank(bytes);
      case null:
        throw const FormatException(
            'Das ist keine gültige Zeitexa-Sicherungsdatei.');
    }
  }
}
