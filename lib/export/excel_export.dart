import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../data/database.dart';
import '../logic/berechnung.dart';
import 'monats_daten.dart';

/// Erzeugt die Excel-Monatsübersicht (ein Tabellenblatt, Spalten wie in
/// der Monatsansicht, Summenzeile am Ende, Briefkopf mit dem Lizenznamen).
/// Wie beim PDF steht der Name nur einmal im Kopf – eine separate
/// „Mitarbeiter"-Angabe gibt es in der Einzelnutzer-Version nicht.
Uint8List excelExport({
  required Branding branding,
  required int jahr,
  required int monat,
  required List<MonatsZeile> zeilen,
  required MonatsSumme summe,
}) {
  final excel = Excel.createExcel();
  final sheet = excel['Stunden'];
  excel.setDefaultSheet('Stunden');
  excel.delete('Sheet1');

  final kopfStil = CellStyle(bold: true);
  void kopfzeile(List<String> werte) {
    sheet.appendRow([for (final w in werte) TextCellValue(w)]);
    final zeile = sheet.maxRows - 1;
    for (var c = 0; c < werte.length; c++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: zeile))
          .cellStyle = kopfStil;
    }
  }

  kopfzeile([branding.firmenname]);
  if (branding.adresse.isNotEmpty) sheet.appendRow([TextCellValue(branding.adresse)]);
  sheet.appendRow([
    TextCellValue('Stundenaufzeichnung – ${monatsTitel(jahr, monat)}')
  ]);
  sheet.appendRow([TextCellValue('')]);
  kopfzeile([
    'Tag', 'Art', 'Ort', 'Beginn', 'Pause (min)', 'Ende',
    'Ist (h)', 'Soll (h)', 'Überstunden (h)', 'Notiz',
  ]);

  for (final z in zeilen) {
    final e = z.eintrag;
    final erg = z.ergebnis;
    sheet.appendRow([
      TextCellValue(z.tagLabel),
      TextCellValue(e == null
          ? (z.feiertagsname ?? '')
          : (tagesartLabel[e.tagesart] ?? '')),
      TextCellValue(z.ort),
      TextCellValue(e?.tagesart == Tagesart.arbeit
          ? formatUhrzeit(e?.beginnMin)
          : ''),
      if (e != null && e.tagesart == Tagesart.arbeit)
        IntCellValue(e.pauseMin)
      else
        TextCellValue(''),
      TextCellValue(
          e?.tagesart == Tagesart.arbeit ? formatUhrzeit(e?.endeMin) : ''),
      if (erg != null) DoubleCellValue(_r2(erg.ist)) else TextCellValue(''),
      if (erg != null) DoubleCellValue(_r2(erg.soll)) else TextCellValue(''),
      if (erg != null)
        DoubleCellValue(_r2(erg.ueberstunden))
      else
        TextCellValue(''),
      TextCellValue(e?.notiz ?? ''),
    ]);
  }

  sheet.appendRow([TextCellValue('')]);
  kopfzeile(['Summe', '', '', '', '', '',
    formatStunden(summe.summeIst),
    formatStunden(summe.summeSoll),
    formatStunden(summe.ueberstunden, vorzeichen: true), '']);
  sheet.appendRow([TextCellValue(tageZusammenfassung(summe))]);

  return Uint8List.fromList(excel.encode()!);
}

double _r2(double v) => (v * 100).roundToDouble() / 100;
