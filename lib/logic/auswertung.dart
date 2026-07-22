import '../data/database.dart' show Tagesart, TimeEntry;
import 'berechnung.dart';

/// Monats-Zusammenfassung für den Auswertungs-Reiter.
///
/// Sie entsteht automatisch aus den eigenen Einträgen – anders als in der
/// Firmenversion Zeitrax gibt es hier keinen JSON-Import per Mail, die
/// Daten liegen ja schon auf dem Gerät.
///
/// Die Urlaubsarten sind `double`, weil Urlaub anteilig genommen werden kann
/// (halber Tag, 6,25 h …) – ein halber Urlaubstag zählt hier also 0,5.
class MonatsAuswertung {
  final String username;
  final String anzeigename;
  final String monat; // 'JJJJ-MM'
  double ist = 0, soll = 0, ueberstunden = 0;
  double urlaub = 0, sonderurlaub = 0, firmenurlaub = 0;
  int krank = 0, zeitausgleich = 0, feiertage = 0, arbeitstage = 0;

  MonatsAuswertung(this.username, this.anzeigename, this.monat);
}

/// Fasst alle Einträge pro Monat zusammen, aufsteigend nach Monat sortiert.
///
/// Wie in [summiere] zählen nur erfasste Tage – Tage ohne Eintrag ergeben
/// keine Minusstunden.
List<MonatsAuswertung> berechneMonatsAuswertungen({
  required String username,
  required String anzeigename,
  required Iterable<TagDaten> tage,
  required SollRegel regel,
}) {
  final map = <String, MonatsAuswertung>{};
  for (final tag in tage) {
    final monat =
        '${tag.datum.year}-${tag.datum.month.toString().padLeft(2, '0')}';
    final a = map.putIfAbsent(
        monat, () => MonatsAuswertung(username, anzeigename, monat));
    final erg = berechneTag(tag, regel);
    a.ist += erg.ist;
    a.soll += erg.soll;
    a.ueberstunden += erg.ueberstunden;
    // Urlaubsarten anteilig zum Tagessoll zählen.
    final anteil = tagesAnteil(tag, erg.soll);
    switch (tag.tagesart) {
      case Tagesart.arbeit:
        a.arbeitstage++;
      case Tagesart.urlaub:
        a.urlaub += anteil;
      case Tagesart.sonderurlaub:
        a.sonderurlaub += anteil;
      case Tagesart.firmenurlaub:
        a.firmenurlaub += anteil;
      case Tagesart.krank:
        a.krank++;
      case Tagesart.zeitausgleich:
        a.zeitausgleich++;
      case Tagesart.feiertag:
        a.feiertage++;
      case Tagesart.frei:
        break;
    }
  }
  return map.values.toList()..sort((a, b) => a.monat.compareTo(b.monat));
}

/// [berechneMonatsAuswertungen] direkt aus Datenbank-Einträgen.
///
/// [bloecke] bildet Tageskopf-Id → Stempel-Blöcke ab (nur Tage mit ≥2
/// Blöcken); fehlt ein Tag, gilt er als Einzelblock.
List<MonatsAuswertung> monatsAuswertungenAusEintraegen({
  required String username,
  required String anzeigename,
  required Iterable<TimeEntry> eintraege,
  required SollRegel regel,
  Map<int, List<TagBlock>> bloecke = const {},
}) =>
    berechneMonatsAuswertungen(
      username: username,
      anzeigename: anzeigename,
      regel: regel,
      tage: [
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
      ],
    );
