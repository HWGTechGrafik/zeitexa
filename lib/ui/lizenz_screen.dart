import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/lizenz_service.dart';
import '../main.dart';
import 'zeitexa_logo.dart';

/// Erster Schritt beim Start: wird gezeigt, solange keine gültige Lizenz
/// vorliegt. Fragt den Lizenznamen und den Freischaltcode gemeinsam ab; alternativ
/// kann eine signierte Lizenzdatei importiert werden. Erst nach
/// erfolgreicher Freischaltung geht es zur Ersteinrichtung bzw. zum Login.
class LizenzScreen extends ConsumerStatefulWidget {
  const LizenzScreen({super.key});

  @override
  ConsumerState<LizenzScreen> createState() => _LizenzScreenState();
}

class _LizenzScreenState extends ConsumerState<LizenzScreen> {
  final _firma = TextEditingController();
  final _code = TextEditingController();
  bool _laeuft = false;
  bool _firmaVorbefuellt = false;
  String? _fehler;

  @override
  void dispose() {
    _firma.dispose();
    _code.dispose();
    super.dispose();
  }

  /// Lizenzname vorbefüllen, falls das Gerät schon eingerichtet war
  /// (Branding weicht vom Default 'Zeitexa' ab), z.B. nach einem Update.
  void _firmaVorbefuellen(String? gespeichert) {
    if (_firmaVorbefuellt || gespeichert == null) return;
    _firmaVorbefuellt = true;
    if (gespeichert != 'Zeitexa' && _firma.text.isEmpty) {
      _firma.text = gespeichert;
    }
  }

  Future<void> _ergebnisVerarbeiten(LizenzErgebnis ergebnis) async {
    if (ergebnis is LizenzOk) {
      if (mounted) ref.invalidate(gateStatusProvider);
      return;
    }
    setState(() => _fehler = (ergebnis as LizenzFehler).meldung);
  }

  Future<void> _codePruefen() async {
    setState(() {
      _laeuft = true;
      _fehler = null;
    });
    try {
      final ergebnis = await ref
          .read(lizenzProvider)
          .codeEinloesen(_code.text, _firma.text);
      await _ergebnisVerarbeiten(ergebnis);
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  Future<void> _dateiImportieren() async {
    final ergebnis = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = ergebnis?.files.firstOrNull?.bytes;
    if (bytes == null) return;
    setState(() {
      _laeuft = true;
      _fehler = null;
    });
    try {
      final inhalt = utf8.decode(bytes);
      final lizenzErgebnis =
          await ref.read(lizenzProvider).dateiEinloesen(inhalt, _firma.text);
      await _ergebnisVerarbeiten(lizenzErgebnis);
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _firmaVorbefuellen(ref.watch(brandingProvider).value?.firmenname);
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
                Text('Zeitexa freischalten',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text(
                  'Bitte den Namen genau so eingeben, wie ihn der '
                  'Entwickler für den Freischaltcode vorgegeben hat, und '
                  'dann den Code eintippen oder die Lizenzdatei importieren.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _firma,
                  decoration: const InputDecoration(
                    labelText: 'Name des Lizenznehmers',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _code,
                  maxLines: 4,
                  minLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Freischaltcode',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _laeuft ? null : _codePruefen,
                  child: _laeuft
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Code prüfen & freischalten'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.file_open_outlined),
                  label: const Text('Lizenzdatei importieren'),
                  onPressed: _laeuft ? null : _dateiImportieren,
                ),
                if (_fehler != null) ...[
                  const SizedBox(height: 16),
                  Text(_fehler!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
