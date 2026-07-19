import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart' show SollModus, Tagesart, TimeEntry;
import 'package:zeitexa/logic/berechnung.dart';
import 'package:zeitexa/logic/konten.dart';

void main() {
  const regel = SollRegel(
      modus: SollModus.moDoFrGetrennt,
      stundenTag: 8,
      stundenMoDo: 8,
      stundenFr: 5);

  TimeEntry entry({
    required DateTime datum,
    required Tagesart tagesart,
    int? beginnMin,
    int pauseMin = 0,
    int? endeMin,
    bool halberTag = false,
    int? urlaubMinuten,
  }) =>
      TimeEntry(
        id: 0,
        userId: 1,
        datum: datum,
        tagesart: tagesart,
        pauseMin: pauseMin,
        beginnMin: beginnMin,
        endeMin: endeMin,
        notiz: '',
        halberTag: halberTag,
        urlaubMinuten: urlaubMinuten,
      );

  group('berechneKonten', () {
    test('Zeitausgleich-Stand = Anfangsstand + Überstunden seit Stichtag', () {
      final stichtag = DateTime(2026, 7, 1);
      final eintraege = [
        // Vor dem Stichtag: darf nicht mitzählen.
        entry(
            datum: DateTime(2026, 6, 15),
            tagesart: Tagesart.arbeit,
            beginnMin: 7 * 60,
            endeMin: 20 * 60), // riesige Überstunde, aber ignoriert
        // 13.07. Montag, Arbeit 07-17, 30 Pause = 9,5h → +1,5
        entry(
            datum: DateTime(2026, 7, 13),
            tagesart: Tagesart.arbeit,
            beginnMin: 7 * 60,
            pauseMin: 30,
            endeMin: 17 * 60),
        // 14.07. Dienstag, Zeitausgleich genommen → -8
        entry(datum: DateTime(2026, 7, 14), tagesart: Tagesart.zeitausgleich),
      ];
      final stand = berechneKonten(
        alleEintraege: eintraege,
        regel: regel,
        jahr: 2026,
        monat: 7,
        anfangsstandUrlaubTage: 0,
        anfangsstandZeitausgleichStunden: 10,
        anfangsstandStichtag: stichtag,
      );
      expect(stand.zeitausgleichGesamt, 10 + 1.5 - 8);
      expect(stand.zeitausgleichMonat, 1.5 - 8);
    });

    test('Resturlaub berücksichtigt halbe Tage', () {
      final eintraege = [
        entry(datum: DateTime(2026, 7, 6), tagesart: Tagesart.urlaub),
        entry(
            datum: DateTime(2026, 7, 7),
            tagesart: Tagesart.urlaub,
            halberTag: true),
        // anderer Monat
        entry(datum: DateTime(2026, 8, 3), tagesart: Tagesart.urlaub),
      ];
      final stand = berechneKonten(
        alleEintraege: eintraege,
        regel: regel,
        jahr: 2026,
        monat: 7,
        anfangsstandUrlaubTage: 25,
        anfangsstandZeitausgleichStunden: 0,
        anfangsstandStichtag: null,
      );
      expect(stand.urlaubMonat, 1.5);
      expect(stand.urlaubGesamt, 25 - 1.5 - 1);
    });

    test('Kranktage zählen unabhängig vom Stichtag (kein Anfangsstand)', () {
      final stichtag = DateTime(2026, 7, 1);
      final eintraege = [
        entry(datum: DateTime(2026, 6, 10), tagesart: Tagesart.krank),
        entry(datum: DateTime(2026, 7, 5), tagesart: Tagesart.krank),
      ];
      final stand = berechneKonten(
        alleEintraege: eintraege,
        regel: regel,
        jahr: 2026,
        monat: 7,
        anfangsstandUrlaubTage: 0,
        anfangsstandZeitausgleichStunden: 0,
        anfangsstandStichtag: stichtag,
      );
      expect(stand.krankGesamt, 2);
      expect(stand.krankMonat, 1);
    });

    test('Stichtag mitten im Monat: Monat zählt voll, Laufzeit ab Stichtag',
        () {
      final stichtag = DateTime(2026, 7, 15);
      final eintraege = [
        // 13.07. Montag, VOR dem Stichtag: 07-17, 30 Pause = 9,5h → +1,5
        entry(
            datum: DateTime(2026, 7, 13),
            tagesart: Tagesart.arbeit,
            beginnMin: 7 * 60,
            pauseMin: 30,
            endeMin: 17 * 60),
        // 20.07. Montag, NACH dem Stichtag: ebenfalls +1,5
        entry(
            datum: DateTime(2026, 7, 20),
            tagesart: Tagesart.arbeit,
            beginnMin: 7 * 60,
            pauseMin: 30,
            endeMin: 17 * 60),
        // Urlaub vor dem Stichtag: zählt im Monat, nicht in der Laufzeit.
        entry(datum: DateTime(2026, 7, 14), tagesart: Tagesart.urlaub),
      ];
      final stand = berechneKonten(
        alleEintraege: eintraege,
        regel: regel,
        jahr: 2026,
        monat: 7,
        anfangsstandUrlaubTage: 25,
        anfangsstandZeitausgleichStunden: 10,
        anfangsstandStichtag: stichtag,
      );
      // Monat: voller Juli, unabhängig vom Stichtag.
      expect(stand.zeitausgleichMonat, 1.5 + 1.5);
      expect(stand.urlaubMonat, 1);
      // Laufzeit: nur ab Stichtag – der 13.07. und der Urlaub am 14.07.
      // stecken bereits im Anfangsstand.
      expect(stand.zeitausgleichGesamt, 10 + 1.5);
      expect(stand.urlaubGesamt, 25);
    });

    test('getrennter Freitags-Urlaub bucht vom eigenen Konto ab', () {
      final eintraege = [
        // 06.07. Montag, 07.07. Dienstag -> Mo-Do-Konto (Di halber Tag)
        entry(datum: DateTime(2026, 7, 6), tagesart: Tagesart.urlaub),
        entry(
            datum: DateTime(2026, 7, 7),
            tagesart: Tagesart.urlaub,
            halberTag: true),
        // 10.07. Freitag -> Fr-Konto
        entry(datum: DateTime(2026, 7, 10), tagesart: Tagesart.urlaub),
        // Freitag im Folgemonat: zaehlt nur in der Laufzeit.
        entry(datum: DateTime(2026, 8, 7), tagesart: Tagesart.urlaub),
      ];
      final stand = berechneKonten(
        alleEintraege: eintraege,
        regel: regel,
        jahr: 2026,
        monat: 7,
        anfangsstandUrlaubTage: 20,
        anfangsstandZeitausgleichStunden: 0,
        anfangsstandStichtag: null,
        urlaubFrGetrennt: true,
        anfangsstandUrlaubFrTage: 5,
      );
      expect(stand.urlaubMonat, 1.5);
      expect(stand.urlaubGesamt, 20 - 1.5);
      expect(stand.urlaubFrMonat, 1);
      expect(stand.urlaubFrGesamt, 5 - 2);
    });

    test('ohne getrennten Freitags-Urlaub zaehlt alles in EIN Konto', () {
      final eintraege = [
        entry(datum: DateTime(2026, 7, 6), tagesart: Tagesart.urlaub),
        entry(datum: DateTime(2026, 7, 10), tagesart: Tagesart.urlaub),
      ];
      final stand = berechneKonten(
        alleEintraege: eintraege,
        regel: regel,
        jahr: 2026,
        monat: 7,
        anfangsstandUrlaubTage: 20,
        anfangsstandZeitausgleichStunden: 0,
        anfangsstandStichtag: null,
      );
      expect(stand.urlaubMonat, 2);
      expect(stand.urlaubGesamt, 18);
      expect(stand.urlaubFrMonat, 0);
      expect(stand.urlaubFrGesamt, 0);
    });

    test('Jahresübertrag: unbegrenzt, kein Deckel', () {
      final eintraege = [
        for (var monat = 1; monat <= 24; monat++)
          entry(
              datum: DateTime(2025, ((monat - 1) % 12) + 1, 15).add(
                  Duration(days: monat > 12 ? 365 : 0)),
              tagesart: Tagesart.zeitausgleich),
      ];
      final stand = berechneKonten(
        alleEintraege: eintraege,
        regel: regel,
        jahr: 2027,
        monat: 1,
        anfangsstandUrlaubTage: 0,
        anfangsstandZeitausgleichStunden: 0,
        anfangsstandStichtag: null,
      );
      // Alle 24 Zeitausgleich-Tage ziehen unbegrenzt vom Saldo ab, egal
      // über wie viele Jahre hinweg.
      expect(stand.zeitausgleichGesamt, lessThan(-100));
    });

    test('Urlaub wird anteilig zum Tagessoll verbraucht', () {
      final eintraege = [
        // Montag, 8 h Soll, davon 6,25 h Urlaub → 0,78125 Tage
        entry(
            datum: DateTime(2026, 7, 13),
            tagesart: Tagesart.urlaub,
            urlaubMinuten: 375),
        // Freitag, 5 h Soll, davon 2,5 h Urlaub → 0,5 Tage
        entry(
            datum: DateTime(2026, 7, 17),
            tagesart: Tagesart.urlaub,
            urlaubMinuten: 150),
      ];
      final stand = berechneKonten(
        alleEintraege: eintraege,
        regel: regel,
        jahr: 2026,
        monat: 7,
        anfangsstandUrlaubTage: 25,
        anfangsstandZeitausgleichStunden: 0,
        anfangsstandStichtag: null,
      );
      expect(stand.urlaubMonat, closeTo(1.28125, 0.0001));
      expect(stand.urlaubGesamt, closeTo(25 - 1.28125, 0.0001));
    });

    test('Sonderurlaub wird nur gezählt und belastet kein Konto', () {
      final eintraege = [
        entry(datum: DateTime(2026, 7, 13), tagesart: Tagesart.sonderurlaub),
        entry(datum: DateTime(2026, 7, 14), tagesart: Tagesart.sonderurlaub),
      ];
      final stand = berechneKonten(
        alleEintraege: eintraege,
        regel: regel,
        jahr: 2026,
        monat: 7,
        anfangsstandUrlaubTage: 25,
        anfangsstandZeitausgleichStunden: 0,
        anfangsstandStichtag: null,
      );
      expect(stand.sonderurlaubMonat, closeTo(2, 0.0001));
      expect(stand.sonderurlaubGesamt, closeTo(2, 0.0001));
      // Weder Urlaubs- noch Zeitausgleichskonto rühren sich.
      expect(stand.urlaubGesamt, 25);
      expect(stand.zeitausgleichGesamt, 0);
    });

    test('Firmenurlaub bucht vom eigenen Kontingent ab, ab Stichtag', () {
      final stichtag = DateTime(2026, 7, 1);
      final eintraege = [
        // Vor dem Stichtag: steckt schon im Anfangsstand.
        entry(datum: DateTime(2026, 6, 15), tagesart: Tagesart.firmenurlaub),
        entry(datum: DateTime(2026, 7, 13), tagesart: Tagesart.firmenurlaub),
        entry(
            datum: DateTime(2026, 7, 14),
            tagesart: Tagesart.firmenurlaub,
            urlaubMinuten: 240), // halber Tag
        // Normaler Urlaub darf das Firmenurlaubs-Konto nicht anfassen.
        entry(datum: DateTime(2026, 7, 15), tagesart: Tagesart.urlaub),
      ];
      final stand = berechneKonten(
        alleEintraege: eintraege,
        regel: regel,
        jahr: 2026,
        monat: 7,
        anfangsstandUrlaubTage: 25,
        anfangsstandZeitausgleichStunden: 0,
        anfangsstandStichtag: stichtag,
        firmenurlaubAktiv: true,
        anfangsstandFirmenurlaubTage: 5,
      );
      expect(stand.firmenurlaubGesamt, closeTo(5 - 1.5, 0.0001));
      // Monatswert zählt den vollen Monat, hier ohne Juni-Eintrag.
      expect(stand.firmenurlaubMonat, closeTo(1.5, 0.0001));
      expect(stand.urlaubGesamt, closeTo(24, 0.0001));
    });

    test('ohne aktives Firmenurlaub-Konto bleibt der Saldo 0', () {
      final stand = berechneKonten(
        alleEintraege: [
          entry(datum: DateTime(2026, 7, 13), tagesart: Tagesart.firmenurlaub),
        ],
        regel: regel,
        jahr: 2026,
        monat: 7,
        anfangsstandUrlaubTage: 0,
        anfangsstandZeitausgleichStunden: 0,
        anfangsstandStichtag: null,
        anfangsstandFirmenurlaubTage: 5,
      );
      expect(stand.firmenurlaubGesamt, 0);
    });
  });
}
