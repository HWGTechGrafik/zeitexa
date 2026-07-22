/// Reine Berechnungslogik für Soll-, Ist- und Überstunden.
///
/// Bewusst ohne Abhängigkeit auf die Datenbank gehalten, damit sie
/// sowohl für lokale Einträge als auch für importierte Daten und in
/// Unit-Tests verwendbar ist.
library;

import '../data/database.dart' show SollModus, Tagesart;

/// Automatische Pausenregel: Ab [schwelleMin] Minuten Anwesenheit
/// (Ende − Beginn) muss die Pause mindestens [mindestMin] Minuten betragen.
/// Eine bereits erfasste (oder aus Blocklücken errechnete) Pause wird nur
/// AUFGEFÜLLT, nie doppelt abgezogen. Standard: aus.
class Pausenregel {
  final bool aktiv;
  final int schwelleMin;
  final int mindestMin;

  const Pausenregel({
    this.aktiv = false,
    this.schwelleMin = 12 * 60,
    this.mindestMin = 60,
  });

  static const aus = Pausenregel();
}

/// Sollstunden-Einstellungen eines Mitarbeiters.
class SollRegel {
  final SollModus modus;
  final double stundenTag;
  final double stundenMoDo;
  final double stundenFr;

  /// Nur im Modus [SollModus.proWochentag]: Sollstunden je Wochentag,
  /// Index 0 = Montag … 6 = Sonntag.
  final List<double> proWochentag;

  /// Automatische Pausenregel; wird in [istStunden] angewandt.
  final Pausenregel pausenregel;

  const SollRegel({
    required this.modus,
    required this.stundenTag,
    required this.stundenMoDo,
    required this.stundenFr,
    this.proWochentag = const [8, 8, 8, 8, 8, 0, 0],
    this.pausenregel = Pausenregel.aus,
  });

  /// Sollstunden für ein Datum. In den alten Modi Sa/So = 0; im Modus
  /// „pro Wochentag" gilt strikt der hinterlegte Tageswert (auch Sa/So).
  double sollFuer(DateTime datum) {
    if (modus == SollModus.proWochentag) {
      return proWochentag[datum.weekday - 1];
    }
    switch (datum.weekday) {
      case DateTime.saturday || DateTime.sunday:
        return 0;
      case DateTime.friday:
        return modus == SollModus.moDoFrGetrennt ? stundenFr : stundenTag;
      default:
        return modus == SollModus.moDoFrGetrennt ? stundenMoDo : stundenTag;
    }
  }
}

/// Ein einzelner Stempel-Block (Beginn/Ende/Pause) in neutraler Form.
class TagBlock {
  final int? beginnMin;
  final int? endeMin;
  final int pauseMin;
  const TagBlock({this.beginnMin, this.endeMin, this.pauseMin = 0});
}

/// Ein Tages-Eintrag in neutraler Form (DB-unabhängig).
class TagDaten {
  final DateTime datum;
  final Tagesart tagesart;
  final int? beginnMin;
  final int pauseMin;
  final int? endeMin;

  /// Stempel-Blöcke des Tages (mehrmaliges An-/Abstempeln). Ist die Liste
  /// leer, gilt der Tag als EIN Block aus [beginnMin]/[endeMin]/[pauseMin].
  /// Bei mehreren Blöcken sind die IST-Stunden die SUMME der Blöcke – die
  /// LÜCKE dazwischen zählt NICHT (siehe [istStunden]).
  final List<TagBlock> bloecke;

  /// Urlaubsanteil des Tages in Minuten (Urlaub/Sonderurlaub/Firmenurlaub);
  /// null = ganzer Tag.
  final int? urlaubMinuten;

  /// Altformat bis Schema 3, siehe [urlaubAnteil]. Wird nur ausgewertet,
  /// wenn [urlaubMinuten] null ist.
  final bool halberTag;

  const TagDaten({
    required this.datum,
    required this.tagesart,
    this.beginnMin,
    this.pauseMin = 0,
    this.endeMin,
    this.bloecke = const [],
    this.urlaubMinuten,
    this.halberTag = false,
  });
}

/// Tagesarten, die einen (ggf. anteiligen) Urlaubsanspruch verbrauchen.
const urlaubsArten = {
  Tagesart.urlaub,
  Tagesart.sonderurlaub,
  Tagesart.firmenurlaub,
};

/// Urlaubsanteil eines Tages in Stunden.
///
/// Die EINZIGE Stelle, an der das Altformat `halberTag` interpretiert wird:
/// ein halber Tag ist ein halbes Tagessoll. Neue Einträge liefern
/// [TagDaten.urlaubMinuten], fehlt beides gilt der ganze Tag.
double urlaubAnteil(TagDaten tag, double soll) {
  final minuten = tag.urlaubMinuten;
  if (minuten != null) return minuten / 60.0;
  return tag.halberTag ? soll / 2 : soll;
}

