import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/main.dart';
import 'package:zeitexa/ui/eintrag_dialog.dart';

/// Legt einen Benutzer samt Einstellungen an.
Future<User> _benutzer(
  ZeitexaDb db, {
  bool firmenurlaubAktiv = false,
  int? beginnFr,
  int? endeFr,
  int? pauseFr,
}) async {
  final id = await db.into(db.users).insert(UsersCompanion.insert(
      username: 'max', passwordHash: 'x', displayName: 'Max'));
  await db.into(db.userSettings).insert(UserSettingsCompanion.insert(
        userId: Value(id),
        sollModus: SollModus.moDoFrGetrennt,
        sollStundenMoDo: const Value(8),
        sollStundenFr: const Value(5),
        standardBeginnMin: const Value(7 * 60),
        standardEndeMin: const Value(16 * 60),
        standardPauseMin: const Value(30),
        standardBeginnFrMin: Value(beginnFr),
        standardEndeFrMin: Value(endeFr),
        standardPauseFrMin: Value(pauseFr),
        firmenurlaubAktiv: Value(firmenurlaubAktiv),
      ));
  return (db.select(db.users)..where((t) => t.id.equals(id))).getSingle();
}

/// Öffnet den Eintragsdialog für [datum] und wartet, bis die Einstellungen
/// geladen sind (Drift ist echte Async-I/O).
///
/// Der Dialog ist hoch – die Standard-Testfläche (800x600) würde die
/// Tagesart-Chips abschneiden, deshalb wird sie vergrößert.
Future<void> _oeffne(
  WidgetTester tester,
  ZeitexaDb db,
  User user,
  DateTime datum,
) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [dbProvider.overrideWithValue(db)],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () =>
                  showEintragDialog(context, ref, user: user, datum: datum),
              child: const Text('öffnen'),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('öffnen'));
  await tester.pump();
  await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  // 2026-07-13 = Montag, 2026-07-17 = Freitag
  final montag = DateTime(2026, 7, 13);
  final freitag = DateTime(2026, 7, 17);

  testWidgets('Urlaub ist mit dem Tagessoll vorbelegt; weniger blendet die '
      'Arbeitszeiten ein', (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    final user = await _benutzer(db);
    await _oeffne(tester, db, user, montag);

    await tester.tap(find.text('Urlaub'));
    await tester.pump();

    // Ganzer Tag = 8 h Soll am Montag.
    final feld = find.widgetWithText(
        TextField, '8'); // Controllertext des Urlaubsstunden-Felds
    expect(feld, findsOneWidget);
    // Solange der volle Tag drinsteht, gibt es keine Arbeitszeiten.
    expect(find.textContaining('Beginn'), findsNothing);

    // Teil-Urlaub eintragen → Beginn/Ende/Pause erscheinen.
    await tester.enterText(feld, '6,25');
    await tester.pump();
    expect(find.textContaining('Beginn'), findsOneWidget);
    expect(find.textContaining('Pause'), findsOneWidget);

    await tester.runAsync(db.close);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('Sonderurlaub blendet die Grund-Auswahl ein', (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    final user = await _benutzer(db);
    await _oeffne(tester, db, user, montag);

    expect(find.text('Grund'), findsNothing);
    await tester.tap(find.text('Sonderurlaub'));
    await tester.pump();

    expect(find.text('Grund'), findsOneWidget);
    await tester.tap(find.text('Grund'));
    await tester.pumpAndSettle();
    expect(find.text('Pflegefreistellung'), findsWidgets);
    expect(find.text('Todesfall'), findsWidgets);

    await tester.runAsync(db.close);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('ohne aktives Konto fehlt der Firmenurlaub-Chip',
      (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    await _oeffne(tester, db, await _benutzer(db), montag);
    expect(find.text('Firmenurlaub'), findsNothing);
    await tester.runAsync(db.close);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('mit aktivem Konto ist der Firmenurlaub-Chip wählbar',
      (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    await _oeffne(
        tester, db, await _benutzer(db, firmenurlaubAktiv: true), montag);
    expect(find.text('Firmenurlaub'), findsOneWidget);
    await tester.tap(find.text('Firmenurlaub'));
    await tester.pump();
    // Auch hier gibt es das Stunden-Feld (Urlaubsanteil des Tages).
    expect(find.textContaining('Firmenurlaub (Stunden an diesem Tag)'),
        findsOneWidget);
    await tester.runAsync(db.close);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('Freitag zieht die eigenen Standardzeiten', (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    // Fr 07:00–12:00 ohne Pause.
    final user =
        await _benutzer(db, beginnFr: 7 * 60, endeFr: 12 * 60, pauseFr: 0);
    await _oeffne(tester, db, user, freitag);
    expect(find.text('Ende 12:00'), findsOneWidget);
    expect(find.text('Pause 00:00'), findsOneWidget);
    await tester.runAsync(db.close);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('Mo–Do bleibt bei den normalen Standardzeiten', (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    final user =
        await _benutzer(db, beginnFr: 7 * 60, endeFr: 12 * 60, pauseFr: 0);
    await _oeffne(tester, db, user, montag);
    expect(find.text('Ende 16:00'), findsOneWidget);
    expect(find.text('Pause 00:30'), findsOneWidget);
    await tester.runAsync(db.close);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
