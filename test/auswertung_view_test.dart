import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/main.dart';
import 'package:zeitexa/ui/auswertung_view.dart';

void main() {
  testWidgets(
      'Auswertung zeigt beide Diagramme und eine Tabellenzeile je Monat',
      (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());

    // Ein Arbeitstag mit Überstunden (07:00–16:00, 30 min Pause = 8,5 h bei
    // Soll 8), ein halber Urlaubstag, ein Sonderurlaub und ein Firmenurlaub.
    await db.mergeImport('max', '2026-07', [
      ImportedEntriesCompanion.insert(
        quellUsername: 'max',
        quellDisplayName: 'Max Mustermann',
        monat: '2026-07',
        datum: DateTime(2026, 7, 13),
        tagesart: Tagesart.arbeit,
        beginnMin: const Value(420),
        pauseMin: const Value(30),
        endeMin: const Value(960),
        sollStunden: 8,
      ),
      ImportedEntriesCompanion.insert(
        quellUsername: 'max',
        quellDisplayName: 'Max Mustermann',
        monat: '2026-07',
        datum: DateTime(2026, 7, 14),
        tagesart: Tagesart.urlaub,
        urlaubMinuten: const Value(240), // halber Tag bei 8 h Soll
        sollStunden: 8,
      ),
      ImportedEntriesCompanion.insert(
        quellUsername: 'max',
        quellDisplayName: 'Max Mustermann',
        monat: '2026-07',
        datum: DateTime(2026, 7, 15),
        tagesart: Tagesart.sonderurlaub,
        sonderurlaubGrund: const Value(SonderurlaubGrund.todesfall),
        sollStunden: 8,
      ),
      ImportedEntriesCompanion.insert(
        quellUsername: 'max',
        quellDisplayName: 'Max Mustermann',
        monat: '2026-07',
        datum: DateTime(2026, 7, 16),
        tagesart: Tagesart.firmenurlaub,
        sollStunden: 8,
      ),
    ]);

    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: const MaterialApp(home: AuswertungView()),
    ));
    // Drift-Zugriff aus initState (_lade) ist echte Async-I/O.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();

    // Mitarbeiter-Karte aufklappen.
    expect(find.text('Max Mustermann'), findsOneWidget);
    await tester.tap(find.text('Max Mustermann'));
    await tester.pumpAndSettle();

    // Beide Diagramme sind da.
    expect(find.text('Überstunden je Monat'), findsOneWidget);
    expect(find.text('Ist gegen Soll je Monat'), findsOneWidget);

    // Genau EINE Tabellenzeile für den Monat (die Monatsspalte links).
    expect(find.text('2026-07'), findsOneWidget);
    expect(find.text('Monat'), findsOneWidget);

    // Die neuen Spalten haben eigene Köpfe ...
    for (final kopf in ['Ist', 'Soll', 'Url', 'Sond', 'Firma']) {
      expect(find.text(kopf), findsOneWidget, reason: kopf);
    }
    // ... und der halbe Urlaubstag zählt 0,5 statt wie früher 1.
    expect(find.text('0,5'), findsOneWidget);
    // Sonderurlaub und Firmenurlaub je ein ganzer Tag; Krank/ZA sind leer.
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('–'), findsNWidgets(3));

    await tester.runAsync(db.close);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
