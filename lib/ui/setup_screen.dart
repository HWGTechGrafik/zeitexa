import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import 'zeitexa_logo.dart';

/// Willkommensbildschirm nach der Freischaltung. Gefragt wird nichts mehr:
/// Der Name kommt aus der Lizenz (die gilt genau für diese Person), alle
/// Zeit- und Urlaubswerte starten mit Vorgaben. Die Monatsansicht weist mit
/// einer Hinweiskarte darauf hin, bis der Nutzer seine Werte in der
/// Verwaltung einmal bestätigt hat.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  bool _laeuft = false;

  Future<void> _starten(String lizenzname) async {
    setState(() => _laeuft = true);
    try {
      await ref.read(authProvider).ersteinrichtung(anzeigename: lizenzname);
      if (mounted) ref.invalidate(gateStatusProvider);
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branding = ref.watch(brandingProvider).value;
    if (branding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final lizenzname = branding.firmenname;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: ZeitexaLogo()),
                const SizedBox(height: 16),
                Text('Willkommen bei Zeitexa',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text(
                  'Die Freischaltung hat geklappt. Diese Lizenz gilt für:',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  lizenzname,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _laeuft ? null : () => _starten(lizenzname),
                  child: _laeuft
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Los geht’s'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Arbeitszeiten, Urlaubsanspruch und Anfangsstände '
                  'stellst du gleich danach selbst in der Verwaltung ein.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
