import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../logic/auth.dart';
import '../logic/berechnung.dart';
import '../main.dart';
import 'standardzeiten_felder.dart';

/// Minuten seit Mitternacht ↔ [TimeOfDay]; null bleibt null (bei den
/// Freitagszeiten heißt das „wie Mo–Do").
TimeOfDay? _tod(int? minuten) => minuten == null
    ? null
    : TimeOfDay(hour: minuten ~/ 60, minute: minuten % 60);

int? _min(TimeOfDay? zeit) =>
    zeit == null ? null : zeit.hour * 60 + zeit.minute;

/// Persönliche Einstellungen: Passwort ändern, Sollstunden nur lesbar
/// (ändern kann sie nur der Admin im Chef-Bereich).
class EinstellungenScreen extends ConsumerStatefulWidget {
  final User user;
  const EinstellungenScreen({super.key, required this.user});

  @override
  ConsumerState<EinstellungenScreen> createState() =>
      _EinstellungenScreenState();
}

class _EinstellungenScreenState extends ConsumerState<EinstellungenScreen> {
  UserSetting? _einstellungen;
  bool _biometrieVerfuegbar = false;
  bool _biometrieAktiv = false;
  bool _heuteOeffnetEintrag = false;
  TimeOfDay _standardBeginn = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _standardEnde = const TimeOfDay(hour: 16, minute: 0);
  int _standardPauseMin = 30;
  TimeOfDay? _standardBeginnFr;
  TimeOfDay? _standardEndeFr;
  int? _standardPauseFrMin;

  @override
  void initState() {
    super.initState();
    ref.read(dbProvider).settingsFor(widget.user.id).then((s) {
      if (mounted) {
        setState(() {
          _einstellungen = s;
          _standardBeginn =
              TimeOfDay(hour: s.standardBeginnMin ~/ 60, minute: s.standardBeginnMin % 60);
          _standardEnde =
              TimeOfDay(hour: s.standardEndeMin ~/ 60, minute: s.standardEndeMin % 60);
          _standardPauseMin = s.standardPauseMin;
          _standardBeginnFr = _tod(s.standardBeginnFrMin);
          _standardEndeFr = _tod(s.standardEndeFrMin);
          _standardPauseFrMin = s.standardPauseFrMin;
        });
      }
    });
    _ladeBiometrie();
    // Zeigt die eigene Wahl bzw. – solange keine getroffen wurde – die
    // Vorgabe des Chefs (Chef-Bereich → Mail & Optionen).
    ref.read(dbProvider).heuteOeffnetEintragFuer(widget.user.id).then((v) {
      if (mounted) setState(() => _heuteOeffnetEintrag = v);
    });
  }

  Future<void> _heuteOptionUmschalten(bool aktiv) async {
    await ref.read(dbProvider).setBoolSetting(
        SettingsKeys.heuteOeffnetEintrag(widget.user.id), aktiv);
    if (mounted) setState(() => _heuteOeffnetEintrag = aktiv);
  }

