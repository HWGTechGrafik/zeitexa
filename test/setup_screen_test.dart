import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/main.dart';
import 'package:zeitexa/ui/setup_screen.dart';

/// Der Branding-Stream der echten Datenbank haelt im Test einen Timer
/// offen; deshalb wird er mit einem festen Wert ueberschrieben. Der
/// Willkommensbildschirm liest daraus den Lizenznamen.
Widget _app(ZeitexaDb db) => ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        brandingProvider.overrideWith((ref) => Stream.value(const Branding(
              id: 1,
              firmenname: 'Max Muster',
              adresse: '',
              telefon: '',
              email: '',
              akzentFarbe: 0xFF1565C0,
            ))),
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
  testWidgets('Willkommensbildschirm zeigt den Lizenznamen und fragt nichts ab',
      (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_app(db));
    await _pumpe(tester);

    expect(find.text('Willkommen bei Zeitexa'), findsOneWidget);
    expect(find.text('Max Muster'), findsOneWidget);
    // Kein Namensfeld, kein Login, kein Adminpasswort.
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('Passwort'), findsNothing);
  });

  testWidgets('„Los geht’s" legt genau ein Profil mit dem Lizenznamen an',
      (tester) async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_app(db));
    await _pumpe(tester);

    await tester.tap(find.text('Los geht’s'));
    await _pumpe(tester);

    final users = await db.allUsers();
    expect(users, hasLength(1));
    expect(users.single.displayName, 'Max Muster');
    // Die Werte sind noch ungeprüft – die Hinweiskarte muss erscheinen.
    expect(await db.getBoolSetting(SettingsKeys.einstellungenGeprueft),
        isFalse);
  });
}
