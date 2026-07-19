import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../logic/backup_service.dart';
import '../logic/berechnung.dart';
import '../logic/lizenz_service.dart';
import '../main.dart';
import 'auswertung_view.dart';
import 'standardzeiten_felder.dart';

TimeOfDay? _vonMinutenTod(int? minuten) => minuten == null
    ? null
    : TimeOfDay(hour: minuten ~/ 60, minute: minuten % 60);

/// Gegenstück zu [_vonMinutenTod]: Uhrzeit als Minuten seit Mitternacht,
/// null bleibt null (= „wie Mo–Do" bei den Freitagszeiten).
int? _minuten(TimeOfDay? zeit) =>
    zeit == null ? null : zeit.hour * 60 + zeit.minute;

String _datumKurz(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// Eingabe des Zeitausgleich-Anfangsstands als Dezimalstunden (z.B. 43,35)
/// plus Plus/Minus-Umschalter für negative Stände.
class _ZaAnfangsstandFeld extends StatelessWidget {
  final bool negativ;
  final TextEditingController stunden;
  final ValueChanged<bool> onNegativ;

  const _ZaAnfangsstandFeld({
    required this.negativ,
    required this.stunden,
    required this.onNegativ,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SegmentedButton<bool>(
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          segments: const [
            ButtonSegment(value: false, label: Text('+')),
            ButtonSegment(value: true, label: Text('−')),
          ],
          selected: {negativ},
          onSelectionChanged: (s) => onNegativ(s.first),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: stunden,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                labelText: 'Zeitausgleich-Anfangsstand (Stunden)',
                helperText: 'Dezimal, z.B. 43,35'),
          ),
        ),
      ],
    );
  }
}

/// Liest Dezimalstunden (Komma oder Punkt) aus [controller] und liefert den
/// Anfangsstand in Minuten, vorzeichenbehaftet über den Umschalter.
int _zaMinuten(TextEditingController controller, bool negativ,
    {int fallbackAbsMin = 0}) {
  final wert = double.tryParse(controller.text.replaceAll(',', '.'));
  final absMin = wert == null ? fallbackAbsMin : (wert.abs() * 60).round();
  return (negativ ? -1 : 1) * absMin;
}

/// Öffnet die Verwaltung. Anders als der Chef-Bereich der Firmenversion ist
/// sie NICHT durch ein Passwort geschützt: In Zeitexa gehören alle
/// Einstellungen dem einen Nutzer, dem das Gerät ohnehin gehört.
Future<void> oeffneVerwaltung(BuildContext context, WidgetRef ref) =>
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const VerwaltungScreen()));

class VerwaltungScreen extends ConsumerWidget {
  const VerwaltungScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verwaltung'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.person_outline), text: 'Mein Profil'),
            Tab(icon: Icon(Icons.tune), text: 'Optionen'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Auswertung'),
          ]),
        ),
        body: const TabBarView(children: [
          _ProfilTab(),
          _OptionenTab(),
          AuswertungView(),
        ]),
      ),
    );
  }
}

// ------------------------------------------------------------ Mein Profil

/// Alle persönlichen Rechenwerte auf einer Seite: Name, Sollstunden,
/// Anfangsstände, Urlaubskonten und Standardzeiten. In der Firmenversion
/// setzt das der Chef pro Mitarbeiter – hier macht es der Nutzer selbst.
class _ProfilTab extends ConsumerStatefulWidget {
  const _ProfilTab();

