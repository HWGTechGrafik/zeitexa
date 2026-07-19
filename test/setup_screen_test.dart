import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/main.dart';
import 'package:zeitexa/ui/setup_screen.dart';

/// Der Branding-Stream der echten Datenbank haelt im Test einen Timer
/// offen; fuer die Ersteinrichtung wird er nicht gebraucht.
Widget _app(ZeitexaDb db) => ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        brandingProvider.overrideWith((ref) => const Stream<Branding>.empty()),
      ],
      child: const MaterialApp(home: SetupScreen()),
    );

/// Ein paar Frames zeichnen, ohne auf Datenbank-Streams zu warten.
Future<void> _pumpe(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('Ersteinrichtung fragt nur nach dem Namen', (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_app(db));
    await _pumpe(tester);

    expect(find.text('Willkommen bei Zeitexa'), findsOneWidget);
    expect(find.text('Dein Name'), findsOneWidget);
    // Kein Login, kein Adminpasswort, keine Benutzerverwaltung.
    expect(find.textContaining('Benutzername'), findsNothing);
    expect(find.textContaining('Adminpasswort'), findsNothing);
    expect(find.textContaining('Passwort'), findsNothing);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('nach dem Anlegen existiert genau ein Profil', (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_app(db));
    await _pumpe(tester);

    await tester.enterText(find.byType(TextFormField), 'Max Muster');
    await tester.tap(find.text('Los geht’s'));
    await _pumpe(tester);

    final users = await db.allUsers();
    expect(users, hasLength(1));
    expect(users.single.displayName, 'Max Muster');
    // Die Werte sind noch ungeprüft – die Hinweiskarte muss erscheinen.
    expect(await db.getBoolSetting(SettingsKeys.einstellungenGeprueft),
        isFalse);
  });

  testWidgets('ohne Namen wird nichts angelegt', (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_app(db));
    await _pumpe(tester);

    await tester.tap(find.text('Los geht’s'));
    await _pumpe(tester);

    expect(find.text('Name angeben'), findsOneWidget);
    expect(await db.allUsers(), isEmpty);
  });
}
