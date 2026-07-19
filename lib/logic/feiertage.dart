/// Österreichische gesetzliche Feiertage.
library;

/// Ostersonntag nach der Gauß'schen Osterformel (gregorianisch).
DateTime ostersonntag(int jahr) {
  final a = jahr % 19;
  final b = jahr ~/ 100;
  final c = jahr % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final monat = (h + l - 7 * m + 114) ~/ 31;
  final tag = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(jahr, monat, tag);
}

/// Gesetzliche Feiertage Österreichs für ein Jahr: Datum → Name.
Map<DateTime, String> feiertageAt(int jahr) {
  final ostern = ostersonntag(jahr);
  DateTime plus(int tage) => DateTime(jahr, ostern.month, ostern.day + tage);
  return {
    DateTime(jahr, 1, 1): 'Neujahr',
    DateTime(jahr, 1, 6): 'Heilige Drei Könige',
    plus(1): 'Ostermontag',
    DateTime(jahr, 5, 1): 'Staatsfeiertag',
    plus(39): 'Christi Himmelfahrt',
    plus(50): 'Pfingstmontag',
    plus(60): 'Fronleichnam',
    DateTime(jahr, 8, 15): 'Mariä Himmelfahrt',
    DateTime(jahr, 10, 26): 'Nationalfeiertag',
    DateTime(jahr, 11, 1): 'Allerheiligen',
    DateTime(jahr, 12, 8): 'Mariä Empfängnis',
    DateTime(jahr, 12, 25): 'Christtag',
    DateTime(jahr, 12, 26): 'Stefanitag',
  };
}

/// Name des Feiertags oder null.
String? feiertagsName(DateTime datum) =>
    feiertageAt(datum.year)[DateTime(datum.year, datum.month, datum.day)];