  @override
  ConsumerState<_ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends ConsumerState<_ProfilTab> {
  final _anzeigename = TextEditingController();
  final _email = TextEditingController();
  final _sollTag = TextEditingController();
  final _sollMoDo = TextEditingController();
  final _sollFr = TextEditingController();
  final _urlaubAnfangsstand = TextEditingController();
  final _urlaubFrAnfangsstand = TextEditingController();
  final _firmenurlaubAnfangsstand = TextEditingController();
  final _zaStunden = TextEditingController();

  User? _user;
  UserSetting? _settings;
  var _modus = SollModus.moDoFrGetrennt;
  var _urlaubFrGetrennt = false;
  var _firmenurlaubAktiv = false;
  var _zaNegativ = false;
  DateTime? _stichtag;
  var _standardBeginn = const TimeOfDay(hour: 7, minute: 0);
  var _standardEnde = const TimeOfDay(hour: 16, minute: 0);
  var _standardPauseMin = 30;
  TimeOfDay? _standardBeginnFr;
  TimeOfDay? _standardEndeFr;
  int? _standardPauseFrMin;
  bool _geladen = false;

  @override
  void initState() {
    super.initState();
    _lade();
  }

  @override
  void dispose() {
    for (final c in [
      _anzeigename,
      _email,
      _sollTag,
      _sollMoDo,
      _sollFr,
      _urlaubAnfangsstand,
      _urlaubFrAnfangsstand,
      _firmenurlaubAnfangsstand,
      _zaStunden,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _lade() async {
    final user = await ref.read(authProvider).einzelUser();
    if (user == null) return;
    final s = await ref.read(dbProvider).settingsFor(user.id);
    if (!mounted) return;
    setState(() {
      _user = user;
      _settings = s;
      _anzeigename.text = user.displayName;
      _email.text = user.mitarbeiterEmail;
      _sollTag.text = formatStunden(s.sollStundenTag);
      _sollMoDo.text = formatStunden(s.sollStundenMoDo);
      _sollFr.text = formatStunden(s.sollStundenFr);
      _urlaubAnfangsstand.text = formatStunden(s.anfangsstandUrlaubTage);
      _urlaubFrAnfangsstand.text = formatStunden(s.anfangsstandUrlaubFrTage);
      _firmenurlaubAnfangsstand.text =
          formatStunden(s.anfangsstandFirmenurlaubTage);
      _zaStunden.text =
          formatStunden(s.anfangsstandZeitausgleichMin.abs() / 60.0);
      _modus = s.sollModus;
      _urlaubFrGetrennt = s.urlaubFrGetrennt;
      _firmenurlaubAktiv = s.firmenurlaubAktiv;
      _zaNegativ = s.anfangsstandZeitausgleichMin < 0;
      _stichtag = s.anfangsstandStichtag;
      _standardBeginn = _vonMinutenTod(s.standardBeginnMin) ??
          const TimeOfDay(hour: 7, minute: 0);
      _standardEnde = _vonMinutenTod(s.standardEndeMin) ??
          const TimeOfDay(hour: 16, minute: 0);
      _standardPauseMin = s.standardPauseMin;
      _standardBeginnFr = _vonMinutenTod(s.standardBeginnFrMin);
      _standardEndeFr = _vonMinutenTod(s.standardEndeFrMin);
      _standardPauseFrMin = s.standardPauseFrMin;
      _geladen = true;
    });
  }

  Future<void> _speichern() async {
    final user = _user;
    final s = _settings;
    if (user == null || s == null) return;
    final db = ref.read(dbProvider);
    double lese(TextEditingController c, double fallback) =>
        double.tryParse(c.text.replaceAll(',', '.')) ?? fallback;
    await (db.update(db.userSettings)..where((t) => t.userId.equals(user.id)))
        .write(UserSettingsCompanion(
      sollModus: Value(_modus),
      sollStundenTag: Value(lese(_sollTag, 8)),
      sollStundenMoDo: Value(lese(_sollMoDo, 8)),
      sollStundenFr: Value(lese(_sollFr, 5)),
      standardBeginnMin:
          Value(_standardBeginn.hour * 60 + _standardBeginn.minute),
      standardEndeMin: Value(_standardEnde.hour * 60 + _standardEnde.minute),
      standardPauseMin: Value(_standardPauseMin),
      anfangsstandStichtag: _stichtag == null
          ? const Value.absent()
          : Value(DateTime(_stichtag!.year, _stichtag!.month, _stichtag!.day)),
      anfangsstandUrlaubTage:
          Value(lese(_urlaubAnfangsstand, s.anfangsstandUrlaubTage)),
      anfangsstandZeitausgleichMin: Value(_zaMinuten(_zaStunden, _zaNegativ,
          fallbackAbsMin: s.anfangsstandZeitausgleichMin.abs())),
      urlaubFrGetrennt: Value(_urlaubFrGetrennt),
      anfangsstandUrlaubFrTage:
          Value(lese(_urlaubFrAnfangsstand, s.anfangsstandUrlaubFrTage)),
      firmenurlaubAktiv: Value(_firmenurlaubAktiv),
      anfangsstandFirmenurlaubTage: Value(
          lese(_firmenurlaubAnfangsstand, s.anfangsstandFirmenurlaubTage)),
      standardBeginnFrMin: Value(_minuten(_standardBeginnFr)),
      standardEndeFrMin: Value(_minuten(_standardEndeFr)),
      standardPauseFrMin: Value(_standardPauseFrMin),
    ));
    await (db.update(db.users)..where((t) => t.id.equals(user.id))).write(
        UsersCompanion(
            displayName: Value(_anzeigename.text.trim().isEmpty
                ? user.displayName
                : _anzeigename.text.trim()),
            mitarbeiterEmail: Value(_email.text.trim())));
    // Ab jetzt gelten die Werte als geprüft: die Hinweiskarte in der
    // Monatsansicht verschwindet.
    await db.setBoolSetting(SettingsKeys.einstellungenGeprueft, true);
    ref.invalidate(einzelUserProvider);
    ref.invalidate(einstellungenGeprueftProvider);
    await _lade();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gespeichert.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_geladen) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _anzeigename,
          decoration: const InputDecoration(
              labelText: 'Dein Name',
              helperText: 'Steht auf Auswertungen und Exporten'),
        ),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
              labelText: 'Deine E-Mail-Adresse',
              helperText: 'Für die eigene Kopie beim Mail-Export'),
        ),
        const Divider(height: 32),
        _SollFelder(
          modus: _modus,
          onModus: (m) => setState(() => _modus = m),
          sollTag: _sollTag,
          sollMoDo: _sollMoDo,
          sollFr: _sollFr,
        ),
        const Divider(height: 32),
        Text('Anfangsstand', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.event),
            label: Text(_stichtag == null
                ? 'Stichtag wählen'
                : 'Stichtag ${_datumKurz(_stichtag!)}'),
            onPressed: () async {
              final neu = await showDatePicker(
                context: context,
                initialDate: _stichtag ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(DateTime.now().year + 5),
              );
              if (neu != null) setState(() => _stichtag = neu);
            },
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('Freitags-Urlaub getrennt führen'),
          subtitle: const Text(
              'Eigenes Urlaubskonto für Freitage (Mo–Do und Fr werden '
              'getrennt gutgeschrieben und verbraucht)'),
          value: _urlaubFrGetrennt,
          onChanged: (v) => setState(() => _urlaubFrGetrennt = v),
        ),
        TextField(
          controller: _urlaubAnfangsstand,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
              labelText: _urlaubFrGetrennt
                  ? 'Resturlaub-Anfangsstand Mo–Do (Tage)'
                  : 'Resturlaub-Anfangsstand (Tage)',
              helperText: 'Halbe Tage z.B. als 12,5'),
        ),
        if (_urlaubFrGetrennt)
          TextField(
            controller: _urlaubFrAnfangsstand,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                labelText: 'Resturlaub-Anfangsstand Freitag (Tage)'),
          ),
        const SizedBox(height: 8),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('Zusatzurlaub führen'),
          subtitle: const Text(
              'Eigenes Konto für zusätzlichen Urlaub (z.B. eine Extra-Woche). '
              'Verfällt nicht.'),
          value: _firmenurlaubAktiv,
          onChanged: (v) => setState(() => _firmenurlaubAktiv = v),
        ),
        if (_firmenurlaubAktiv)
          TextField(
            controller: _firmenurlaubAnfangsstand,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                labelText: 'Zusatzurlaub-Kontingent (Tage)',
                helperText: 'Gesamtstand zum Stichtag; jährlich selbst erhöhen'),
          ),
        const SizedBox(height: 8),
        _ZaAnfangsstandFeld(
          negativ: _zaNegativ,
          stunden: _zaStunden,
          onNegativ: (v) => setState(() => _zaNegativ = v),
        ),
        const Divider(height: 32),
        StandardzeitenFelder(
          beginn: _standardBeginn,
          ende: _standardEnde,
          pauseMin: _standardPauseMin,
          onBeginn: (t) => setState(() => _standardBeginn = t),
          onEnde: (t) => setState(() => _standardEnde = t),
          onPause: (m) => setState(() => _standardPauseMin = m),
          zeigeFreitag: _modus == SollModus.moDoFrGetrennt,
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
        const SizedBox(height: 24),
        FilledButton(onPressed: _speichern, child: const Text('Speichern')),
        const SizedBox(height: 60),
      ],
    );
  }
}