  Future<void> _standardzeitenSpeichern() async {
    final db = ref.read(dbProvider);
    await (db.update(db.userSettings)
          ..where((t) => t.userId.equals(widget.user.id)))
        .write(UserSettingsCompanion(
      standardBeginnMin:
          Value(_standardBeginn.hour * 60 + _standardBeginn.minute),
      standardEndeMin: Value(_standardEnde.hour * 60 + _standardEnde.minute),
      standardPauseMin: Value(_standardPauseMin),
      standardBeginnFrMin: Value(_min(_standardBeginnFr)),
      standardEndeFrMin: Value(_min(_standardEndeFr)),
      standardPauseFrMin: Value(_standardPauseFrMin),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gespeichert.')));
    }
  }

  Future<void> _ladeBiometrie() async {
    final biometrie = ref.read(biometrieProvider);
    final verfuegbar =
        await biometrie.geraetUnterstuetzt() && await biometrie.istErlaubt();
    final aktiv = await biometrie.istAktiviertFuer(widget.user.id);
    if (mounted) {
      setState(() {
        _biometrieVerfuegbar = verfuegbar;
        _biometrieAktiv = aktiv;
      });
    }
  }

  Future<void> _biometrieUmschalten(bool aktivieren) async {
    final biometrie = ref.read(biometrieProvider);
    if (aktivieren) {
      // Erst per Biometrie bestaetigen, damit sie nachweislich funktioniert.
      final ok = await biometrie
          .authentifizieren('Biometrische Anmeldung aktivieren');
      if (!ok) return;
      await biometrie.aktivierenFuer(widget.user.id);
    } else {
      await biometrie.deaktivierenFuer(widget.user.id);
    }
    if (mounted) setState(() => _biometrieAktiv = aktivieren);
  }

  Future<void> _passwortAendern() async {
    final alt = TextEditingController();
    final neu = TextEditingController();
    final wdh = TextEditingController();
    String? fehler;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Passwort ändern'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: alt,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Aktuelles Passwort')),
              TextField(
                  controller: neu,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Neues Passwort')),
              TextField(
                  controller: wdh,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Wiederholen')),
              if (fehler != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(fehler!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Abbrechen')),
            FilledButton(
              onPressed: () async {
                final auth = ref.read(authProvider);
                final aktuell = await ref
                    .read(dbProvider)
                    .userByName(widget.user.username);
                if (aktuell == null ||
                    !AuthService.pruefe(alt.text, aktuell.passwordHash)) {
                  setDialogState(() => fehler = 'Aktuelles Passwort falsch.');
                  return;
                }
                if (neu.text.length < 4 || neu.text != wdh.text) {
                  setDialogState(() =>
                      fehler = 'Neues Passwort ungültig oder stimmt nicht überein.');
                  return;
                }
                await auth.passwortAendern(widget.user.id, neu.text);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _einstellungen;
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Passwort ändern'),
              onTap: _passwortAendern,
            ),
          ),
          if (_biometrieVerfuegbar)
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Anmeldung per Fingerabdruck/Gesicht'),
                subtitle: const Text(
                    'Ohne Passwort anmelden. Achtung: Jede an diesem Gerät '
                    'hinterlegte Biometrie (z.B. weitere Fingerabdrücke) '
                    'kann sich dann als du anmelden.'),
                value: _biometrieAktiv,
                onChanged: _biometrieUmschalten,
              ),
            ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.today),
              title: const Text('Heute-Knopf öffnet den Tageseintrag'),
              subtitle: const Text(
                  'Beim Tippen auf „Heute" öffnet sich sofort das '
                  'Eintragsfenster für den heutigen Tag. Die Vorgabe macht '
                  'der Chef – hier kannst du sie für dich ändern.'),
              value: _heuteOeffnetEintrag,
              onChanged: _heuteOptionUmschalten,
            ),
          ),
          const SizedBox(height: 16),
          Text('Deine Sollstunden',
              style: Theme.of(context).textTheme.titleMedium),
          const Text('Änderungen macht der Chef im Chef-Bereich.'),
          const SizedBox(height: 8),
          if (s == null)
            const Center(child: CircularProgressIndicator())
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (s.sollModus == SollModus.gleich)
                      Text(
                          'Mo–Fr: ${formatStunden(s.sollStundenTag)} Stunden pro Tag')
                    else ...[
                      Text('Mo–Do: ${formatStunden(s.sollStundenMoDo)} Stunden'),
                      Text('Freitag: ${formatStunden(s.sollStundenFr)} Stunden'),
                    ],
                    const Text('Sa/So: frei'),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardzeitenFelder(
                    beginn: _standardBeginn,
                    ende: _standardEnde,
                    pauseMin: _standardPauseMin,
                    onBeginn: (t) => setState(() => _standardBeginn = t),
                    onEnde: (t) => setState(() => _standardEnde = t),
                    onPause: (m) => setState(() => _standardPauseMin = m),
                    zeigeFreitag: s?.sollModus == SollModus.moDoFrGetrennt,
                    beginnFr: _standardBeginnFr,
                    endeFr: _standardEndeFr,
                    pauseFrMin: _standardPauseFrMin,
                    onFreitagAbweichend: (an) => setState(() {
                      _standardBeginnFr = an ? _standardBeginn : null;
                      _standardEndeFr = an ? _standardEnde : null;
                      _standardPauseFrMin = an ? _standardPauseMin : null;
                    }),
                    onBeginnFr: (t) => setState(() => _standardBeginnFr = t),
                    onEndeFr: (t) => setState(() => _standardEndeFr = t),
                    onPauseFr: (m) => setState(() => _standardPauseFrMin = m),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                      onPressed: _standardzeitenSpeichern,
                      child: const Text('Speichern')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

