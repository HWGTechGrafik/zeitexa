import 'package:flutter/material.dart';

import '../version.dart';

/// „Über Zeitexa"-Dialog. Der frühere versteckte Entwickler-Bereich
/// (7× Tippen auf die Version) ist entfallen: In der Einzelnutzer-Version
/// pflegt der Nutzer alles selbst in der Verwaltung, und der Name kommt
/// aus der Lizenz.
Future<void> zeigeUeberDialog(BuildContext context) async {
  // Version fest aus dem Code (lib/version.dart), damit sie auf jeder
  // Plattform sofort und offline erscheint. Frueher las package_info_plus
  // sie auf Web ueber eine Netz-Abfrage, die in der iOS-PWA fehlschlug und
  // „unbekannt" zeigte.
  const appVersion = kAppVersion;
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
          Text('Version $appVersion',
              style: Theme.of(dialogContext).textTheme.bodySmall),
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
