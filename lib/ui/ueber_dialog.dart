import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../version.dart';
import 'branding_screen.dart';

/// „Über Zeitexa"-Dialog. 7× Tippen auf die Versionsnummer öffnet den
/// versteckten Entwickler-/Branding-Bereich (nach Passwortabfrage).
Future<void> zeigeUeberDialog(BuildContext context, WidgetRef ref) async {
  // Version fest aus dem Code (lib/version.dart), damit sie auf jeder
  // Plattform sofort und offline erscheint. Frueher las package_info_plus
  // sie auf Web ueber eine Netz-Abfrage, die in der iOS-PWA fehlschlug und
  // „unbekannt" zeigte.
  const appVersion = kAppVersion;
  var tipps = 0;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Über Zeitexa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Offline-Stundenerfassung.'),
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              tipps++;
              if (tipps >= 7) {
                Navigator.pop(dialogContext);
                await _brandingZugang(context, ref);
              }
            },
            child: Text('Version $appVersion',
                style: Theme.of(dialogContext).textTheme.bodySmall),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Schließen')),
      ],
    ),
  );
}

Future<void> _brandingZugang(BuildContext context, WidgetRef ref) async {
  final passwort = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Entwickler-Bereich'),
      content: TextField(
        controller: passwort,
        obscureText: true,
        autofocus: true,
        decoration: const InputDecoration(
            labelText: 'Entwickler-Passwort',
            helperText: 'Wird über die Lizenzdatei des Entwicklers gesetzt'),
        onSubmitted: (_) => Navigator.pop(context, true),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen')),
        FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Öffnen')),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final stimmt =
      await ref.read(authProvider).pruefeBrandingPasswort(passwort.text);
  if (!context.mounted) return;
  if (!stimmt) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Passwort falsch.')));
    return;
  }
  await Navigator.push(
      context, MaterialPageRoute(builder: (_) => const BrandingScreen()));
}
