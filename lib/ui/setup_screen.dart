import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';

/// Ersteinrichtung beim allerersten Start. Gefragt wird bewusst NUR der
/// Anzeigename: Zeitexa startet mit Vorgabewerten (Sollstunden,
/// Standardzeiten, Urlaubsanspruch, Anfangsstände) und weist in der
/// Monatsansicht so lange mit einer Hinweiskarte darauf hin, bis der
/// Nutzer seine Werte in der Verwaltung einmal bestätigt hat.
///
/// Ein langes Pflichtformular an dieser Stelle würde der Nutzer ausfüllen,
/// bevor er die App überhaupt gesehen hat – und die dabei geratenen Werte
/// später für richtig halten.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _form = GlobalKey<FormState>();
  final _anzeigename = TextEditingController();
  bool _laeuft = false;

  @override
  void dispose() {
    _anzeigename.dispose();
    super.dispose();
  }

  Future<void> _starten() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _laeuft = true);
    try {
      await ref
          .read(authProvider)
          .ersteinrichtung(anzeigename: _anzeigename.text);
      if (mounted) ref.invalidate(gateStatusProvider);
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lizenzname = ref.watch(brandingProvider).value?.firmenname;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Willkommen bei Zeitexa',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text(
                    'Nur noch eine Angabe, dann kann es losgehen.',
                    textAlign: TextAlign.center,
                  ),
                  if (lizenzname != null && lizenzname.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Freigeschaltet für: $lizenzname',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _anzeigename,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Dein Name',
                      helperText: 'Steht später auf deinen Auswertungen.',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Name angeben' : null,
                    onFieldSubmitted: (_) => _laeuft ? null : _starten(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _laeuft ? null : _starten,
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
      ),
    );
  }
}
