import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/logic/feiertage.dart';

void main() {
  test('Ostersonntag bekannte Jahre', () {
    expect(ostersonntag(2024), DateTime(2024, 3, 31));
    expect(ostersonntag(2025), DateTime(2025, 4, 20));
    expect(ostersonntag(2026), DateTime(2026, 4, 5));
    expect(ostersonntag(2027), DateTime(2027, 3, 28));
  });

  test('bewegliche Feiertage 2026', () {
    final f = feiertageAt(2026);
    expect(f[DateTime(2026, 4, 6)], 'Ostermontag');
    expect(f[DateTime(2026, 5, 14)], 'Christi Himmelfahrt');
    expect(f[DateTime(2026, 5, 25)], 'Pfingstmontag');
    expect(f[DateTime(2026, 6, 4)], 'Fronleichnam');
  });

  test('fixe Feiertage', () {
    final f = feiertageAt(2026);
    expect(f[DateTime(2026, 1, 1)], 'Neujahr');
    expect(f[DateTime(2026, 10, 26)], 'Nationalfeiertag');
    expect(f[DateTime(2026, 12, 25)], 'Christtag');
    expect(f.length, 13);
  });

  test('feiertagsName ignoriert Uhrzeit', () {
    expect(feiertagsName(DateTime(2026, 12, 25, 14, 30)), 'Christtag');
    expect(feiertagsName(DateTime(2026, 7, 14)), isNull);
  });
}