/// Ergebnis der Tagesberechnung.
class TagErgebnis {
  /// Geleistete Stunden (nur bei Tagesart Arbeit > 0).
  final double ist;

  /// Sollstunden des Tages laut Regel (0 an Sa/So).
  final double soll;

  /// Überstunden des Tages (kann negativ sein).
  final double ueberstunden;

  const TagErgebnis(
      {required this.ist, required this.soll, required this.ueberstunden});
}

/// Berechnet Ist/Soll/Überstunden eines Tages.
///
/// - Arbeit: Ist = (Ende − Beginn) − Pause, Überstunden = Ist − Soll
/// - Urlaub/Sonderurlaub/Firmenurlaub: der Urlaubsanteil zählt als Ist,
///   dazu kommt die am selben Tag erfasste Arbeitszeit. Der ganze Urlaubstag
///   ohne Arbeitszeiten ergibt Ist = Soll → 0 Überstunden.
/// - Krank/Feiertag: gelten als Soll erfüllt → 0 Überstunden
/// - Zeitausgleich: Ist = 0, Soll bleibt → Überstunden = −Soll
/// - Frei (kein Eintrag): Ist = 0, Überstunden = −Soll (an Sa/So 0)
TagErgebnis berechneTag(TagDaten tag, SollRegel regel) {
  final soll = regel.sollFuer(tag.datum);
  final pause = regel.pausenregel;
  switch (tag.tagesart) {
    case Tagesart.arbeit:
      final ist = istStunden(tag, pause: pause);
      return TagErgebnis(ist: ist, soll: soll, ueberstunden: ist - soll);
    case Tagesart.urlaub || Tagesart.sonderurlaub || Tagesart.firmenurlaub:
      final ist = urlaubAnteil(tag, soll) + istStunden(tag, pause: pause);
      return TagErgebnis(ist: ist, soll: soll, ueberstunden: ist - soll);
    case Tagesart.krank || Tagesart.feiertag:
      return TagErgebnis(ist: soll, soll: soll, ueberstunden: 0);
    case Tagesart.zeitausgleich:
      return TagErgebnis(ist: 0, soll: soll, ueberstunden: -soll);
    case Tagesart.frei:
      return TagErgebnis(ist: 0, soll: soll, ueberstunden: -soll);
  }
}

/// Wie [berechneTag], aber mit fix vorgegebenen Sollstunden – für
/// importierte Einträge, deren Soll aus der Exportdatei stammt.
TagErgebnis berechneMitSoll({
  required Tagesart tagesart,
  required int? beginnMin,
  required int pauseMin,
  required int? endeMin,
  required double soll,
  int? urlaubMinuten,
  Pausenregel pausenregel = Pausenregel.aus,
}) {
  final tag = TagDaten(
    datum: DateTime(2000),
    tagesart: tagesart,
    beginnMin: beginnMin,
    pauseMin: pauseMin,
    endeMin: endeMin,
    urlaubMinuten: urlaubMinuten,
  );
  switch (tagesart) {
    case Tagesart.arbeit:
      final ist = istStunden(tag, pause: pausenregel);
      return TagErgebnis(ist: ist, soll: soll, ueberstunden: ist - soll);
    case Tagesart.urlaub || Tagesart.sonderurlaub || Tagesart.firmenurlaub:
      final ist = urlaubAnteil(tag, soll) + istStunden(tag, pause: pausenregel);
      return TagErgebnis(ist: ist, soll: soll, ueberstunden: ist - soll);
    case Tagesart.krank || Tagesart.feiertag:
      return TagErgebnis(ist: soll, soll: soll, ueberstunden: 0);
    case Tagesart.zeitausgleich || Tagesart.frei:
      return TagErgebnis(ist: 0, soll: soll, ueberstunden: -soll);
  }
}

