import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart' show SollModus, Tagesart;
import 'package:zeitexa/logic/berechnung.dart';

void main() {
  const regelGetrennt = SollRegel(
      modus: SollModus.moDoFrGetrennt,
      stundenTag: 8,
      stundenMoDo: 8,
      stundenFr: 5);
  const regelGleich = SollRegel(
      modus: SollModus.gleich, stundenTag: 7.5, stundenMoDo: 8, stundenFr: 5);

  // 2026-07-13 = Montag, 2026-07-17 = Freitag, 2026-07-18 = Samstag
  final montag = DateTime(2026, 7, 13);
  final freitag = DateTime(2026, 7, 17);
  final samstag = DateTime(2026, 7, 18);
  final sonntag = DateTime(2026, 7, 19);

  group('SollRegel', () {
    test('Mo–Do und Fr getrennt', () {
      expect(regelGetrennt.sollFuer(montag), 8);
      expect(regelGetrennt.sollFuer(freitag), 5);
      expect(regelGetrennt.sollFuer(samstag), 0);
      expect(regelGetrennt.sollFuer(sonntag), 0);
    });

    test('genereller Stundensatz gilt auch am Freitag', () {
      expect(regelGleich.sollFuer(montag), 7.5);
      expect(regelGleich.sollFuer(freitag), 7.5);
      expect(regelGleich.sollFuer(samstag), 0);
    });
  });

  group('berechneTag – Arbeit', () {
    test('normaler Arbeitstag: 07:00–16:00, 30 min Pause = 8,5 h', () {
      final e = berechneTag(
          TagDaten(
              datum: montag,
              tagesart: Tagesart.arbeit,
              beginnMin: 7 * 60,
              pauseMin: 30,
              endeMin: 16 * 60),
          regelGetrennt);
      expect(e.ist, 8.5);
      expect(e.soll, 8);
      expect(e.ueberstunden, 0.5);
    });

    test('Minusstunden: 08:00–15:00, 60 min Pause = 6 h bei Soll 8', () {
      final e = berechneTag(
          TagDaten(
              datum: montag,
              tagesart: Tagesart.arbeit,
              beginnMin: 8 * 60,
              pauseMin: 60,
              endeMin: 15 * 60),
          regelGetrennt);
      expect(e.ist, 6);
      expect(e.ueberstunden, -2);
    });

    test('Freitag-Sonderregel: 07:00–12:00 ohne Pause = genau Soll 5', () {
      final e = berechneTag(
          TagDaten(
              datum: freitag,
              tagesart: Tagesart.arbeit,
              beginnMin: 7 * 60,
              pauseMin: 0,
              endeMin: 12 * 60),
          regelGetrennt);
      expect(e.ist, 5);
      expect(e.ueberstunden, 0);
    });

    test('Samstagsarbeit zählt komplett als Überstunden', () {
      final e = berechneTag(
          TagDaten(
              datum: samstag,
              tagesart: Tagesart.arbeit,
              beginnMin: 8 * 60,
              pauseMin: 0,
              endeMin: 12 * 60),
          regelGetrennt);
      expect(e.ist, 4);
      expect(e.soll, 0);
      expect(e.ueberstunden, 4);
    });

    test('unvollständige Zeiten ergeben 0 Ist', () {
      final e = berechneTag(
          TagDaten(datum: montag, tagesart: Tagesart.arbeit, beginnMin: 480),
          regelGetrennt);
      expect(e.ist, 0);
      expect(e.ueberstunden, -8);
    });

    test('Pause länger als Arbeitszeit ergibt 0 Ist', () {
      final e = berechneTag(
          TagDaten(
              datum: montag,
              tagesart: Tagesart.arbeit,
              beginnMin: 480,
              pauseMin: 600,
              endeMin: 540),
          regelGetrennt);
      expect(e.ist, 0);
    });
  });

  group('berechneTag – andere Tagesarten', () {
    for (final art in [Tagesart.urlaub, Tagesart.krank, Tagesart.feiertag]) {
      test('$art gilt als Soll erfüllt (Mo und Fr)', () {
        final mo =
            berechneTag(TagDaten(datum: montag, tagesart: art), regelGetrennt);
        expect(mo.ist, 8);
        expect(mo.ueberstunden, 0);
        final fr =
            berechneTag(TagDaten(datum: freitag, tagesart: art), regelGetrennt);
        expect(fr.ist, 5);
        expect(fr.ueberstunden, 0);
      });
    }

    test('Zeitausgleich zieht Tagessoll vom Saldo ab', () {
      final mo = berechneTag(
          TagDaten(datum: montag, tagesart: Tagesart.zeitausgleich),
          regelGetrennt);
      expect(mo.ist, 0);
      expect(mo.ueberstunden, -8);
      final fr = berechneTag(
          TagDaten(datum: freitag, tagesart: Tagesart.zeitausgleich),
          regelGetrennt);
      expect(fr.ueberstunden, -5);
    });
  });

  group('summiere', () {
    test('gemischte Woche', () {
      final tage = [
        // Mo Arbeit 9h (07-16:30, 30 Pause) → +1
        TagDaten(
            datum: DateTime(2026, 7, 13),
            tagesart: Tagesart.arbeit,
            beginnMin: 420,
            pauseMin: 30,
            endeMin: 990),
        // Di Urlaub → soll erfüllt
        TagDaten(datum: DateTime(2026, 7, 14), tagesart: Tagesart.urlaub),
        // Mi Krank
        TagDaten(datum: DateTime(2026, 7, 15), tagesart: Tagesart.krank),
        // Do Zeitausgleich → −8
        TagDaten(
            datum: DateTime(2026, 7, 16), tagesart: Tagesart.zeitausgleich),
        // Fr Arbeit 4h bei Soll 5 → −1
        TagDaten(
            datum: DateTime(2026, 7, 17),
            tagesart: Tagesart.arbeit,
            beginnMin: 420,
            pauseMin: 0,
            endeMin: 660),
      ];
      final s = summiere(tage, regelGetrennt);
      expect(s.summeIst, 9 + 8 + 8 + 0 + 4);
      expect(s.summeSoll, 8 + 8 + 8 + 8 + 5);
      expect(s.ueberstunden, 1 + 0 + 0 - 8 - 1);
      expect(s.urlaubsTage, 1);
      expect(s.krankTage, 1);
      expect(s.zeitausgleichTage, 1);
    });
  });

  group('berechneMitSoll (Import)', () {
    test('Arbeit mit fixem Soll', () {
      final e = berechneMitSoll(
          tagesart: Tagesart.arbeit,
          beginnMin: 420,
          pauseMin: 30,
          endeMin: 960,
          soll: 8);
      expect(e.ist, 8.5);
      expect(e.ueberstunden, 0.5);
    });

    test('Urlaub mit fixem Soll', () {
      final e = berechneMitSoll(
          tagesart: Tagesart.urlaub,
          beginnMin: null,
          pauseMin: 0,
          endeMin: null,
          soll: 5);
      expect(e.ist, 5);
      expect(e.ueberstunden, 0);
    });
  });

  group('Teil-Urlaub in Stunden', () {
    test('ganzer Urlaubstag bleibt bei 0 Überstunden (Regression)', () {
      final e = berechneTag(
          TagDaten(datum: montag, tagesart: Tagesart.urlaub), regelGetrennt);
      expect(e.ist, 8);
      expect(e.ueberstunden, 0);
    });

    test('6,25 h Urlaub + 1,75 h gearbeitet bei 8 h Soll = 0 Überstunden', () {
      final e = berechneTag(
          TagDaten(
            datum: montag,
            tagesart: Tagesart.urlaub,
            urlaubMinuten: 375, // 6,25 h
            beginnMin: 8 * 60,
            endeMin: 9 * 60 + 45, // 1,75 h
          ),
          regelGetrennt);
      expect(e.ist, closeTo(8, 0.0001));
      expect(e.ueberstunden, closeTo(0, 0.0001));
    });

    test('Teil-Urlaub ohne Arbeitszeit ergibt Minusstunden', () {
      final e = berechneTag(
          TagDaten(
              datum: montag, tagesart: Tagesart.urlaub, urlaubMinuten: 240),
          regelGetrennt);
      expect(e.ist, 4);
      expect(e.ueberstunden, -4);
    });

    test('Altformat halberTag ohne urlaubMinuten = halbes Tagessoll', () {
      final e = berechneTag(
          TagDaten(
              datum: montag, tagesart: Tagesart.urlaub, halberTag: true),
          regelGetrennt);
      expect(e.ist, 4);
      // urlaubMinuten gewinnt, wenn beides gesetzt ist.
      final neu = berechneTag(
          TagDaten(
              datum: montag,
              tagesart: Tagesart.urlaub,
              halberTag: true,
              urlaubMinuten: 375),
          regelGetrennt);
      expect(neu.ist, closeTo(6.25, 0.0001));
    });

    test('Sonderurlaub und Firmenurlaub rechnen wie Urlaub', () {
      for (final art in [Tagesart.sonderurlaub, Tagesart.firmenurlaub]) {
        final e =
            berechneTag(TagDaten(datum: montag, tagesart: art), regelGetrennt);
        expect(e.ist, 8, reason: '$art');
        expect(e.ueberstunden, 0, reason: '$art');
      }
    });

    test('summiere zählt Urlaubsarten anteilig und getrennt', () {
      final summe = summiere([
        TagDaten(datum: montag, tagesart: Tagesart.urlaub),
        TagDaten(
            datum: DateTime(2026, 7, 14),
            tagesart: Tagesart.urlaub,
            urlaubMinuten: 240), // halber Tag bei 8 h Soll
        TagDaten(datum: DateTime(2026, 7, 15), tagesart: Tagesart.sonderurlaub),
        TagDaten(datum: DateTime(2026, 7, 16), tagesart: Tagesart.firmenurlaub),
      ], regelGetrennt);
      expect(summe.urlaubsTage, closeTo(1.5, 0.0001));
      expect(summe.sonderurlaubTage, closeTo(1, 0.0001));
      expect(summe.firmenurlaubTage, closeTo(1, 0.0001));
    });

    test('berechneMitSoll übernimmt den Urlaubsanteil aus dem Export', () {
      final e = berechneMitSoll(
          tagesart: Tagesart.urlaub,
          beginnMin: null,
          pauseMin: 0,
          endeMin: null,
          soll: 8,
          urlaubMinuten: 375);
      expect(e.ist, closeTo(6.25, 0.0001));
      expect(e.ueberstunden, closeTo(-1.75, 0.0001));
    });
  });

  group('Formatierung', () {
    test('formatStunden', () {
      expect(formatStunden(8.5), '8,5');
      expect(formatStunden(8), '8');
      expect(formatStunden(-2.25, vorzeichen: true), '-2,25');
      expect(formatStunden(1.5, vorzeichen: true), '+1,5');
      expect(formatStunden(0, vorzeichen: true), '0');
    });

    test('formatUhrzeit', () {
      expect(formatUhrzeit(420), '07:00');
      expect(formatUhrzeit(990), '16:30');
      expect(formatUhrzeit(null), '');
    });
  });
}
