import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/database.dart';
import '../logic/berechnung.dart';
import 'monats_daten.dart';

/// Druckfertiger A4-Monatsbericht mit Branding-Kopf, Tabelle, Summen
/// und Unterschriftszeile.
Future<Uint8List> pdfExport({
  required Branding branding,
  required String anzeigename,
  required int jahr,
  required int monat,
  required List<MonatsZeile> zeilen,
  required MonatsSumme summe,
}) async {
  final akzent = PdfColor.fromInt(branding.akzentFarbe);
  final doc = pw.Document();

  final logoBytes = branding.logo;
  final pw.Widget? logo = (logoBytes == null || logoBytes.isEmpty)
      ? null
      : pw.Image(pw.MemoryImage(logoBytes), height: 40);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 48),
    footer: (ctx) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('Seite ${ctx.pageNumber}/${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
    ),
    build: (ctx) => [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(branding.firmenname,
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold, color: akzent)),
            if (branding.adresse.isNotEmpty)
              pw.Text(branding.adresse, style: const pw.TextStyle(fontSize: 9)),
            if (branding.telefon.isNotEmpty || branding.email.isNotEmpty)
              pw.Text(
                  [branding.telefon, branding.email]
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  style: const pw.TextStyle(fontSize: 9)),
          ]),
          ?logo,
        ],
      ),
      pw.SizedBox(height: 12),
      pw.Text('Stundenaufzeichnung – ${monatsTitel(jahr, monat)}',
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
      pw.Text('Mitarbeiter: $anzeigename',
          style: const pw.TextStyle(fontSize: 10)),
      pw.SizedBox(height: 8),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(
            fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: pw.BoxDecoration(color: akzent),
        cellStyle: const pw.TextStyle(fontSize: 8),
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
        headers: [
          'Tag', 'Art', 'Ort', 'Beginn', 'Pause', 'Ende', 'Ist', 'Soll', '±', 'Notiz'
        ],
        data: [
          for (final z in zeilen)
            [
              z.tagLabel,
              z.eintrag == null
                  ? (z.feiertagsname ?? '')
                  : (tagesartLabel[z.eintrag!.tagesart] ?? ''),
              z.ort,
              z.eintrag?.tagesart == Tagesart.arbeit
                  ? formatUhrzeit(z.eintrag?.beginnMin)
                  : '',
              z.eintrag?.tagesart == Tagesart.arbeit && z.eintrag!.pauseMin > 0
                  ? '${z.eintrag!.pauseMin} min'
                  : '',
              z.eintrag?.tagesart == Tagesart.arbeit
                  ? formatUhrzeit(z.eintrag?.endeMin)
                  : '',
              z.ergebnis == null ? '' : formatStunden(z.ergebnis!.ist),
              z.ergebnis == null ? '' : formatStunden(z.ergebnis!.soll),
              z.ergebnis == null
                  ? ''
                  : formatStunden(z.ergebnis!.ueberstunden, vorzeichen: true),
              z.eintrag?.notiz ?? '',
            ],
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: akzent), borderRadius: pw.BorderRadius.circular(4)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(
              'Summe Ist: ${formatStunden(summe.summeIst)} h   ·   '
              'Summe Soll: ${formatStunden(summe.summeSoll)} h   ·   '
              'Überstunden: ${formatStunden(summe.ueberstunden, vorzeichen: true)} h',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.Text(tageZusammenfassung(summe),
              style: const pw.TextStyle(fontSize: 9)),
        ]),
      ),
      pw.SizedBox(height: 36),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Column(children: [
          pw.Container(width: 180, height: 1, color: PdfColors.grey700),
          pw.Text('Datum, Unterschrift Mitarbeiter',
              style: const pw.TextStyle(fontSize: 8)),
        ]),
        pw.Column(children: [
          pw.Container(width: 180, height: 1, color: PdfColors.grey700),
          pw.Text('Datum, Unterschrift Firma',
              style: const pw.TextStyle(fontSize: 8)),
        ]),
      ]),
    ],
  ));

  return doc.save();
}