/// Geleistete Stunden eines Tages.
///
/// Die IST-Zeit ist die SUMME der Blöcke: je Block (Ende − Beginn − Pause).
/// Die LÜCKE zwischen zwei Blöcken zählt bewusst NICHT – weder als Arbeit
/// noch als Pause. Ein Tag ohne Blockliste gilt als EIN Block aus den
/// flachen Feldern (Bestands-/Alltagsfall). Offene Blöcke (kein Ende) zählen
/// 0. Ist eine [Pausenregel] aktiv und die Brutto-Arbeitszeit (Summe der
/// Blockspannen, ohne Lücken) erreicht die Schwelle, wird die GESAMTE Pause
/// auf die Mindestpause AUFGEFÜLLT (kein Doppelabzug).
double istStunden(TagDaten tag, {Pausenregel pause = Pausenregel.aus}) {
  final bloecke = tag.bloecke.isEmpty
      ? [
          TagBlock(
              beginnMin: tag.beginnMin,
              endeMin: tag.endeMin,
              pauseMin: tag.pauseMin)
        ]
      : tag.bloecke;
  var brutto = 0; // Summe der Blockspannen (ohne Lücken)
  var pausen = 0; // Summe der Blockpausen
  for (final b in bloecke) {
    final beginn = b.beginnMin, ende = b.endeMin;
    if (beginn == null || ende == null || ende <= beginn) continue;
    brutto += ende - beginn;
    pausen += b.pauseMin;
  }
  if (brutto <= 0) return 0;
  if (pause.aktiv && brutto >= pause.schwelleMin && pausen < pause.mindestMin) {
    pausen = pause.mindestMin;
  }
  final minuten = brutto - pausen;
  return minuten <= 0 ? 0 : minuten / 60.0;
}

/// Monats-Zusammenfassung.
///
/// Die Tage-Werte sind `double`, weil Urlaub anteilig genommen werden kann
/// (halber Tag, 6,25 h …); Krank/Zeitausgleich/Feiertage sind weiterhin
/// ganze Tage, stehen aber der Einheitlichkeit halber ebenfalls als
/// `double` in der Ausgabe.
class MonatsSumme {
  final double summeIst;
  final double summeSoll;
  final double ueberstunden;
  final double urlaubsTage;
  final double sonderurlaubTage;
  final double firmenurlaubTage;
  final double krankTage;
  final double zeitausgleichTage;
  final double feiertage;

  const MonatsSumme({
    required this.summeIst,
    required this.summeSoll,
    required this.ueberstunden,
    required this.urlaubsTage,
    this.sonderurlaubTage = 0,
    this.firmenurlaubTage = 0,
    required this.krankTage,
    required this.zeitausgleichTage,
    required this.feiertage,
  });
}

/// Summiert die Einträge eines Zeitraums.
///
/// Tage ohne Eintrag zählen NICHT als Minusstunden – nur explizit
/// erfasste Tage fließen ein. (Wer einen Tag unentschuldigt frei hatte,
/// trägt „Zeitausgleich" oder nichts ein; der Chef sieht fehlende Tage
/// in der Auswertung.)
MonatsSumme summiere(Iterable<TagDaten> tage, SollRegel regel) {
  var ist = 0.0, soll = 0.0, ueber = 0.0;
  var urlaub = 0.0, sonder = 0.0, firma = 0.0;
  var krank = 0.0, za = 0.0, feiertage = 0.0;
  for (final tag in tage) {
    final e = berechneTag(tag, regel);
    ist += e.ist;
    soll += e.soll;
    ueber += e.ueberstunden;
    switch (tag.tagesart) {
      case Tagesart.urlaub:
        urlaub += tagesAnteil(tag, e.soll);
      case Tagesart.sonderurlaub:
        sonder += tagesAnteil(tag, e.soll);
      case Tagesart.firmenurlaub:
        firma += tagesAnteil(tag, e.soll);
      case Tagesart.krank:
        krank++;
      case Tagesart.zeitausgleich:
        za++;
      case Tagesart.feiertag:
        feiertage++;
      default:
        break;
    }
  }
  return MonatsSumme(
    summeIst: ist,
    summeSoll: soll,
    ueberstunden: ueber,
    urlaubsTage: urlaub,
    sonderurlaubTage: sonder,
    firmenurlaubTage: firma,
    krankTage: krank,
    zeitausgleichTage: za,
    feiertage: feiertage,
  );
}

/// Verbrauchte Urlaubs-TAGE eines Eintrags: der Stundenanteil im Verhältnis
/// zum Tagessoll. An Tagen ohne Soll (Sa/So) wird nichts verbraucht.
double tagesAnteil(TagDaten tag, double soll) =>
    soll > 0 ? urlaubAnteil(tag, soll) / soll : 0;

/// Formatiert Stunden als „8,5 h" bzw. mit Vorzeichen („+1,25 h" / „−0,5 h").
String formatStunden(double stunden, {bool vorzeichen = false}) {
  final gerundet = (stunden * 100).roundToDouble() / 100;
  var text = gerundet
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '')
      .replaceFirst('.', ',');
  if (text == '-0') text = '0';
  if (vorzeichen && gerundet > 0) text = '+$text';
  return text;
}

/// Minuten seit Mitternacht als „HH:MM".
String formatUhrzeit(int? minuten) {
  if (minuten == null) return '';
  final h = minuten ~/ 60, m = minuten % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

