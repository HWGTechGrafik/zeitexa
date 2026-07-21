import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/logic/berechnung.dart';

void main() {
  // 2026-07-13 Mo, 15 Mi, 18 Sa, 19 So
  final mo = DateTime(2026, 7, 13);
  final mi = DateTime(2026, 7, 15);
  final sa = DateTime(2026, 7, 18);
  final so = DateTime(2026, 7, 19);

  group('SollRegel pro Wochentag', () {
    const regel = SollRegel(
      modus: SollModus.proWochentag,
      stundenTag: 8,
      stundenMoDo: 8,
      stundenFr: 5,
      proWochentag: [8, 8, 0, 6, 5, 3, 0], // Mi frei, Sa 3 h
    );

    test('liefert den Tageswert – auch für Sa (nicht hart 0)', () {
      expect(regel.sollFuer(mo), 8);
      expect(regel.sollFuer(mi), 0);
      expect(regel.sollFuer(sa), 3);
      expect(regel.sollFuer(so), 0);
    });
  });

  group('Pausenregel (Mindestpause auffüllen)', () {
    TagDaten arbeit(int beginn, int ende, {int pause = 0}) => TagDaten(
        datum: mo, tagesart: Tagesart.arbeit,
        beginnMin: beginn, endeMin: ende, pauseMin: pause);

    const regel = Pausenregel(aktiv: true, schwelleMin: 12 * 60, mindestMin: 60);

    test('unter der Schwelle bleibt die Pause unverändert', () {
      // 8 h anwesend, 0 Pause → 8 h
      expect(istStunden(arbeit(8 * 60, 16 * 60), pause: regel), 8);
    });

    test('ab der Schwelle wird auf die Mindestpause aufgefüllt', () {
      // 13 h anwesend, 0 Pause → 13 h − 1 h = 12 h
      expect(istStunden(arbeit(6 * 60, 19 * 60), pause: regel), 12);
    });

    test('bereits ausreichende Pause wird nicht doppelt abgezogen', () {
      // 13 h anwesend, 90 min Pause → 13 h − 1,5 h = 11,5 h (nicht −2,5 h)
      expect(istStunden(arbeit(6 * 60, 19 * 60, pause: 90), pause: regel), 11.5);
    });

    test('aus: keine automatische Pause', () {
      expect(istStunden(arbeit(6 * 60, 19 * 60)), 13);
    });
  });

  group('Mehrere Blöcke (Lücken als Pause in pauseMin)', () {
    test('zwei Blöcke = Summe der Blöcke', () {
      // 08–12 (4 h) + 13–17 (4 h): Klammer 08–17 = 9 h, Lücke 60 min in pause.
      final tag = TagDaten(
        datum: mo, tagesart: Tagesart.arbeit,
        beginnMin: 8 * 60, endeMin: 17 * 60, pauseMin: 60);
      expect(istStunden(tag), 8);
    });
  });

  group('Offener Block', () {
    test('ohne Ende zählt 0 Ist', () {
      final tag = TagDaten(
          datum: mo, tagesart: Tagesart.arbeit, beginnMin: 8 * 60, endeMin: null);
      expect(istStunden(tag), 0);
      const regel = SollRegel(
          modus: SollModus.gleich, stundenTag: 8, stundenMoDo: 8, stundenFr: 5);
      final e = berechneTag(tag, regel);
      expect(e.ist, 0);
      expect(e.ueberstunden, -8);
    });
  });
}