/// Eingabefelder für die Sollstunden (Modus + Werte).
class _SollFelder extends StatelessWidget {
  final SollModus modus;
  final ValueChanged<SollModus> onModus;
  final TextEditingController sollTag;
  final TextEditingController sollMoDo;
  final TextEditingController sollFr;

  const _SollFelder({
    required this.modus,
    required this.onModus,
    required this.sollTag,
    required this.sollMoDo,
    required this.sollFr,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sollstunden', style: Theme.of(context).textTheme.titleSmall),
        RadioGroup<SollModus>(
          groupValue: modus,
          onChanged: (v) => onModus(v!),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<SollModus>(
                dense: true,
                title: Text('Gleich für alle Tage (Mo–Fr)'),
                value: SollModus.gleich,
              ),
              RadioListTile<SollModus>(
                dense: true,
                title: Text('Mo–Do und Freitag getrennt'),
                value: SollModus.moDoFrGetrennt,
              ),
            ],
          ),
        ),
        if (modus == SollModus.gleich)
          TextField(
              controller: sollTag,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Stunden pro Tag (Mo–Fr)',
                  helperText: 'Halbe Stunden z.B. als 8,5'))
        else ...[
          TextField(
              controller: sollMoDo,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Stunden Mo–Do')),
          TextField(
              controller: sollFr,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Stunden Freitag')),
        ],
      ],
    );
  }
}

