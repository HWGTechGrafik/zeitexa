import '../data/database.dart';
import '../logic/berechnung.dart';
import '../logic/feiertage.dart';

const wochentagKurz = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

/// Wandelt die DB-Blockzeilen (gruppiert nach Tageskopf-Id) in die reinen
/// [TagBlock]e der Rechenlogik um.
Map<int, List<TagBlock>> tagBloeckeAus(Map<int, List<Zeitblock>> rohBloecke) => {
      for (final e in rohBloecke.entries)
        e.key: [
          for (final b in e.value)
            TagBlock(
                beginnMin: b.beginnMin, endeMin: b.endeMin, pauseMin: b.pauseMin)
        ],
    };

const tagesartLabel = {
  Tagesart.arbeit: 'Arbeit',
  Tagesart.urlaub: 'Urlaub',
  Tagesart.krank: 'Krank',
  Tagesart.feiertag: 'Feiertag',
  Tagesart.zeitausgleich: 'Zeitausgleich',
  Tagesart.frei: 'Frei',
  Tagesart.sonderurlaub: 'Sonderurlaub',
  Tagesart.firmenurlaub: 'Firmenurlaub',
};

/// Beschriftung der Sonderurlaubs-Anlässe (Auswahl im Eintragsdialog,
/// Anzeige in Monatsliste und Exporten).
const sonderurlaubGrundLabel = {
  SonderurlaubGrund.pflegefreistellung: 'Pflegefreistellung',
  SonderurlaubGrund.umzug: 'Umzug',
  SonderurlaubGrund.hochzeit: 'Hochzeit',
  SonderurlaubGrund.geburt: 'Geburt',
  SonderurlaubGrund.todesfall: 'Todesfall',
  SonderurlaubGrund.sonstiges: 'Sonstiges',
};

/// Tage-Zusammenfassung eines Monats als eine Zeile – gemeinsam genutzt von
/// Excel- und PDF-Export.
///
/// Urlaubsarten stehen mit Nachkommastelle da (anteilige Tage: ein halber
/// Urlaubstag ist 0,5). Sonder- und Firmenurlaub erscheinen nur, wenn es sie
/// im Monat tatsächlich gab.
String tageZusammenfassung(MonatsSumme summe) => [
      'Urlaub: ${formatStunden(summe.urlaubsTage)} Tage',
      if (summe.sonderurlaubTage > 0)
        'Sonderurlaub: ${formatStunden(summe.sonderurlaubTage)} Tage',
      if (summe.firmenurlaubTage > 0)
        'Firmenurlaub: ${formatStunden(summe.firmenurlaubTage)} Tage',
      'Krank: ${formatStunden(summe.krankTage)} Tage',
      'Zeitausgleich: ${formatStunden(summe.zeitausgleichTage)} Tage',
      'Feiertage: ${formatStunden(summe.feiertage)}',
    ].join(' · ');

/// Eine aufbereitete Zeile der Monatstabelle (für Anzeige und Exporte).
class MonatsZeile {
  final DateTime datum;
  final String tagLabel; // '01 Mi'
  final TimeEntry? eintrag;
  final String ort;
  final TagErgebnis? ergebnis;
  final String? feiertagsname;

  MonatsZeile({
    required this.datum,
    required this.tagLabel,
    required this.eintrag,
    required this.ort,
    required this.ergebnis,
    required this.feiertagsname,
  });

  bool get istWochenende =>
      datum.weekday == DateTime.saturday || datum.weekday == DateTime.sunday;
}

/// Baut für jeden Kalendertag des Monats eine Zeile.
///
/// [bloecke] bildet Tageskopf-Id → Stempel-Blöcke ab (nur Tage mit ≥2
/// Blöcken). Fehlt ein Tag dort, gilt er als Einzelblock (flache Felder).
List<MonatsZeile> monatsZeilen({
  required int jahr,
  required int monat,
  required List<TimeEntry> eintraege,
  required Map<int, String> ortNamen,
  required SollRegel regel,
  Map<int, List<TagBlock>> bloecke = const {},
}) {
  final proTag = {
    for (final e in eintraege) DateTime(e.datum.year, e.datum.month, e.datum.day).day: e
  };
  final tageImMonat = DateTime(jahr, monat + 1, 0).day;
  return [
    for (var tag = 1; tag <= tageImMonat; tag++)
      _zeile(DateTime(jahr, monat, tag), proTag[tag], ortNamen, regel, bloecke),
  ];
}

MonatsZeile _zeile(DateTime datum, TimeEntry? eintrag,
    Map<int, String> ortNamen, SollRegel regel,
    Map<int, List<TagBlock>> bloecke) {
  TagErgebnis? ergebnis;
  if (eintrag != null) {
    ergebnis = berechneTag(
      TagDaten(
        datum: datum,
        tagesart: eintrag.tagesart,
        beginnMin: eintrag.beginnMin,
        pauseMin: eintrag.pauseMin,
        endeMin: eintrag.endeMin,
        bloecke: bloecke[eintrag.id] ?? const [],
        urlaubMinuten: eintrag.urlaubMinuten,
        halberTag: eintrag.halberTag,
      ),
      regel,
    );
  }
  return MonatsZeile(
    datum: datum,
    tagLabel:
        '${datum.day.toString().padLeft(2, '0')} ${wochentagKurz[datum.weekday - 1]}',
    eintrag: eintrag,
    ort: eintrag?.ortId == null ? '' : (ortNamen[eintrag!.ortId] ?? ''),
    ergebnis: ergebnis,
    feiertagsname: feiertagsName(datum),
  );
}

/// Summen über die erfassten Tage eines Monats.
MonatsSumme monatsSumme(List<TimeEntry> eintraege, SollRegel regel,
        {Map<int, List<TagBlock>> bloecke = const {}}) =>
    summiere([
      for (final e in eintraege)
        TagDaten(
          datum: e.datum,
          tagesart: e.tagesart,
          beginnMin: e.beginnMin,
          pauseMin: e.pauseMin,
          endeMin: e.endeMin,
          bloecke: bloecke[e.id] ?? const [],
          urlaubMinuten: e.urlaubMinuten,
          halberTag: e.halberTag,
        ),
    ], regel);

const monatsNamen = [
  'Jänner', 'Februar', 'März', 'April', 'Mai', 'Juni',
  'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
];

String monatsTitel(int jahr, int monat) => '${monatsNamen[monat - 1]} $jahr';

String monatsKey(int jahr, int monat) =>
    '$jahr-${monat.toString().padLeft(2, '0')}';
