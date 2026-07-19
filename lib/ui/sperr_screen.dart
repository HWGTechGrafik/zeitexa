import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';

/// Wird nur angezeigt, wenn die optionale App-Sperre eingeschaltet ist
/// (Verwaltung → Optionen). Standardmäßig ist sie aus, dann startet Zeitexa
/// direkt in die Monatsansicht.
class SperrScreen extends ConsumerStatefulWidget {
  const SperrScreen({super.key, required this.user});

  final User user;

  @override
  ConsumerState<SperrScreen> createState() => _SperrScreenState();
}

class _SperrScreenState extends ConsumerState<SperrScreen> {
  final _passwort = TextEditingController();
  bool _laeuft = false;
  String? _fehler;
  bool _biometrieMoeglich = false;

  @override
  void initState() {
    super.initState();
    ref
        .read(biometrieProvider)
        .entsperrenMoeglich(widget.user.id)
        .then((moeglich) {
      if (!mounted || !moeglich) return;
      setState(() => _biometrieMoeglich = true);
      _perBiometrie();
    });
  }

  @override
  void dispose() {
    _passwort.dispose();
    super.dispose();
  }

  void _entsperren() => ref.read(entsperrtProvider.notifier).freigeben();

  Future<void> _perPasswort() async {
    setState(() {
      _laeuft = true;
      _fehler = null;
    });
    final ok = await ref.read(authProvider).pruefeAppSperre(_passwort.text);
    if (!mounted) return;
    setState(() => _laeuft = false);
    if (ok) {
      _entsperren();
    } else {
      setState(() => _fehler = 'Passwort falsch.');
    }
  }

  Future<void> _perBiometrie() async {
    final ok = await ref
        .read(biometrieProvider)
        .authentifizieren('Zeitexa entsperren');
    if (mounted && ok) _entsperren();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                Text('Zeitexa ist gesperrt',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwort,
                  obscureText: true,
                  autofocus: !_biometrieMoeglich,
                  decoration: InputDecoration(
                    labelText: 'Passwort',
                    errorText: _fehler,
                  ),
                  onSubmitted: (_) => _laeuft ? null : _perPasswort(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _laeuft ? null : _perPasswort,
                  child: const Text('Entsperren'),
                ),
                if (_biometrieMoeglich) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _laeuft ? null : _perBiometrie,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Mit Fingerabdruck entsperren'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
