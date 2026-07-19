import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/logic/biometrie_service.dart';
import 'package:zeitexa/main.dart';
import 'package:zeitexa/ui/login_screen.dart';

void main() {
  testWidgets('Passwort-vergessen-Hinweis am Login-Screen', (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        biometrieProvider.overrideWithValue(BiometrieService(
          db,
          authentifizierer: (_) async => false,
          geraeteCheck: () async => false,
        )),
      ],
      child: const MaterialApp(home: LoginScreen()),
    ));
    // Drift-Zugriffe aus initState sind echte Async-I/O; nur hier kurz in
    // Echtzeit warten, damit sie abgeschlossen sind.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();

    // Anbieter-Hinweis in der Fußzeile.
    expect(find.text('Bereitgestellt von HWG.Tech'), findsOneWidget);

    expect(find.text('Passwort vergessen?'), findsOneWidget);
    await tester.tap(find.text('Passwort vergessen?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Passwort vergessen'), findsOneWidget);
    expect(find.textContaining('Chef-Bereich zurücksetzen'), findsOneWidget);

    await tester.tap(find.text('Verstanden'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Passwort vergessen'), findsNothing);

    // Schliessen ist ebenfalls echte Async-I/O - nicht per addTearDown
    // (haengt in der FakeAsync-Zone), sondern hier in Echtzeit.
    await tester.runAsync(db.close);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