// --------------------------------------------------------------- Optionen

class _OptionenTab extends ConsumerStatefulWidget {
  const _OptionenTab();

  @override
  ConsumerState<_OptionenTab> createState() => _OptionenTabState();
}

class _OptionenTabState extends ConsumerState<_OptionenTab> {
  final _ziel = TextEditingController();
  final _host = TextEditingController();
  final _port = TextEditingController(text: '465');
  final _smtpUser = TextEditingController();
  final _smtpPass = TextEditingController();
  bool _ssl = true;
  bool _autoSend = false;
  bool _heuteOeffnet = false;
  bool _appSperre = false;
  bool _biometrie = false;
  bool _biometrieMoeglich = false;
  bool _geladen = false;
  bool _testLaeuft = false;
  bool _backupLaeuft = false;
  bool _lizenzLaeuft = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _lade();
  }

  @override
  void dispose() {
    for (final c in [_ziel, _host, _port, _smtpUser, _smtpPass]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _lade() async {
    final db = ref.read(dbProvider);
    final user = await ref.read(authProvider).einzelUser();
    _userId = user?.id;
    _ziel.text = await db.getSetting(SettingsKeys.zielEmail) ?? '';
    _host.text = await db.getSetting(SettingsKeys.smtpHost) ?? '';
    _port.text = await db.getSetting(SettingsKeys.smtpPort) ?? '465';
    _smtpUser.text = await db.getSetting(SettingsKeys.smtpUser) ?? '';
    _smtpPass.text = await db.getSetting(SettingsKeys.smtpPass) ?? '';
    _ssl = await db.getBoolSetting(SettingsKeys.smtpSsl, fallback: true);
    _autoSend = await db.getBoolSetting(SettingsKeys.autoSendAktiv);
    _heuteOeffnet =
        await db.getBoolSetting(SettingsKeys.heuteOeffnetEintragStandard);
    _appSperre = await ref.read(authProvider).appSperreAktiv();
    final biometrie = ref.read(biometrieProvider);
    _biometrieMoeglich = await biometrie.geraetUnterstuetzt();
    _biometrie = _userId != null && await biometrie.istAktiviertFuer(_userId!);
    if (mounted) setState(() => _geladen = true);
  }

  Future<void> _speichern() async {
    final db = ref.read(dbProvider);
    await db.setSetting(SettingsKeys.zielEmail, _ziel.text.trim());
    await db.setSetting(SettingsKeys.smtpHost, _host.text.trim());
    await db.setSetting(SettingsKeys.smtpPort, _port.text.trim());
    await db.setSetting(SettingsKeys.smtpUser, _smtpUser.text.trim());
    await db.setSetting(SettingsKeys.smtpPass, _smtpPass.text);
    await db.setBoolSetting(SettingsKeys.smtpSsl, _ssl);
    await db.setBoolSetting(SettingsKeys.autoSendAktiv, _autoSend);
    await db.setBoolSetting(
        SettingsKeys.heuteOeffnetEintragStandard, _heuteOeffnet);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gespeichert.')));
    }
  }

  /// Schaltet die App-Sperre ein (Passwort zweimal eingeben) oder aus.
  Future<void> _appSperreUmschalten(bool an) async {
    final auth = ref.read(authProvider);
    if (!an) {
      await auth.entferneAppSperre();
      ref.invalidate(appSperreProvider);
      if (mounted) setState(() => _appSperre = false);
      return;
    }
    final passwort = TextEditingController();
    final wdh = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App-Sperre einschalten'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Beim Start fragt Zeitexa dann nach diesem Passwort. '
                  'Es lässt sich nicht wiederherstellen – notiere es dir.'),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwort,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Passwort'),
                validator: (v) =>
                    (v == null || v.length < 4) ? 'Mindestens 4 Zeichen' : null,
              ),
              TextFormField(
                controller: wdh,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Passwort wiederholen'),
                validator: (v) => v != passwort.text
                    ? 'Passwörter stimmen nicht überein'
                    : null,
              ),
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
              child: const Text('Einschalten')),
        ],
      ),
    );
    if (ok != true) return;
    await auth.setzeAppSperre(passwort.text);
    ref.invalidate(appSperreProvider);
    if (mounted) setState(() => _appSperre = true);
  }

  Future<void> _biometrieUmschalten(bool an) async {
    final userId = _userId;
    if (userId == null) return;
    final biometrie = ref.read(biometrieProvider);
    if (an) {
      final ok = await biometrie
          .authentifizieren('Entsperren per Fingerabdruck einrichten');
      if (!ok) return;
      await biometrie.aktivierenFuer(userId);
    } else {
      await biometrie.deaktivierenFuer(userId);
    }
    if (mounted) setState(() => _biometrie = an);
  }

  Future<void> _testmail() async {
    setState(() => _testLaeuft = true);
    try {
      await _speichern();
      await ref.read(exportProvider).sendeTestmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Testmail wurde gesendet – bitte Posteingang prüfen.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Testmail fehlgeschlagen: $e')));
      }
    } finally {
      if (mounted) setState(() => _testLaeuft = false);
    }
  }

  Future<void> _sichern() async {
    setState(() => _backupLaeuft = true);
    try {
      final pfad = await ref.read(backupProvider).sichern();
      if (mounted && pfad != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sicherung gespeichert: $pfad')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sicherung fehlgeschlagen: $e')));
      }
    } finally {
      if (mounted) setState(() => _backupLaeuft = false);
    }
  }

  Future<void> _wiederherstellen() async {
    final backup = ref.read(backupProvider);
    final bytes = await backup.waehleSicherung();
    if (bytes == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (!istSqliteDatei(bytes)) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Das ist keine gültige Zeitexa-Sicherungsdatei.')));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sicherung wiederherstellen?'),
        content: const Text(
            'Achtung: Dabei werden ALLE aktuellen Daten auf diesem Gerät '
            'durch den Stand der Sicherung ersetzt (Einträge, '
            'Einstellungen, Lizenz).'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Wiederherstellen')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _backupLaeuft = true);
    String meldung;
    try {
      await backup.wiederherstellen(bytes);
      meldung = 'Sicherung wiederhergestellt.';
    } catch (e) {
      meldung = 'Wiederherstellen fehlgeschlagen: $e';
    }
    if (!mounted) return;
    // Die Datenbank wurde geschlossen: zurück zum StartGate und alle
    // Provider mit der (neuen) Datenbankdatei neu aufbauen.
    Navigator.of(context).popUntil((route) => route.isFirst);
    ref.invalidate(dbProvider);
    ref.invalidate(gateStatusProvider);
    messenger.showSnackBar(SnackBar(content: Text(meldung)));
  }

  /// Importiert eine (neue) Lizenzdatei in eine bereits freigeschaltete
  /// Installation – z.B. wenn der Entwickler eine aktualisierte Datei
  /// schickt, die zusätzlich sein Entwickler-Passwort mitbringt.
  Future<void> _lizenzImportieren() async {
    final ergebnis = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = ergebnis?.files.firstOrNull?.bytes;
    if (bytes == null || !mounted) return;
    setState(() => _lizenzLaeuft = true);
    try {
      final lizenzname = (await ref.read(dbProvider).branding()).firmenname;
      final lizenzErgebnis = await ref
          .read(lizenzProvider)
          .dateiEinloesen(utf8.decode(bytes), lizenzname);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(lizenzErgebnis is LizenzOk
              ? 'Lizenzdatei importiert.'
              : (lizenzErgebnis as LizenzFehler).meldung)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import fehlgeschlagen: $e')));
      }
    } finally {
      if (mounted) setState(() => _lizenzLaeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_geladen) {
      return const Center(child: CircularProgressIndicator());
    }
    final smtpMoeglich = ref.read(exportProvider).smtpMoeglich;
    final backupVerfuegbar = ref.read(backupProvider).verfuegbar;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Mailversand', style: Theme.of(context).textTheme.titleMedium),
        TextField(
            controller: _ziel,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'Empfänger der Monatsberichte',
                helperText:
                    'z.B. Auftraggeber, Steuerberater oder die eigene Adresse')),
        const SizedBox(height: 8),
        if (smtpMoeglich) ...[
          TextField(
              controller: _host,
              decoration: const InputDecoration(
                  labelText: 'SMTP-Server (z.B. mail.gmx.net)')),
          Row(children: [
            Expanded(
                child: TextField(
                    controller: _port,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Port (465 = SSL)'))),
            const SizedBox(width: 12),
            Expanded(
              child: SwitchListTile(
                dense: true,
                title: const Text('SSL'),
                value: _ssl,
                onChanged: (v) => setState(() => _ssl = v),
              ),
            ),
          ]),
          TextField(
              controller: _smtpUser,
              decoration: const InputDecoration(
                  labelText: 'SMTP-Benutzer (Mailadresse)')),
          TextField(
              controller: _smtpPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'SMTP-Passwort')),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _testLaeuft ? null : _testmail,
              icon: _testLaeuft
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.outgoing_mail),
              label: const Text('Testmail senden'),
            ),
          ),
          SwitchListTile(
            title: const Text('Automatischer Versand am Monatsanfang'),
            subtitle: const Text(
                'Beim ersten App-Start im neuen Monat wird der Vormonat '
                'automatisch gesendet'),
            value: _autoSend,
            onChanged: (v) => setState(() => _autoSend = v),
          ),
        ] else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                  'Im Browser (PWA) ist kein automatischer SMTP-Versand '
                  'möglich – den Export dort über die Mail-App (Teilen) '
                  'weitergeben.'),
            ),
          ),
        const Divider(height: 32),
        Text('Bedienung', style: Theme.of(context).textTheme.titleMedium),
        SwitchListTile(
          title: const Text('Heute-Knopf öffnet den Tageseintrag'),
          subtitle: const Text(
              '„Heute" springt zum aktuellen Tag und öffnet gleich das '
              'Eintragsfenster.'),
          value: _heuteOeffnet,
          onChanged: (v) => setState(() => _heuteOeffnet = v),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _speichern, child: const Text('Speichern')),
        const Divider(height: 32),
        Text('Sicherheit', style: Theme.of(context).textTheme.titleMedium),
        SwitchListTile(
          title: const Text('App mit Passwort sperren'),
          subtitle: const Text(
              'Zeitexa fragt beim Start nach einem Passwort. Standardmäßig '
              'aus – sinnvoll, wenn andere Zugriff auf das Gerät haben.'),
          value: _appSperre,
          onChanged: _appSperreUmschalten,
        ),
        if (_appSperre && _biometrieMoeglich)
          SwitchListTile(
            title: const Text('Auch per Fingerabdruck entsperren'),
            subtitle: const Text(
                'Hinweis: Das Gerät unterscheidet keine Personen – jeder '
                'hinterlegte Fingerabdruck kann entsperren.'),
            value: _biometrie,
            onChanged: _biometrieUmschalten,
          ),
        const Divider(height: 32),
        const _DarstellungAbschnitt(),
        const Divider(height: 32),
        Text('Datensicherung', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        if (backupVerfuegbar) ...[
          const Text(
              'Die Sicherung enthält ALLE Daten dieses Geräts (Einträge, '
              'Einstellungen, Lizenz) in einer Datei – z.B. um auf einen '
              'neuen PC umzuziehen oder die Daten zu sichern.'),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton.icon(
              onPressed: _backupLaeuft ? null : _sichern,
              icon: const Icon(Icons.save_alt),
              label: const Text('Sicherung erstellen…'),
            ),
            OutlinedButton.icon(
              onPressed: _backupLaeuft ? null : _wiederherstellen,
              icon: const Icon(Icons.settings_backup_restore),
              label: const Text('Sicherung wiederherstellen…'),
            ),
          ]),
        ] else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                  'Im Browser (PWA) ist keine Datensicherung möglich – '
                  'bitte dafür die Windows- oder Android-App verwenden.'),
            ),
          ),
        const Divider(height: 32),
        Text('Lizenz', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        const Text(
            'Hier kann eine neue Lizenzdatei des Entwicklers eingespielt '
            'werden (die Freischaltung selbst bleibt dabei erhalten).'),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _lizenzLaeuft ? null : _lizenzImportieren,
            icon: _lizenzLaeuft
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.file_open_outlined),
            label: const Text('Lizenzdatei importieren…'),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ------------------------------------------------------------- Darstellung

