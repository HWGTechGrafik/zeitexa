import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import 'benutzer_datei.dart';

/// Ersteinrichtung beim allerersten Start: Adminpasswort und das erste
/// Benutzerprofil (der Chef). Das Entwickler-/Branding-Passwort wird NICHT
/// hier festgelegt - es kommt aus der importierten Lizenzdatei.
///
/// Statt alles einzutippen kann der Chef eine Benutzerdatei einspielen, die
/// er an seinem Rechner exportiert hat (Chef-Bereich → Benutzer übertragen).
/// Bringt sie das Adminpasswort mit (Dateiversion 2), ist die Einrichtung
/// damit fertig und es geht direkt zum Login; bei älteren Dateien bleibt
/// nur noch das Adminpasswort auszufüllen.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _form = GlobalKey<FormState>();
  final _admin = TextEditingController();
  final _adminWdh = TextEditingController();
  final _username = TextEditingController();
  final _anzeigename = TextEditingController();
  final _passwort = TextEditingController();
  bool _laeuft = false;

  /// Wie viele Benutzer aus einer Datei übernommen wurden; > 0 blendet den
  /// Abschnitt „Dein Benutzerprofil" aus.
  int _uebernommen = 0;
  String? _importFehler;

  @override
  void dispose() {
    for (final c in [
      _admin,
      _adminWdh,
      _username,
      _anzeigename,
      _passwort
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Übernimmt eine Benutzerdatei. Bringt sie das Adminpasswort mit, ist das
  /// Gerät sofort eingerichtet und das StartGate zeigt den Login.
  Future<void> _dateiUebernehmen() async {
    final inhalt = await waehleBenutzerdatei();
    if (inhalt == null || !mounted) return;
    setState(() {
      _laeuft = true;
      _importFehler = null;
    });
    try {
      final r = await ref
          .read(benutzerTransferProvider)
          .importiere(inhalt, adminPasswortUebernehmen: true);
      if (!mounted) return;
      if (r.adminGesetzt) {
        // Fertig: istEingerichtet() ist jetzt true.
        ref.invalidate(gateStatusProvider);
        return;
      }
      setState(() => _uebernommen = r.neu + r.aktualisiert);
    } on FormatException catch (e) {
      if (mounted) setState(() => _importFehler = e.message);
    } catch (e) {
      if (mounted) setState(() => _importFehler = '$e');
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  Future<void> _speichern() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _laeuft = true);
    try {
      final auth = ref.read(authProvider);
      if (_uebernommen > 0) {
        // Benutzer kamen aus der Datei – es fehlt nur das Adminpasswort.
        await auth.setzeAdminPasswort(_admin.text);
        if (mounted) ref.invalidate(gateStatusProvider);
        return;
      }
      final user = await auth.ersteinrichtung(
        adminPasswort: _admin.text,
        username: _username.text,
        anzeigename: _anzeigename.text,
        benutzerPasswort: _passwort.text,
      );
      if (mounted) {
        ref.read(angemeldeterUserProvider.notifier).anmelden(user);
        ref.invalidate(gateStatusProvider);
      }
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firmenname = ref.watch(brandingProvider).value?.firmenname;
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
                  Text('Zeitexa einrichten',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text(
                    'Diese Einrichtung machst du nur einmal pro Gerät.',
                    textAlign: TextAlign.center,
                  ),
                  if (firmenname != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Freigeschaltet für: $firmenname',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Schon ein Gerät eingerichtet?',
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          const Text(
                            'Dann übernimm die Benutzerdatei, die du im '
                            'Chef-Bereich exportiert hast – damit sind alle '
                            'Mitarbeiter samt Passwörtern sofort da.',
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _laeuft ? null : _dateiUebernehmen,
                            icon: const Icon(Icons.file_open_outlined),
                            label: const Text('Benutzerdatei übernehmen…'),
                          ),
                          if (_uebernommen > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '$_uebernommen Benutzer übernommen. Diese '
                                'Datei enthält kein Adminpasswort – bitte '
                                'unten noch eines vergeben.',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary),
                              ),
                            ),
                          if (_importFehler != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Import fehlgeschlagen: $_importFehler',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('1. Adminpasswort (Chef-Bereich)',
                      style: Theme.of(context).textTheme.titleMedium),
                  TextFormField(
                    controller: _admin,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Adminpasswort'),
                    validator: (v) => (v == null || v.length < 4)
                        ? 'Mindestens 4 Zeichen'
                        : null,
                  ),
                  TextFormField(
                    controller: _adminWdh,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Adminpasswort wiederholen'),
                    validator: (v) =>
                        v != _admin.text ? 'Passwörter stimmen nicht überein' : null,
                  ),
                  // Nur nötig, wenn die Benutzer NICHT aus einer Datei kamen.
                  if (_uebernommen == 0) ...[
                    const SizedBox(height: 24),
                    Text('2. Dein Benutzerprofil',
                        style: Theme.of(context).textTheme.titleMedium),
                    TextFormField(
                      controller: _username,
                      decoration:
                          const InputDecoration(labelText: 'Benutzername'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Benutzername angeben'
                          : null,
                    ),
                    TextFormField(
                      controller: _anzeigename,
                      decoration: const InputDecoration(
                          labelText: 'Anzeigename (z.B. Vor- und Nachname)'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Anzeigename angeben'
                          : null,
                    ),
                    TextFormField(
                      controller: _passwort,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Dein Passwort'),
                      validator: (v) => (v == null || v.length < 4)
                          ? 'Mindestens 4 Zeichen'
                          : null,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _laeuft ? null : _speichern,
                    child: _laeuft
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Einrichten und starten'),
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
