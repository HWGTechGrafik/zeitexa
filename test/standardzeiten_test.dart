import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/ui/standardzeiten_felder.dart';

void main() {
  // 2026-07-13 = Montag, 2026-07-17 = Freitag
  final montag = DateTime(2026, 7, 13);
  final freitag = DateTime(2026, 7, 17);

  UserSetting einstellungen({
    SollModus modus = SollModus.moDoFrGetrennt,
    int? beginnFr,
    int? endeFr,
    int? pauseFr,
  }) =>
      UserSetting(
        userId: 1,
        sollModus: modus,
        sollStundenTag: 8,
        sollStundenMoDo: 8,
        sollStundenFr: 5,
        standardBeginnMin: 7 * 60,
        standardEndeMin: 16 * 60,
        standardPauseMin: 30,
        standardBeginnFrMin: beginnFr,
        standardEndeFrMin: endeFr,
        standardPauseFrMin: pauseFr,
        anfangsstandUrlaubTage: 0,
        anfangsstandZeitausgleichMin: 0,
        urlaubFrGetrennt: false,
        anfangsstandUrlaubFrTage: 0,
        firmenurlaubAktiv: false,
        anfangsstandFirmenurlaubTage: 0,
      );

  group('standardzeitenFuer', () {
    test('ohne Freitagszeiten gilt überall Mo–Do (Bestandsverhalten)', () {
      final s = einstellungen();
      for (final tag in [montag, freitag]) {
        final z = standardzeitenFuer(s, tag);
        expect(z.beginnMin, 7 * 60, reason: '$tag');
        expect(z.endeMin, 16 * 60, reason: '$tag');
        expect(z.pauseMin, 30, reason: '$tag');
      }
    });

    test('mit Freitagszeiten zieht der Freitag die eigenen Werte', () {
      final s = einstellungen(
          beginnFr: 7 * 60, endeFr: 12 * 60, pauseFr: 0);
      final fr = standardzeitenFuer(s, freitag);
      expect(fr.beginnMin, 7 * 60);
      expect(fr.endeMin, 12 * 60);
      expect(fr.pauseMin, 0);

      // Mo–Do bleibt unberührt.
      final mo = standardzeitenFuer(s, montag);
      expect(mo.endeMin, 16 * 60);
      expect(mo.pauseMin, 30);
    });

    test('einzeln gesetzte Freitagswerte fallen auf Mo–Do zurück', () {
      final s = einstellungen(endeFr: 12 * 60);
      final fr = standardzeitenFuer(s, freitag);
      expect(fr.beginnMin, 7 * 60); // nicht gesetzt → wie Mo–Do
      expect(fr.endeMin, 12 * 60);
      expect(fr.pauseMin, 30);
    });

    test('bei generellem Sollmodus zählt der Freitag nicht gesondert', () {
      final s = einstellungen(
          modus: SollModus.gleich, beginnFr: 9 * 60, endeFr: 12 * 60);
      final fr = standardzeitenFuer(s, freitag);
      expect(fr.beginnMin, 7 * 60);
      expect(fr.endeMin, 16 * 60);
    });
  });
}
