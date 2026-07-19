import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../logic/auth.dart';
import '../logic/backup_service.dart';
import '../logic/backup_stub.dart'
    if (dart.library.io) '../logic/backup_io.dart' as plattform;
import '../logic/berechnung.dart';
import '../logic/lizenz_service.dart';
import '../main.dart';
import 'auswertung_view.dart';
import 'benutzer_datei.dart';
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

/// Fragt das Adminpasswort ab und öffnet dann den Chef-Bereich.
Future<void> oeffneAdminBereich(BuildContext context, WidgetRef ref) async {
  final passwort = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Chef-Bereich'),
      content: TextField(
        controller: passwort,
        obscureText: true,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Adminpasswort'),
        onSubmitted: (_) => Navigator.pop(context, true),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen')),
        FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Öffnen')),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final stimmt = await ref.read(authProvider).pruefeAdminPasswort(passwort.text);
  if (!context.mounted) return;
  if (!stimmt) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Adminpasswort falsch.')));
    return;
  }
  await Navigator.push(
      context, MaterialPageRoute(builder: (_) => const AdminScreen()));
}

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chef-Bereich'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.group), text: 'Benutzer'),
            Tab(icon: Icon(Icons.mail_outline), text: 'Mail & Optionen'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Auswertung'),
          ]),
        ),
        body: const TabBarView(children: [
          _BenutzerTab(),
          _MailOptionenTab(),
          AuswertungView(),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------- Benutzer

class _BenutzerTab extends ConsumerStatefulWidget {
  const _BenutzerTab();

  @override
  ConsumerState<_BenutzerTab> createState() => _BenutzerTabState();
}

class _BenutzerTabState extends ConsumerState<_BenutzerTab> {
  List<User> _benutzer = const [];
  bool _transferLaeuft = false;

  @override
  void initState() {
    super.initState();
    _lade();
  }

  Future<void> _lade() async {
    final liste = await ref.read(dbProvider).allUsers();
    if (mounted) setState(() => _benutzer = liste);
  }

  Future<void> _neuerBenutzer() async {
    await _benutzerDialog();
    await _lade();
  }

  /// Dialog zum Anlegen eines Benutzers inkl. Sollstunden, Anfangsständen,
  /// Standardzeiten und E-Mail-Adresse.
  Future<void> _benutzerDialog() async {
    final username = TextEditingController();
    final anzeigename = TextEditingController();
    final passwort = TextEditingController();
    final sollTag = TextEditingController(text: '8');
    final sollMoDo = TextEditingController(text: '8');
    final sollFr = TextEditingController(text: '5');
    final email = TextEditingController();
    final urlaubAnfangsstand = TextEditingController(text: '0');
    final urlaubFrAnfangsstand = TextEditingController(text: '0');
    var urlaubFrGetrennt = false;
    final firmenurlaubAnfangsstand = TextEditingController(text: '0');
    var firmenurlaubAktiv = false;
    var zaNegativ = false;
    final zaStunden = TextEditingController(text: '0');
    var modus = SollModus.moDoFrGetrennt;
    var stichtag = DateTime.now();
    var standardBeginn = const TimeOfDay(hour: 7, minute: 0);
    var standardEnde = const TimeOfDay(hour: 16, minute: 0);
    var standardPauseMin = 30;
    TimeOfDay? standardBeginnFr;
    TimeOfDay? standardEndeFr;
    int? standardPauseFrMin;
    final formKey = GlobalKey<FormState>();
    String? fehler;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Mitarbeiter anlegen'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                        controller: username,
                        decoration:
                            const InputDecoration(labelText: 'Benutzername'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Angeben' : null),
                    TextFormField(
                        controller: anzeigename,
                        decoration:
                            const InputDecoration(labelText: 'Anzeigename'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Angeben' : null),
                    TextFormField(
                        controller: passwort,
                        decoration: const InputDecoration(
                            labelText: 'Start-Passwort',
                            helperText:
                                'Muss beim ersten Login geändert werden'),
                        validator: (v) =>
                            (v == null || v.length < 4) ? 'Mind. 4 Zeichen' : null),
                    TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            labelText: 'E-Mail-Adresse (Mitarbeiter)',
                            helperText:
                                'Für die eigene Excel-Kopie beim Mail-Export')),
                    const SizedBox(height: 12),
                    _SollFelder(
                      modus: modus,
                      onModus: (m) => setDialogState(() => modus = m),
                      sollTag: sollTag,
                      sollMoDo: sollMoDo,
                      sollFr: sollFr,
                    ),
                    const Divider(height: 24),
                    Text('Anfangsstand',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.event),
                      label: Text('Stichtag ${_datumKurz(stichtag)}'),
                      onPressed: () async {
                        final neu = await showDatePicker(
                          context: context,
                          initialDate: stichtag,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(stichtag.year + 5),
                        );
                        if (neu != null) setDialogState(() => stichtag = neu);
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Freitags-Urlaub getrennt führen'),
                      subtitle: const Text(
                          'Eigenes Urlaubskonto für Freitage (Mo–Do und Fr '
                          'werden getrennt gutgeschrieben und verbraucht)'),
                      value: urlaubFrGetrennt,
                      onChanged: (v) =>
                          setDialogState(() => urlaubFrGetrennt = v),
                    ),
                    TextFormField(
                      controller: urlaubAnfangsstand,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: urlaubFrGetrennt
                              ? 'Resturlaub-Anfangsstand Mo–Do (Tage)'
                              : 'Resturlaub-Anfangsstand (Tage)',
                          helperText: 'Halbe Tage z.B. als 12,5'),
                      validator: (v) => double.tryParse(
                                  (v ?? '').replaceAll(',', '.')) ==
                              null
                          ? 'Ungültige Zahl'
                          : null,
                    ),
                    if (urlaubFrGetrennt)
                      TextFormField(
                        controller: urlaubFrAnfangsstand,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText:
                                'Resturlaub-Anfangsstand Freitag (Tage)'),
                        validator: (v) => double.tryParse(
                                    (v ?? '').replaceAll(',', '.')) ==
                                null
                            ? 'Ungültige Zahl'
                            : null,
                      ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Firmenurlaub führen'),
                      subtitle: const Text(
                          'Eigenes Konto für internen Zusatzurlaub der Firma '
                          '(z.B. eine Extra-Woche). Verfällt nicht.'),
                      value: firmenurlaubAktiv,
                      onChanged: (v) =>
                          setDialogState(() => firmenurlaubAktiv = v),
                    ),
                    if (firmenurlaubAktiv)
                      TextFormField(
                        controller: firmenurlaubAnfangsstand,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Firmenurlaub-Kontingent (Tage)',
                            helperText:
                                'Gesamtstand zum Stichtag; jährlich selbst '
                                'erhöhen'),
                        validator: (v) => double.tryParse(
                                    (v ?? '').replaceAll(',', '.')) ==
                                null
                            ? 'Ungültige Zahl'
                            : null,
                      ),
                    const SizedBox(height: 8),
                    _ZaAnfangsstandFeld(
                      negativ: zaNegativ,
                      stunden: zaStunden,
                      onNegativ: (v) => setDialogState(() => zaNegativ = v),
                    ),
                    const Divider(height: 24),
                    StandardzeitenFelder(
                      beginn: standardBeginn,
                      ende: standardEnde,
                      pauseMin: standardPauseMin,
                      onBeginn: (t) =>
                          setDialogState(() => standardBeginn = t),
                      onEnde: (t) => setDialogState(() => standardEnde = t),
                      onPause: (m) =>
                          setDialogState(() => standardPauseMin = m),
                      zeigeFreitag: modus == SollModus.moDoFrGetrennt,
                      beginnFr: standardBeginnFr,
                      endeFr: standardEndeFr,
                      pauseFrMin: standardPauseFrMin,
                      onFreitagAbweichend: (an) => setDialogState(() {
                        standardBeginnFr = an ? standardBeginn : null;
                        standardEndeFr = an ? standardEnde : null;
                        standardPauseFrMin = an ? standardPauseMin : null;
                      }),
                      onBeginnFr: (t) =>
                          setDialogState(() => standardBeginnFr = t),
                      onEndeFr: (t) => setDialogState(() => standardEndeFr = t),
                      onPauseFr: (m) =>
                          setDialogState(() => standardPauseFrMin = m),
                    ),
                    if (fehler != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(fehler!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await ref.read(authProvider).benutzerAnlegen(
                        username: username.text,
                        anzeigename: anzeigename.text,
                        passwort: passwort.text,
                        mustChangePassword: true,
                        sollModus: modus,
                        sollTag: double.tryParse(
                            sollTag.text.replaceAll(',', '.')),
                        sollMoDo: double.tryParse(
                            sollMoDo.text.replaceAll(',', '.')),
                        sollFr:
                            double.tryParse(sollFr.text.replaceAll(',', '.')),
                        mitarbeiterEmail: email.text,
                        standardBeginnMin: standardBeginn.hour * 60 +
                            standardBeginn.minute,
                        standardEndeMin:
                            standardEnde.hour * 60 + standardEnde.minute,
                        standardPauseMin: standardPauseMin,
                        anfangsstandStichtag: DateTime(
                            stichtag.year, stichtag.month, stichtag.day),
                        anfangsstandUrlaubTage: double.tryParse(
                                urlaubAnfangsstand.text
                                    .replaceAll(',', '.')) ??
                            0,
                        anfangsstandZeitausgleichMin:
                            _zaMinuten(zaStunden, zaNegativ),
                        urlaubFrGetrennt: urlaubFrGetrennt,
                        anfangsstandUrlaubFrTage: double.tryParse(
                                urlaubFrAnfangsstand.text
                                    .replaceAll(',', '.')) ??
                            0,
                        firmenurlaubAktiv: firmenurlaubAktiv,
                        anfangsstandFirmenurlaubTage: double.tryParse(
                                firmenurlaubAnfangsstand.text
                                    .replaceAll(',', '.')) ??
                            0,
                        standardBeginnFrMin: _minuten(standardBeginnFr),
                        standardEndeFrMin: _minuten(standardEndeFr),
                        standardPauseFrMin: standardPauseFrMin,
                      );
                  if (context.mounted) Navigator.pop(context, true);
                } on ArgumentError catch (e) {
                  setDialogState(() => fehler = e.message as String);
                }
              },
              child: const Text('Anlegen'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) await _lade();
  }

  /// Bearbeitet Sollstunden, Anfangsstände, Standardzeiten und die
  /// E-Mail-Adresse eines bestehenden Profils (später korrigierbar).
  Future<void> _profilBearbeiten(User user) async {
    final db = ref.read(dbProvider);
    final s = await db.settingsFor(user.id);
    final sollTag =
        TextEditingController(text: formatStunden(s.sollStundenTag));
    final sollMoDo =
        TextEditingController(text: formatStunden(s.sollStundenMoDo));
    final sollFr = TextEditingController(text: formatStunden(s.sollStundenFr));
    final email = TextEditingController(text: user.mitarbeiterEmail);
    final urlaubAnfangsstand =
        TextEditingController(text: formatStunden(s.anfangsstandUrlaubTage));
    final urlaubFrAnfangsstand = TextEditingController(
        text: formatStunden(s.anfangsstandUrlaubFrTage));
    var urlaubFrGetrennt = s.urlaubFrGetrennt;
    final firmenurlaubAnfangsstand = TextEditingController(
        text: formatStunden(s.anfangsstandFirmenurlaubTage));
    var firmenurlaubAktiv = s.firmenurlaubAktiv;
    var zaNegativ = s.anfangsstandZeitausgleichMin < 0;
    final zaStunden = TextEditingController(
        text: formatStunden(s.anfangsstandZeitausgleichMin.abs() / 60.0));
    var modus = s.sollModus;
    // Kein Fallback auf "heute": ein Stichtag wird nur gespeichert, wenn
    // Florian ihn bewusst wählt – sonst würden beim bloßen Speichern des
    // Dialogs alle Buchungen vor heute aus der Laufzeit fallen.
    DateTime? stichtag = s.anfangsstandStichtag;
    var standardBeginn =
        _vonMinutenTod(s.standardBeginnMin) ?? const TimeOfDay(hour: 7, minute: 0);
    var standardEnde =
        _vonMinutenTod(s.standardEndeMin) ?? const TimeOfDay(hour: 16, minute: 0);
    var standardPauseMin = s.standardPauseMin;
    var standardBeginnFr = _vonMinutenTod(s.standardBeginnFrMin);
    var standardEndeFr = _vonMinutenTod(s.standardEndeFrMin);
    var standardPauseFrMin = s.standardPauseFrMin;
    if (!mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Profil bearbeiten – ${user.displayName}'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'E-Mail-Adresse (Mitarbeiter)',
                        helperText:
                            'Für die eigene Excel-Kopie beim Mail-Export'),
                  ),
                  const SizedBox(height: 12),
                  _SollFelder(
                    modus: modus,
                    onModus: (m) => setDialogState(() => modus = m),
                    sollTag: sollTag,
                    sollMoDo: sollMoDo,
                    sollFr: sollFr,
                  ),
                  const Divider(height: 24),
                  Text('Anfangsstand',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.event),
                    label: Text(stichtag == null
                        ? 'Stichtag wählen'
                        : 'Stichtag ${_datumKurz(stichtag!)}'),
                    onPressed: () async {
                      final neu = await showDatePicker(
                        context: context,
                        initialDate: stichtag ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (neu != null) setDialogState(() => stichtag = neu);
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Freitags-Urlaub getrennt führen'),
                    subtitle: const Text(
                        'Eigenes Urlaubskonto für Freitage (Mo–Do und Fr '
                        'werden getrennt gutgeschrieben und verbraucht)'),
                    value: urlaubFrGetrennt,
                    onChanged: (v) =>
                        setDialogState(() => urlaubFrGetrennt = v),
                  ),
                  TextField(
                    controller: urlaubAnfangsstand,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: urlaubFrGetrennt
                            ? 'Resturlaub-Anfangsstand Mo–Do (Tage)'
                            : 'Resturlaub-Anfangsstand (Tage)',
                        helperText: 'Halbe Tage z.B. als 12,5'),
                  ),
                  if (urlaubFrGetrennt)
                    TextField(
                      controller: urlaubFrAnfangsstand,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                          labelText:
                              'Resturlaub-Anfangsstand Freitag (Tage)'),
                    ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Firmenurlaub führen'),
                    subtitle: const Text(
                        'Eigenes Konto für internen Zusatzurlaub der Firma '
                        '(z.B. eine Extra-Woche). Verfällt nicht.'),
                    value: firmenurlaubAktiv,
                    onChanged: (v) =>
                        setDialogState(() => firmenurlaubAktiv = v),
                  ),
                  if (firmenurlaubAktiv)
                    TextField(
                      controller: firmenurlaubAnfangsstand,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Firmenurlaub-Kontingent (Tage)',
                          helperText:
                              'Gesamtstand zum Stichtag; jährlich selbst '
                              'erhöhen'),
                    ),
                  const SizedBox(height: 8),
                  _ZaAnfangsstandFeld(
                    negativ: zaNegativ,
                    stunden: zaStunden,
                    onNegativ: (v) => setDialogState(() => zaNegativ = v),
                  ),
                  const Divider(height: 24),
                  StandardzeitenFelder(
                    beginn: standardBeginn,
                    ende: standardEnde,
                    pauseMin: standardPauseMin,
                    onBeginn: (t) => setDialogState(() => standardBeginn = t),
                    onEnde: (t) => setDialogState(() => standardEnde = t),
                    onPause: (m) =>
                        setDialogState(() => standardPauseMin = m),
                    zeigeFreitag: modus == SollModus.moDoFrGetrennt,
                    beginnFr: standardBeginnFr,
                    endeFr: standardEndeFr,
                    pauseFrMin: standardPauseFrMin,
                    onFreitagAbweichend: (an) => setDialogState(() {
                      standardBeginnFr = an ? standardBeginn : null;
                      standardEndeFr = an ? standardEnde : null;
                      standardPauseFrMin = an ? standardPauseMin : null;
                    }),
                    onBeginnFr: (t) =>
                        setDialogState(() => standardBeginnFr = t),
                    onEndeFr: (t) => setDialogState(() => standardEndeFr = t),
                    onPauseFr: (m) =>
                        setDialogState(() => standardPauseFrMin = m),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Speichern')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    double lese(TextEditingController c, double fallback) =>
        double.tryParse(c.text.replaceAll(',', '.')) ?? fallback;
    await (db.update(db.userSettings)
          ..where((t) => t.userId.equals(user.id)))
        .write(UserSettingsCompanion(
      sollModus: Value(modus),
      sollStundenTag: Value(lese(sollTag, 8)),
      sollStundenMoDo: Value(lese(sollMoDo, 8)),
      sollStundenFr: Value(lese(sollFr, 5)),
      standardBeginnMin:
          Value(standardBeginn.hour * 60 + standardBeginn.minute),
      standardEndeMin: Value(standardEnde.hour * 60 + standardEnde.minute),
      standardPauseMin: Value(standardPauseMin),
      anfangsstandStichtag: stichtag == null
          ? const Value.absent()
          : Value(DateTime(
              stichtag!.year, stichtag!.month, stichtag!.day)),
      anfangsstandUrlaubTage:
          Value(lese(urlaubAnfangsstand, s.anfangsstandUrlaubTage)),
      anfangsstandZeitausgleichMin: Value(_zaMinuten(zaStunden, zaNegativ,
          fallbackAbsMin: s.anfangsstandZeitausgleichMin.abs())),
      urlaubFrGetrennt: Value(urlaubFrGetrennt),
      anfangsstandUrlaubFrTage:
          Value(lese(urlaubFrAnfangsstand, s.anfangsstandUrlaubFrTage)),
      firmenurlaubAktiv: Value(firmenurlaubAktiv),
      anfangsstandFirmenurlaubTage: Value(
          lese(firmenurlaubAnfangsstand, s.anfangsstandFirmenurlaubTage)),
      standardBeginnFrMin: Value(_minuten(standardBeginnFr)),
      standardEndeFrMin: Value(_minuten(standardEndeFr)),
      standardPauseFrMin: Value(standardPauseFrMin),
    ));
    await (db.update(db.users)..where((t) => t.id.equals(user.id)))
        .write(UsersCompanion(mitarbeiterEmail: Value(email.text.trim())));
    await _lade();
  }

  Future<void> _passwortZuruecksetzen(User user) async {
    final passwort = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Passwort zurücksetzen – ${user.displayName}'),
        content: TextField(
          controller: passwort,
          decoration: const InputDecoration(
              labelText: 'Neues Start-Passwort',
              helperText: 'Muss beim nächsten Login geändert werden'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Zurücksetzen')),
        ],
      ),
    );
    if (ok != true || passwort.text.length < 4) return;
    final db = ref.read(dbProvider);
    await (db.update(db.users)..where((t) => t.id.equals(user.id))).write(
        UsersCompanion(
            passwordHash: Value(AuthService.hash(passwort.text)),
            mustChangePassword: const Value(true)));
    await _lade();
  }

  Future<void> _loeschen(User user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.displayName} löschen?'),
        content: const Text(
            'Alle Zeiteinträge dieses Benutzers auf DIESEM Gerät werden gelöscht. Das kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Löschen')),
        ],
      ),
    );
    if (ok != true) return;
    final db = ref.read(dbProvider);
    await (db.delete(db.timeEntries)
          ..where((t) => t.userId.equals(user.id)))
        .go();
    await (db.delete(db.userSettings)
          ..where((t) => t.userId.equals(user.id)))
        .go();
    await (db.delete(db.users)..where((t) => t.id.equals(user.id))).go();
    await _lade();
  }

  /// Exportiert alle Mitarbeiter (mit Profil und verschlüsseltem Passwort)
  /// als eine Datei, um sie auf weiteren Geräten einzuspielen. Speichern/
  /// Teilen wie beim Lizenz-Export (Desktop = „Speichern unter").
  Future<void> _benutzerExportieren() async {
    setState(() => _transferLaeuft = true);
    try {
      final json = await ref.read(benutzerTransferProvider).exportiere();
      final firma = (await ref.read(dbProvider).branding()).firmenname.trim();
      final dateiname =
          '${firma.isEmpty ? 'Zeitexa' : firma}_Benutzer.json';
      final bytes = Uint8List.fromList(utf8.encode(json));
      final desktop = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS);
      if (desktop) {
        final pfad = await plattform.speichereDatei(
            'Benutzerdatei speichern', dateiname, ['json'], bytes);
        if (pfad != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Benutzerdatei gespeichert: $pfad')));
        }
        return;
      }
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(bytes,
              name: dateiname, mimeType: 'application/json'),
        ],
        subject: 'Zeitexa Benutzer',
        text: 'Zeitexa-Benutzerdatei zum Importieren auf einem anderen Gerät. '
            'Enthält Zugangsdaten – bitte vertraulich behandeln.',
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export fehlgeschlagen: $e')));
      }
    } finally {
      if (mounted) setState(() => _transferLaeuft = false);
    }
  }

  /// Spielt eine Benutzerdatei ein: neue Mitarbeiter werden angelegt,
  /// bestehende behalten Login/Passwort/Anfangsstände (nur Stundeneinteilung
  /// + E-Mail werden aktualisiert).
  Future<void> _benutzerImportieren() async {
    final inhalt = await waehleBenutzerdatei();
    if (inhalt == null || !mounted) return;
    setState(() => _transferLaeuft = true);
    try {
      // Ohne adminPasswortUebernehmen: der laufende Betrieb darf das
      // Adminpasswort dieses Geräts nie überschreiben.
      final r = await ref.read(benutzerTransferProvider).importiere(inhalt);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${r.neu} neu angelegt, '
              '${r.aktualisiert} aktualisiert.')));
      await _lade();
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import fehlgeschlagen: ${e.message}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import fehlgeschlagen: $e')));
      }
    } finally {
      if (mounted) setState(() => _transferLaeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _neuerBenutzer,
        icon: const Icon(Icons.person_add),
        label: const Text('Mitarbeiter anlegen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Benutzer übertragen',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  const Text(
                      'Alle Mitarbeiter einmal exportieren und auf weiteren '
                      'Geräten (nach der Lizenz-Freischaltung) importieren – '
                      'dann können sich alle mit demselben Passwort anmelden. '
                      'Die Datei enthält Zugangsdaten und ist vertraulich zu '
                      'behandeln.'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    OutlinedButton.icon(
                      onPressed:
                          _transferLaeuft ? null : _benutzerExportieren,
                      icon: const Icon(Icons.ios_share),
                      label: const Text('Benutzer exportieren…'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          _transferLaeuft ? null : _benutzerImportieren,
                      icon: const Icon(Icons.file_open_outlined),
                      label: const Text('Benutzer importieren…'),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          for (final user in _benutzer)
            Card(
              child: ListTile(
                leading: Icon(
                    user.isAdmin ? Icons.verified_user : Icons.person_outline),
                title: Text(user.displayName),
                subtitle: Text(user.username +
                    (user.mustChangePassword
                        ? ' · wartet auf ersten Login'
                        : '')),
                trailing: PopupMenuButton<String>(
                  onSelected: (wert) {
                    switch (wert) {
                      case 'soll':
                        _profilBearbeiten(user);
                      case 'passwort':
                        _passwortZuruecksetzen(user);
                      case 'loeschen':
                        _loeschen(user);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                        value: 'soll', child: Text('Profil bearbeiten')),
                    PopupMenuItem(
                        value: 'passwort',
                        child: Text('Passwort zurücksetzen')),
                    PopupMenuItem(value: 'loeschen', child: Text('Löschen')),
                  ],
                ),
              ),
            ),
        ],
      ),
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
              decoration:
                  const InputDecoration(labelText: 'Stunden Mo–Do')),
          TextField(
              controller: sollFr,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Stunden Freitag')),
        ],
      ],
    );
  }
}

