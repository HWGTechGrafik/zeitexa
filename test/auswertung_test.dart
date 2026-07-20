import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart' show SollModus, Tagesart;
import 'package:zeitexa/logic/auswertung.dart';
import 'package:zeitexa/logic/berechnung.dart';

void main() {
  const regel = SollRegel(
    modus: SollModus.gleich,
    stundenTag: 8,
    stundenMoDo: 8,
    stundenFr: 8,
  );

  test('berechneMonatsAuswertungen fasst pro Monat zusammen und sortiert', () {
    final auswertungen = berechneMonatsAuswertungen(
      username: 'max',
      anzeigename: 'Max Mustermann',
      regel: regel,
      tage: [
        // Juli VOR Juni übergeben – die Ausgabe muss trotzdem sortiert sein.
        TagDaten(
          datum: DateTime(2026, 7, 13), // Montag
          tagesart: Tagesart.arbeit,
          beginnMin: 7 * 60,
          pauseMin: 30,
          endeMin: 16 * 60, // 8,5 h bei Soll 8 → +0,5
        ),
        TagDaten(
          datum: DateTime(2026, 7, 14),
          tagesart: Tagesart.urlaub,
          urlaubMinuten: 240, // halber Tag
        ),
        TagDaten(datum: DateTime(2026, 6, 15), tagesart: Tagesart.krank),
        TagDaten(datum: DateTime(2026, 6, 16), tagesart: Tagesart.feiertag),
        TagDaten(
            datum: DateTime(2026, 6, 17), tagesart: Tagesart.zeitausgleich),
      ],
    );

    expect(auswertungen.map((a) => a.monat), ['2026-06', '2026-07']);
    expect(auswertungen.first.anzeigename, 'Max Mustermann');

    final juni = auswertungen[0];
    expect(juni.krank, 1);
    expect(juni.feiertage, 1);
    expect(juni.zeitausgleich, 1);
    expect(juni.ueberstunden, -8); // nur der Zeitausgleich kostet Soll

    final juli = auswertungen[1];
    expect(juli.arbeitstage, 1);
    expect(juli.ist, closeTo(12.5, 0.001)); // 8,5 Arbeit + 4 h Urlaub
    expect(juli.soll, 16);
    expect(juli.urlaub, closeTo(0.5, 0.001)); // halber Tag zählt 0,5
  });

  test('Tage ohne Eintrag ergeben keine Auswertung', () {
    expect(
      berechneMonatsAuswertungen(
          username: 'max', anzeigename: 'Max', regel: regel, tage: const []),
      isEmpty,
    );
  });
}
