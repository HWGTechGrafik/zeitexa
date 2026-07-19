import 'package:flutter_test/flutter_test.dart';

import 'package:lizenz_gui/main.dart';

void main() {
  testWidgets('Startbildschirm zeigt Eingabefeld und Erzeugen-Button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LizenzGuiApp());

    expect(find.text('Firmenname'), findsOneWidget);
    expect(find.text('Code erzeugen'), findsOneWidget);
  });
}
