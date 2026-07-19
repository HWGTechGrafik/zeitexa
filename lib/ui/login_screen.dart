import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../logic/auth.dart';
import '../main.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _username = TextEditingController();
  final _passwort = TextEditingController();
  String? _fehler;
  bool _laeuft = false;
  bool _registrierungErlaubt = false;
  List<User> _biometrieBenutzer = const [];

  @override
  void initState() {
    super.initState();
    ref
        .read(dbProvider)
        .getBoolSetting(SettingsKeys.selbstRegistrierungErlaubt)
        .then((v) {
      if (mounted) setState(() => _registrierungErlaubt = v);
    });
    ref.read(biometrieProvider).benutzerMitBiometrie().then((benutzer) {
      if (mounted) setState(() => _biometrieBenutzer = benutzer);
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _passwort.dispose();
    super.dispose();
  }

  Future<void> _anmelden() async {
    setState(() {
      _laeuft = true;
      _fehler = null;
    });
    final ergebnis =
        await ref.read(authProvider).login(_username.text, _passwort.text);
    if (!mounted) return;
    switch (ergebnis) {
      case LoginOk(:final user):
        if (user.mustChangePassword) {
          final geaendert = await _passwortWechselDialog(user);
          if (!geaendert || !mounted) {
            setState(() => _laeuft = false);
            return;
          }
          final aktualisiert =
              await ref.read(dbProvider).userByName(user.username);
          if (mounted && aktualisiert != null) {
            ref.read(angemeldeterUserProvider.notifier).anmelden(aktualisiert);
          }
        } else {
          ref.read(angemeldeterUserProvider.notifier).anmelden(user);
        }
      case LoginFehler(:final meldung):
        setState(() {
          _fehler = meldung;
          _laeuft = false;
        });
    }
  }

  /// Anmeldung per Fingerabdruck/Gesicht (Windows Hello, Android-Biometrie).
  Future<void> _biometrischAnmelden(User user) async {
    setState(() => _fehler = null);
    final ok = await ref
        .read(biometrieProvider)
        .authentifizieren('Anmeldung als ${user.displayName}');
    if (!ok || !mounted) return;
    // Benutzer frisch laden (Passwort/Flags koennten sich geaendert haben).
    final aktuell = await ref.read(dbProvider).userByName(user.username);
    if (!mounted) return;
    if (aktuell == null) {
      setState(() => _fehler = 'Benutzer existiert nicht mehr.');
      return;
    }
    if (aktuell.mustChangePassword) {
      setState(() => _fehler =
          'Bitte einmal mit Passwort anmelden (Passwortwechsel erforderlich).');
      return;
    }
    ref.read(angemeldeterUserProvider.notifier).anmelden(aktuell);
  }

  /// Erzwungener Passwortwechsel beim ersten Login.
  Future<bool> _passwortWechselDialog(User user) async {
    final neu = TextEditingController();
    final wdh = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Neues Passwort festlegen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bitte lege beim ersten Login dein eigenes Passwort fest.'),
            TextField(
                controller: neu,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Neues Passwort')),
            TextField(
                controller: wdh,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Wiederholen')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              if (neu.text.length >= 4 && neu.text == wdh.text) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authProvider).passwortAendern(user.id, neu.text);
      return true;
    }
    return false;
  }

  Future<void> _passwortVergessen() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passwort vergessen'),
        content: const Text(
            'Bitte wende dich an deinen Chef – er kann dein Passwort im '
            'Chef-Bereich zurücksetzen.'),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Verstanden')),
        ],
      ),
    );
  }

  Future<void> _registrieren() async {
    final username = TextEditingController();
    final anzeigename = TextEditingController();
    final passwort = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrieren'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: username,
                  decoration: const InputDecoration(labelText: 'Benutzername'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Angeben' : null),
              TextFormField(
                  controller: anzeigename,
                  decoration: const InputDecoration(labelText: 'Anzeigename'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Angeben' : null),
              TextFormField(
                  controller: passwort,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Passwort'),
                  validator: (v) =>
                      (v == null || v.length < 4) ? 'Mind. 4 Zeichen' : null),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Registrieren')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final user = await ref.read(authProvider).benutzerAnlegen(
            username: username.text,
            anzeigename: anzeigename.text,
            passwort: passwort.text,
          );
      if (mounted) {
        ref.read(angemeldeterUserProvider.notifier).anmelden(user);
      }
    } on ArgumentError catch (e) {
      if (mounted) setState(() => _fehler = e.message as String);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branding = ref.watch(brandingProvider).value;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.punch_clock_outlined,
                    size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  branding?.firmenname.isNotEmpty == true
                      ? branding!.firmenname
                      : 'Zeitexa',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text('Stundenerfassung',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                TextField(
                  controller: _username,
                  autofocus: true,
                  decoration: const InputDecoration(
                      labelText: 'Benutzername',
                      prefixIcon: Icon(Icons.person_outline)),
                  onSubmitted: (_) => _anmelden(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwort,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Passwort',
                      prefixIcon: Icon(Icons.lock_outline)),
                  onSubmitted: (_) => _anmelden(),
                ),
                if (_fehler != null) ...[
                  const SizedBox(height: 12),
                  Text(_fehler!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _laeuft ? null : _anmelden,
                  child: _laeuft
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Anmelden'),
                ),
                if (_biometrieBenutzer.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('oder',
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 8),
                  for (final user in _biometrieBenutzer)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.fingerprint),
                        label: Text('Als ${user.displayName} anmelden'),
                        onPressed:
                            _laeuft ? null : () => _biometrischAnmelden(user),
                      ),
                    ),
                ],
                TextButton(
                    onPressed: _passwortVergessen,
                    child: const Text('Passwort vergessen?')),
                if (_registrierungErlaubt)
                  TextButton(
                      onPressed: _registrieren,
                      child: const Text('Neu hier? Registrieren')),
                const SizedBox(height: 24),
                Text(
                  'Bereitgestellt von HWG.Tech',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
