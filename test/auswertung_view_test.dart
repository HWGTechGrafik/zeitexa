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
      'Auswertung entsteht automatisch aus den eigenen Einträgen '
      '(Diagramme + eine Tabellenzeile je Monat, kein Import)',
      (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());

    final userId = await db.into(db.users).insert(UsersCompanion.insert(
          username: 'max',
          passwordHash: 'hash',
          displayName: 'Max Mustermann',
        ));
    await db.settingsFor(userId); // Standardwerte anlegen
    await (db.update(db.userSettings)..where((t) => t.userId.equals(userId)))
        .write(const UserSettingsCompanion(
      sollModus: Value(SollModus.gleich),
      sollStundenTag: Value(8),
    ));

    // Ein Arbeitstag mit Überstunden (07:00–16:00, 30 min Pause = 8,5 h bei
    // Soll 8), ein halber Urlaubstag, ein Sonderurlaub und ein Firmenurlaub
    // (Mo 13.7. bis Do 16.7.2026).
    await db.upsertEntry(TimeEntriesCompanion.insert(
      userId: userId,
      datum: DateTime(2026, 7, 13),
      tagesart: Tagesart.arbeit,
      beginnMin: const Value(420),
      pauseMin: const Value(30),
      endeMin: const Value(960),
    ));
    await db.upsertEntry(TimeEntriesCompanion.insert(
      userId: userId,
      datum: DateTime(2026, 7, 14),
      tagesart: Tagesart.urlaub,
      urlaubMinuten: const Value(240), // halber Tag bei 8 h Soll
    ));
    await db.upsertEntry(TimeEntriesCompanion.insert(
      userId: userId,
      datum: DateTime(2026, 7, 15),
      tagesart: Tagesart.sonderurlaub,
      sonderurlaubGrund: const Value(SonderurlaubGrund.todesfall),
    ));
    await db.upsertEntry(TimeEntriesCompanion.insert(
      userId: userId,
      datum: DateTime(2026, 7, 16),
      tagesart: Tagesart.firmenurlaub,
    ));

    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: const MaterialApp(home: AuswertungView()),
    ));
    // Drift-Zugriff ist echte Async-I/O: erst lädt _lade (initState)
    // Profil und Sollregel, dann liefert der Eintrags-Stream – dazwischen
    // braucht es jeweils einen Pump.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();
    }

    // Die eigene Karte erscheint direkt – ohne Import-Knopf.
    expect(find.text('Max Mustermann'), findsOneWidget);
    expect(find.text('JSON-Dateien importieren'), findsNothing);

    // Beide Diagramme sind da.
    expect(find.text('Überstunden je Monat'), findsOneWidget);
    expect(find.text('Ist gegen Soll je Monat'), findsOneWidget);

    // Genau EINE Tabellenzeile für den Monat (die Monatsspalte links).
    expect(find.text('2026-07'), findsOneWidget);
    expect(find.text('Monat'), findsOneWidget);

    // Die Spalten haben eigene Köpfe ...
    for (final kopf in ['Ist', 'Soll', 'Url', 'Sond', 'Firma']) {
      expect(find.text(kopf), findsOneWidget, reason: kopf);
    }
    // ... und der halbe Urlaubstag zählt 0,5.
    expect(find.text('0,5'), findsOneWidget);
    // Sonderurlaub und Firmenurlaub je ein ganzer Tag; Krank/ZA/Feiertage leer.
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('–'), findsNWidgets(3));

    await tester.runAsync(db.close);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