const _farben = <int, String>{
  0xFF1565C0: 'Blau',
  0xFF2E7D32: 'Grün',
  0xFFC62828: 'Rot',
  0xFFEF6C00: 'Orange',
  0xFF6A1B9A: 'Violett',
  0xFF00838F: 'Türkis',
  0xFF37474F: 'Grau',
  0xFF827717: 'Oliv',
};

/// Logo und Akzentfarbe darf der Nutzer selbst bestimmen – reine Kosmetik
/// ohne Einfluss auf Lizenz oder Berechnung. Der lizenzgebundene Name
/// bleibt dagegen im Entwicklerbereich (siehe lib/ui/branding_screen.dart).
class _DarstellungAbschnitt extends ConsumerStatefulWidget {
  const _DarstellungAbschnitt();

  @override
  ConsumerState<_DarstellungAbschnitt> createState() =>
      _DarstellungAbschnittState();
}

class _DarstellungAbschnittState extends ConsumerState<_DarstellungAbschnitt> {
  Uint8List? _logo;
  int _farbe = 0xFF1565C0;
  bool _geladen = false;

  @override
  void initState() {
    super.initState();
    ref.read(dbProvider).branding().then((b) {
      if (!mounted) return;
      setState(() {
        _logo = b.logo;
        _farbe = b.akzentFarbe;
        _geladen = true;
      });
    });
  }

