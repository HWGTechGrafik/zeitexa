import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/database.dart';
import '../logic/berechnung.dart';
import '../ui/auswertung_view.dart' show MonatsAuswertung;

/// Gesamtauswertung als Excel: eine Zeile pro Mitarbeiter und Monat.
Uint8List auswertungExcel(
    Branding branding, List<MonatsAuswertung> auswertungen) {
  final excel = Excel.createExcel();
  final sheet = excel['Auswertung'];
  excel.setDefaultSheet('Auswertung');
  excel.delete('Sheet1');

  sheet.appendRow([TextCellValue(branding.firmenname)]);
  sheet.appendRow([TextCellValue('Zeitexa Gesamtauswertung')]);
  sheet.appendRow([TextCellValue('')]);
  sheet.appendRow([
    for (final kopf in [
      'Mitarbeiter', 'Monat', 'Ist (h)', 'Soll (h)', 'Überstunden (h)',
      'Arbeitstage', 'Urlaub', 'Sonderurlaub', 'Firmenurlaub', 'Krank',
      'Zeitausgleich', 'Feiertage'
    ])
      TextCellValue(kopf)
  ]);
  for (final a in auswertungen) {
    sheet.appendRow([
      TextCellValue(a.anzeigename),
      TextCellValue(a.monat),
      DoubleCellValue(_r2(a.ist)),
      DoubleCellValue(_r2(a.soll)),
      DoubleCellValue(_r2(a.ueberstunden)),
      IntCellValue(a.arbeitstage),
      // Urlaubsarten anteilig: ein halber Tag ist 0,5.
      DoubleCellValue(_r2(a.urlaub)),
      DoubleCellValue(_r2(a.sonderurlaub)),
      DoubleCellValue(_r2(a.firmenurlaub)),
      IntCellValue(a.krank),
      IntCellValue(a.zeitausgleich),
      IntCellValue(a.feiertage),
    ]);
  }
  return Uint8List.fromList(excel.encode()!);
}

/// Gesamtauswertung als PDF.
Future<Uint8List> auswertungPdf(
    Branding branding, List<MonatsAuswertung> auswertungen) async {
  final akzent = PdfColor.fromInt(branding.akzentFarbe);
  final doc = pw.Document();
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    build: (ctx) => [
      pw.Text(branding.firmenname,
          style: pw.TextStyle(
              fontSize: 16, fontWeight: pw.FontWeight.bold, color: akzent)),
      pw.Text('Zeitexa Gesamtauswertung',
          style: const pw.TextStyle(fontSize: 11)),
      pw.SizedBox(height: 10),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(
            fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: pw.BoxDecoration(color: akzent),
        cellStyle: const pw.TextStyle(fontSize: 8),
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
        headers: [
          'Mitarbeiter', 'Monat', 'Ist', 'Soll', '±', 'AT', 'Url', 'SU', 'FU',
          'Kr', 'ZA', 'FT'
        ],
        data: [
          for (final a in auswertungen)
            [
              a.anzeigename,
              a.monat,
              formatStunden(a.ist),
              formatStunden(a.soll),
              formatStunden(a.ueberstunden, vorzeichen: true),
              '${a.arbeitstage}',
              formatStunden(a.urlaub),
              formatStunden(a.sonderurlaub),
              formatStunden(a.firmenurlaub),
              '${a.krank}',
              '${a.zeitausgleich}',
              '${a.feiertage}',
            ],
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Text(
          'AT = Arbeitstage · Url = Urlaub · SU = Sonderurlaub · '
          'FU = Firmenurlaub · Kr = Krank · ZA = Zeitausgleich · FT = Feiertage',
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey)),
    ],
  ));
  return doc.save();
}

double _r2(double v) => (v * 100).roundToDouble() / 100;
