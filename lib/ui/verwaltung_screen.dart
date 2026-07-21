import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../export/export_service.dart';
import '../logic/backup_service.dart';
import '../logic/backup_stub.dart'
    if (dart.library.io) '../logic/backup_io.dart' as plattform;
import '../logic/berechnung.dart';
import 'package:lizenz_shared/lizenz_shared.dart' show lizenzDateiName;

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

/// Alle persönlichen Werte auf einer Seite: Name (aus der Lizenz, nur
/// Anzeige), Briefkopf-Kontaktdaten, Sollstunden, Anfangsstände,
/// Urlaubskonten und Standardzeiten. In der Firmenversion setzt das der
/// Chef pro Mitarbeiter – hier macht es der Nutzer selbst.
class _ProfilTab extends ConsumerStatefulWidget {
  const _ProfilTab();

  @override
  ConsumerState<_ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends ConsumerState<_ProfilTab> {
  final _anzeigename = TextEditingController();
  final _email = TextEditingController();
  final _adresse = TextEditingController();
  final _telefon = TextEditingController();
  final _briefkopfEmail = TextEditingController();
  final _sollTag = TextEditingController();
  final _sollMoDo = TextEditingController();
  final _sollFr = TextEditingController();
  // Sollstunden je Wochentag (Modus „Pro Wochentag"): Mo … So.
  final _sollWochentag =
      List.generate(7, (_) => TextEditingController(), growable: false);
  // Automatische Pausenregel.
  final _pausenSchwelleStd = TextEditingController(text: '12');
  final _pausenMindestMin = TextEditingController(text: '60');
  final _urlaubAnfangsstand = TextEditingController();
  final _urlaubFrAnfangsstand = TextEditingController();
  final _firmenurlaubAnfangsstand = TextEditingController();
  final _zaStunden = TextEditingController();

  User? _user;
  UserSetting? _settings;
  var _modus = SollModus.moDoFrGetrennt;
  var _pausenAktiv = false;
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
      _adresse,
      _telefon,
      _briefkopfEmail,
      _sollTag,
      _sollMoDo,
      _sollFr,
      ..._sollWochentag,
      _pausenSchwelleStd,
      _pausenMindestMin,
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
    final branding = await ref.read(dbProvider).branding();
    if (!mounted) return;
    setState(() {
      _user = user;
      _settings = s;
      // Der Name kommt aus der Lizenz und ist hier nur Anzeige.
      _anzeigename.text = branding.firmenname;
      _email.text = user.mitarbeiterEmail;
      _adresse.text = branding.adresse;
      _telefon.text = branding.telefon;
      _briefkopfEmail.text = branding.email;
      _sollTag.text = formatStunden(s.sollStundenTag);
      _sollMoDo.text = formatStunden(s.sollStundenMoDo);
      _sollFr.text = formatStunden(s.sollStundenFr);
      final proTag = [
        s.sollStundenMo,
        s.sollStundenDi,
        s.sollStundenMi,
        s.sollStundenDo,
        s.sollStundenFrTag,
        s.sollStundenSa,
        s.sollStundenSo,
      ];
      for (var i = 0; i < 7; i++) {
        _sollWochentag[i].text = formatStunden(proTag[i]);
      }
      _pausenAktiv = s.pausenregelAktiv;
      _pausenSchwelleStd.text = formatStunden(s.pausenSchwelleMin / 60.0);
      _pausenMindestMin.text = '${s.pausenMindestMin}';
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
    final schwelleMin = (lese(_pausenSchwelleStd, 12) * 60).round();
    final mindestMin = int.tryParse(_pausenMindestMin.text.trim()) ?? 60;
    await (db.update(db.userSettings)..where((t) => t.userId.equals(user.id)))
        .write(UserSettingsCompanion(
      sollModus: Value(_modus),
      sollStundenTag: Value(lese(_sollTag, 8)),
      sollStundenMoDo: Value(lese(_sollMoDo, 8)),
      sollStundenFr: Value(lese(_sollFr, 5)),
      sollStundenMo: Value(lese(_sollWochentag[0], 8)),
      sollStundenDi: Value(lese(_sollWochentag[1], 8)),
      sollStundenMi: Value(lese(_sollWochentag[2], 8)),
      sollStundenDo: Value(lese(_sollWochentag[3], 8)),
      sollStundenFrTag: Value(lese(_sollWochentag[4], 8)),
      sollStundenSa: Value(lese(_sollWochentag[5], 0)),
      sollStundenSo: Value(lese(_sollWochentag[6], 0)),
      pausenregelAktiv: Value(_pausenAktiv),
      pausenSchwelleMin: Value(schwelleMin < 1 ? 1 : schwelleMin),
      pausenMindestMin: Value(mindestMin < 0 ? 0 : mindestMin),
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
    // Der Anzeigename bleibt unangetastet – er ist an die Lizenz gebunden.
    await (db.update(db.users)..where((t) => t.id.equals(user.id))).write(
        UsersCompanion(mitarbeiterEmail: Value(_email.text.trim())));
    await (db.update(db.brandings)..where((t) => t.id.equals(1))).write(
        BrandingsCompanion(
            adresse: Value(_adresse.text.trim()),
            telefon: Value(_telefon.text.trim()),
            email: Value(_briefkopfEmail.text.trim())));
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
          readOnly: true,
          enabled: false,
          decoration: const InputDecoration(
              labelText: 'Name (aus der Lizenz)',
              helperText: 'Steht auf allen Berichten. Änderbar nur über '
                  'eine neue Lizenzdatei des Entwicklers.'),
        ),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
              labelText: 'Deine E-Mail-Adresse',
              helperText: 'Für die eigene Kopie beim Mail-Export'),
        ),
        const Divider(height: 32),
        Text('Briefkopf der Berichte',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        const Text('Erscheint unter deinem Namen im Kopf der PDF-Berichte. '
            'Leere Felder werden weggelassen.'),
        TextField(
          controller: _adresse,
          decoration: const InputDecoration(labelText: 'Adresse'),
        ),
        TextField(
          controller: _telefon,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Telefon'),
        ),
        TextField(
          controller: _briefkopfEmail,
          keyboardType: TextInputType.emailAddress,
          decoration:
              const InputDecoration(labelText: 'E-Mail auf dem Bericht'),
        ),
        const Divider(height: 32),
        _SollFelder(
          modus: _modus,
          onModus: (m) => setState(() => _modus = m),
          sollTag: _sollTag,
          sollMoDo: _sollMoDo,
          sollFr: _sollFr,
          sollWochentag: _sollWochentag,
          onWochentagGeaendert: () => setState(() {}),
        ),
        const Divider(height: 32),
        Text('Automatische Pause', style: Theme.of(context).textTheme.titleSmall),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('Mindestpause bei langen Tagen'),
          subtitle: const Text(
              'Ab einer bestimmten Anwesenheit wird die Pause auf einen '
              'Mindestwert aufgefüllt (kein Doppelabzug einer schon '
              'erfassten Pause).'),
          value: _pausenAktiv,
          onChanged: (v) => setState(() => _pausenAktiv = v),
        ),
        if (_pausenAktiv)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pausenSchwelleStd,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'ab Anwesenheit', suffixText: 'h'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _pausenMindestMin,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'mindestens', suffixText: 'min'),
                ),
              ),
            ],
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

  /// Sollstunden je Wochentag Mo … So (Modus „Pro Wochentag").
  final List<TextEditingController> sollWochentag;

  /// Neu rechnen, wenn sich ein Wochentagswert ändert (für die Wochensumme).
  final VoidCallback onWochentagGeaendert;

  const _SollFelder({
    required this.modus,
    required this.onModus,
    required this.sollTag,
    required this.sollMoDo,
    required this.sollFr,
    required this.sollWochentag,
    required this.onWochentagGeaendert,
  });

  static const _tage = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
      'Freitag', 'Samstag', 'Sonntag'];

  double _wochensumme() {
    var summe = 0.0;
    for (final c in sollWochentag) {
      summe += double.tryParse(c.text.replaceAll(',', '.')) ?? 0;
    }
    return summe;
  }

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
              RadioListTile<SollModus>(
                dense: true,
                title: Text('Pro Wochentag (jeder Tag einzeln)'),
                subtitle: Text('z.B. 25-Stunden-Woche oder freier Mittwoch'),
                value: SollModus.proWochentag,
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
        else if (modus == SollModus.moDoFrGetrennt) ...[
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
        ] else ...[
          for (var i = 0; i < 7; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(width: 96, child: Text(_tage[i])),
                  Expanded(
                    child: TextField(
                      controller: sollWochentag[i],
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration:
                          const InputDecoration(isDense: true, suffixText: 'h'),
                      onChanged: (_) => onWochentagGeaendert(),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Wochensumme: ${formatStunden(_wochensumme())} h',
                style: Theme.of(context).textTheme.labelMedium),
          ),
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
  final _betreffVorlage = TextEditingController();
  final _host = TextEditingController();
  final _port = TextEditingController(text: '465');
  final _smtpUser = TextEditingController();
  final _smtpPass = TextEditingController();
  bool _ssl = true;
  bool _autoSend = false;
  bool _sicherungMitMail = false;
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
    for (final c in [
      _ziel,
      _betreffVorlage,
      _host,
      _port,
      _smtpUser,
      _smtpPass
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _lade() async {
    final db = ref.read(dbProvider);
    final user = await ref.read(authProvider).einzelUser();
    _userId = user?.id;
    _ziel.text = await db.getSetting(SettingsKeys.zielEmail) ?? '';
    _betreffVorlage.text = await db.getSetting(SettingsKeys.betreffVorlage) ??
        kBetreffVorlageStandard;
    _host.text = await db.getSetting(SettingsKeys.smtpHost) ?? '';
    _port.text = await db.getSetting(SettingsKeys.smtpPort) ?? '465';
    _smtpUser.text = await db.getSetting(SettingsKeys.smtpUser) ?? '';
    _smtpPass.text = await db.getSetting(SettingsKeys.smtpPass) ?? '';
    _ssl = await db.getBoolSetting(SettingsKeys.smtpSsl, fallback: true);
    _autoSend = await db.getBoolSetting(SettingsKeys.autoSendAktiv);
    _sicherungMitMail =
        await db.getBoolSetting(SettingsKeys.sicherungMitMail);
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
    await db.setSetting(
        SettingsKeys.betreffVorlage,
        _betreffVorlage.text.trim().isEmpty
            ? kBetreffVorlageStandard
            : _betreffVorlage.text.trim());
    await db.setSetting(SettingsKeys.smtpHost, _host.text.trim());
    await db.setSetting(SettingsKeys.smtpPort, _port.text.trim());
    await db.setSetting(SettingsKeys.smtpUser, _smtpUser.text.trim());
    await db.setSetting(SettingsKeys.smtpPass, _smtpPass.text);
    await db.setBoolSetting(SettingsKeys.smtpSsl, _ssl);
    await db.setBoolSetting(SettingsKeys.autoSendAktiv, _autoSend);
    await db.setBoolSetting(
        SettingsKeys.sicherungMitMail, _sicherungMitMail);
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
    if (erkenneSicherungsFormat(bytes) == null) {
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
  /// Installation – z.B. wenn der Entwickler eine korrigierte Datei mit
  /// geändertem Namen schickt. Der Name kommt aus der Datei und wird als
  /// Lizenz- und Anzeigename übernommen.
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
      final lizenzErgebnis =
          await ref.read(lizenzProvider).dateiEinloesen(utf8.decode(bytes));
      if (!mounted) return;
      String meldung;
      if (lizenzErgebnis is LizenzOk) {
        final name = (await ref.read(dbProvider).branding()).firmenname;
        // Neuer Name soll sofort überall sichtbar sein (Monatsansicht,
        // Profil, Exporte).
        ref.invalidate(einzelUserProvider);
        meldung = 'Lizenzdatei importiert – freigeschaltet für: $name';
      } else {
        meldung = (lizenzErgebnis as LizenzFehler).meldung;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(meldung)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import fehlgeschlagen: $e')));
      }
    } finally {
      if (mounted) setState(() => _lizenzLaeuft = false);
    }
  }

  /// Exportiert die gespeicherte, signierte Lizenz als Datei – z.B. zum
  /// Freischalten auf einem anderen Gerät oder einer anderen Plattform.
  Future<void> _lizenzExportieren() async {
    setState(() => _lizenzLaeuft = true);
    try {
      final json = await ref.read(lizenzProvider).exportiereLizenzdatei();
      final name = (await ref.read(dbProvider).branding()).firmenname;
      final dateiname = lizenzDateiName(name);
      // Der Desktop hat keinen System-Teilen-Dialog für Dateien – dort
      // stattdessen „Speichern unter" (wie bei der Datensicherung).
      final desktop = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS);
      if (desktop) {
        final pfad = await plattform.speichereDatei('Lizenzdatei speichern',
            dateiname, ['json'], Uint8List.fromList(utf8.encode(json)));
        if (pfad != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lizenzdatei gespeichert: $pfad')));
        }
        return;
      }
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(Uint8List.fromList(utf8.encode(json)),
              name: dateiname, mimeType: 'application/json'),
        ],
        subject: 'Zeitexa Lizenzdatei',
        text: 'Zeitexa-Lizenzdatei zum Importieren auf einem anderen Gerät.',
      ));
    } on StateError {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Keine Lizenz vorhanden – erst per Code freischalten.')));
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
        TextField(
          controller: _betreffVorlage,
          decoration: const InputDecoration(
            labelText: 'Betreff der Export-Mails',
            helperText: 'Platzhalter: {Mitarbeiter} {Monat} {Jahr} '
                '{Firma} {Zeitraum}',
          ),
        ),
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
        SwitchListTile(
          title: const Text('Sicherung an die Export-Mail anhängen'),
          subtitle: const Text(
              'Jede Monats-Mail (auch die automatische) bekommt zusätzlich '
              'eine komplette Datensicherung als Anhang – so liegt immer '
              'ein aktueller Stand im Postfach.'),
          value: _sicherungMitMail,
          onChanged: (v) => setState(() => _sicherungMitMail = v),
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
        const Text(
            'Die Sicherung enthält ALLE Daten dieses Geräts (Einträge, '
            'Einstellungen, Lizenz) in einer Datei – z.B. um auf ein neues '
            'Gerät umzuziehen oder die Daten zu sichern. Die Datei lässt '
            'sich auf jedem Gerät einspielen – auch zwischen PC, Handy '
            'und Browser-App.'),
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
        const Divider(height: 32),
        Text('Lizenz', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
            'Freigeschaltet für: '
            '${ref.watch(brandingProvider).value?.firmenname ?? '…'}',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        const Text(
            'Die Lizenz gilt für diese Person; der Name lässt sich nur über '
            'eine neue Lizenzdatei des Entwicklers ändern. Mit „Exportieren" '
            'kann die Lizenz auf ein anderes Gerät mitgenommen werden.'),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(
            onPressed: _lizenzLaeuft ? null : _lizenzImportieren,
            icon: _lizenzLaeuft
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.file_open_outlined),
            label: const Text('Lizenzdatei importieren…'),
          ),
          OutlinedButton.icon(
            onPressed: _lizenzLaeuft ? null : _lizenzExportieren,
            icon: const Icon(Icons.ios_share),
            label: const Text('Lizenzdatei exportieren…'),
          ),
        ]),
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

/// Die Akzentfarbe darf der Nutzer selbst bestimmen – reine Kosmetik ohne
/// Einfluss auf Lizenz oder Berechnung.
class _DarstellungAbschnitt extends ConsumerStatefulWidget {
  const _DarstellungAbschnitt();

  @override
  ConsumerState<_DarstellungAbschnitt> createState() =>
      _DarstellungAbschnittState();
}

class _DarstellungAbschnittState extends ConsumerState<_DarstellungAbschnitt> {
  int _farbe = 0xFF1565C0;
  bool _geladen = false;

  @override
  void initState() {
    super.initState();
    ref.read(dbProvider).branding().then((b) {
      if (!mounted) return;
      setState(() {
        _farbe = b.akzentFarbe;
        _geladen = true;
      });
    });
  }

  Future<void> _speichern() async {
    final db = ref.read(dbProvider);
    await (db.update(db.brandings)..where((t) => t.id.equals(1)))
        .write(BrandingsCompanion(akzentFarbe: Value(_farbe)));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Darstellung übernommen.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_geladen) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Darstellung', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        const Text('Die Farbe erscheint in der App und auf dem '
            'PDF-Bericht.'),
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
