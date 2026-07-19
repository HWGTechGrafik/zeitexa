import 'package:flutter/material.dart';

/// Das Produktzeichen von Zeitexa (dieselbe Sanduhr wie das App-Symbol auf
/// dem Startmenü bzw. Homescreen). Steht auf den Bildschirmen vor dem
/// eigentlichen Betrieb – Freischaltung und Willkommen –, damit auf jedem
/// Gerät sofort erkennbar ist, welches Programm gerade läuft.
class ZeitexaLogo extends StatelessWidget {
  const ZeitexaLogo({super.key, this.groesse = 88});

  final double groesse;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/zeitexa_logo.png',
      width: groesse,
      height: groesse,
      // Fehlt das Bild (z.B. in einem Widget-Test ohne Assets), bleibt der
      // Bildschirm benutzbar statt mit einem roten Fehlerfeld zu brechen.
      errorBuilder: (context, error, stack) =>
          Icon(Icons.hourglass_bottom, size: groesse * 0.7),
    );
  }
}