  Future<void> _speichern() async {
    final db = ref.read(dbProvider);
    await (db.update(db.brandings)..where((t) => t.id.equals(1))).write(
        BrandingsCompanion(
            logo: Value(_logo), akzentFarbe: Value(_farbe)));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Darstellung übernommen.')));
    }
  }

  Future<void> _logoWaehlen() async {
    final ergebnis =
        await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final bytes = ergebnis?.files.firstOrNull?.bytes;
    if (bytes != null) setState(() => _logo = bytes);
  }

  @override
  Widget build(BuildContext context) {
    if (!_geladen) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Darstellung', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        const Text('Logo und Farbe erscheinen in der App und auf dem '
            'PDF-Bericht.'),
        const SizedBox(height: 12),
        Row(children: [
          if (_logo != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Image.memory(_logo!, height: 48),
            ),
          OutlinedButton.icon(
            onPressed: _logoWaehlen,
            icon: const Icon(Icons.image_outlined),
            label: Text(_logo == null ? 'Logo wählen…' : 'Logo ersetzen…'),
          ),
          if (_logo != null)
            TextButton(
              onPressed: () => setState(() => _logo = null),
              child: const Text('Entfernen'),
            ),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final eintrag in _farben.entries)
              ChoiceChip(
                label: Text(eintrag.value),
                avatar: CircleAvatar(backgroundColor: Color(eintrag.key)),
                selected: _farbe == eintrag.key,
                onSelected: (_) => setState(() => _farbe = eintrag.key),
              ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
            onPressed: _speichern, child: const Text('Darstellung speichern')),
      ],
    );
  }
}