// ---------------------------------------------------- Mail & Optionen

class _MailOptionenTab extends ConsumerStatefulWidget {
  const _MailOptionenTab();

  @override
  ConsumerState<_MailOptionenTab> createState() => _MailOptionenTabState();
}

class _MailOptionenTabState extends ConsumerState<_MailOptionenTab> {
  final _ziel = TextEditingController();
  final _host = TextEditingController();
  final _port = TextEditingController(text: '465');
  final _smtpUser = TextEditingController();
  final _smtpPass = TextEditingController();
  bool _ssl = true;
  bool _autoSend = false;
  bool _sendeSperre = false;
  bool _selbstReg = false;
  bool _biometrieErlaubt = true;
  bool _heuteOeffnet = false;
  bool _geladen = false;
  bool _testLaeuft = false;
  bool _backupLaeuft = false;
  bool _lizenzLaeuft = false;

  @override
  void initState() {
    super.initState();
    _lade();
  }

  Future<void> _lade() async {
    final db = ref.read(dbProvider);
    _ziel.text = await db.getSetting(SettingsKeys.zielEmail) ?? '';
    _host.text = await db.getSetting(SettingsKeys.smtpHost) ?? '';
    _port.text = await db.getSetting(SettingsKeys.smtpPort) ?? '465';
    _smtpUser.text = await db.getSetting(SettingsKeys.smtpUser) ?? '';
    _smtpPass.text = await db.getSetting(SettingsKeys.smtpPass) ?? '';
    _ssl = await db.getBoolSetting(SettingsKeys.smtpSsl, fallback: true);
    _autoSend = await db.getBoolSetting(SettingsKeys.autoSendAktiv);
    _sendeSperre = await db.getBoolSetting(SettingsKeys.sendeSperreAktiv);
    _heuteOeffnet =
        await db.getBoolSetting(SettingsKeys.heuteOeffnetEintragStandard);
    _selbstReg =
        await db.getBoolSetting(SettingsKeys.selbstRegistrierungErlaubt);
    _biometrieErlaubt =
        await db.getBoolSetting(SettingsKeys.biometrieErlaubt, fallback: true);
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
    await db.setBoolSetting(SettingsKeys.sendeSperreAktiv, _sendeSperre);
    await db.setBoolSetting(
        SettingsKeys.heuteOeffnetEintragStandard, _heuteOeffnet);
    await db.setBoolSetting(
        SettingsKeys.selbstRegistrierungErlaubt, _selbstReg);
    await db.setBoolSetting(SettingsKeys.biometrieErlaubt, _biometrieErlaubt);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gespeichert.')));
    }
  }

  Future<void> _testmail() async {
    setState(() => _testLaeuft = true);
    try {
      await _speichern();
      await ref.read(exportProvider).sendeTestmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Testmail wurde gesendet – bitte Posteingang prüfen.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Testmail fehlgeschlagen: $e')));
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
            'durch den Stand der Sicherung ersetzt (Benutzer, Einträge, '
            'Einstellungen, Lizenz). Danach musst du dich neu anmelden.'),
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
      meldung = 'Sicherung wiederhergestellt – bitte neu anmelden.';
    } catch (e) {
      meldung = 'Wiederherstellen fehlgeschlagen: $e';
    }
    if (!mounted) return;
    // Die Datenbank wurde geschlossen: zurück zum StartGate und alle
    // Provider mit der (neuen) Datenbankdatei neu aufbauen.
    Navigator.of(context).popUntil((route) => route.isFirst);
    ref.read(angemeldeterUserProvider.notifier).abmelden();
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
      final firmenname = (await ref.read(dbProvider).branding()).firmenname;
      final lizenzErgebnis = await ref
          .read(lizenzProvider)
          .dateiEinloesen(utf8.decode(bytes), firmenname);
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
                labelText: 'Ziel-Mailadresse (Chef)',
                helperText: 'Dorthin gehen die Monatsberichte')),
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
          Row(children: [
            OutlinedButton.icon(
              onPressed: _testLaeuft ? null : _testmail,
              icon: _testLaeuft
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.outgoing_mail),
              label: const Text('Testmail senden'),
            ),
          ]),
          SwitchListTile(
            title: const Text('Automatischer Versand am Monatsanfang'),
            subtitle: const Text(
                'Beim ersten App-Start im neuen Monat wird der Vormonat automatisch gesendet'),
            value: _autoSend,
            onChanged: (v) => setState(() => _autoSend = v),
          ),
        ] else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                  'Im Browser (PWA) ist kein automatischer SMTP-Versand möglich – '
                  'Mitarbeiter senden den Export über die Mail-App (Teilen).'),
            ),
          ),
        const Divider(height: 32),
        Text('Regeln', style: Theme.of(context).textTheme.titleMedium),
        SwitchListTile(
          title: const Text('Sende-Sperre am Monatswechsel'),
          subtitle: const Text(
              'Ab dem 1. muss zuerst der Vormonat gesendet werden, bevor neue Einträge möglich sind'),
          value: _sendeSperre,
          onChanged: (v) => setState(() => _sendeSperre = v),
        ),
        SwitchListTile(
          title: const Text('Heute-Knopf öffnet den Tageseintrag'),
          subtitle: const Text(
              'Vorgabe für alle Mitarbeiter: „Heute" springt zum aktuellen '
              'Tag und öffnet gleich das Eintragsfenster. Jeder Mitarbeiter '
              'kann das in seinen Einstellungen für sich ändern.'),
          value: _heuteOeffnet,
          onChanged: (v) => setState(() => _heuteOeffnet = v),
        ),
        SwitchListTile(
          title: const Text('Selbst-Registrierung erlauben'),
          subtitle: const Text(
              'Mitarbeiter können sich am Login-Screen selbst registrieren'),
          value: _selbstReg,
          onChanged: (v) => setState(() => _selbstReg = v),
        ),
        SwitchListTile(
          title: const Text('Biometrische Anmeldung erlauben'),
          subtitle: const Text(
              'Mitarbeiter können die Anmeldung per Fingerabdruck/Gesicht '
              'für sich aktivieren. Hinweis: Geräte-Biometrie unterscheidet '
              'keine Personen – jeder am Gerät hinterlegte Fingerabdruck '
              'kann eine aktivierte Anmeldung nutzen.'),
          value: _biometrieErlaubt,
          onChanged: (v) => setState(() => _biometrieErlaubt = v),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _speichern, child: const Text('Speichern')),
        const Divider(height: 32),
        Text('Datensicherung', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        if (backupVerfuegbar) ...[
          const Text(
              'Die Sicherung enthält ALLE Daten dieses Geräts (Benutzer, '
              'Passwörter, Einträge, Einstellungen, Lizenz) in einer Datei – '
              'z.B. um per USB-Stick einen weiteren PC fertig eingerichtet '
              'zu übernehmen oder die Daten zu sichern.'),
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
