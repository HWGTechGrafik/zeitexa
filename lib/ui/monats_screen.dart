import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../export/monats_daten.dart';
import '../logic/berechnung.dart';
import '../logic/konten.dart';
import '../main.dart';
import 'admin_screen.dart';
import 'eintrag_dialog.dart';
import 'einstellungen_screen.dart';
import 'ueber_dialog.dart';

class MonatsScreen extends ConsumerStatefulWidget {
  final User user;
  const MonatsScreen({super.key, required this.user});

  @override
  ConsumerState<MonatsScreen> createState() => _MonatsScreenState();
}

class _MonatsScreenState extends ConsumerState<MonatsScreen> {
  late int _jahr;
  late int _monat;
  SollRegel? _regel;
  UserSetting? _settings;
  String? _sperrMonat; // 'JJJJ-MM' des noch nicht versendeten Vormonats
  final _liste = ScrollController();

  @override
  void dispose() {
    _liste.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final heute = DateTime.now();
    _jahr = heute.year;
    _monat = heute.month;
    _lade();
  }

  Future<void> _lade() async {
    final export = ref.read(exportProvider);
    final regel = await export.regelFuer(widget.user.id);
    final settings = await ref.read(dbProvider).settingsFor(widget.user.id);
    final sperre = await export.sperrGrund(widget.user, DateTime.now());
    if (mounted) {
      setState(() {
        _regel = regel;
        _settings = settings;
        _sperrMonat = sperre;
      });
      if (sperre == null) _autoVersand();
    }
  }

  /// Springt auf den aktuellen Monat, scrollt zur heutigen Zeile und
  /// öffnet auf Wunsch (Chef-Vorgabe bzw. eigener Schalter in den
  /// Einstellungen) direkt den Tageseintrag.
  Future<void> _heute() async {
    final heute = DateTime.now();
    setState(() {
      _jahr = heute.year;
      _monat = heute.month;
    });
    _scrolleZuHeute(heute);
    final db = ref.read(dbProvider);
    final oeffnen = await db.heuteOeffnetEintragFuer(widget.user.id);
    if (!oeffnen || !mounted) return;
    final eintraege =
        await db.entriesForMonth(widget.user.id, heute.year, heute.month);
    final eintrag = eintraege
        .where((e) =>
            e.datum.year == heute.year &&
            e.datum.month == heute.month &&
            e.datum.day == heute.day)
        .firstOrNull;
    if (!mounted) return;
    await _oeffneEintrag(
        DateTime(heute.year, heute.month, heute.day), eintrag);
  }

  /// Scrollt die Tagesliste so, dass der heutige Tag ungefähr in der
  /// Mitte steht. Die Zeilenhöhe wird aus der Gesamthöhe der Liste
  /// geschätzt (die Zeilen sind praktisch gleich hoch).
  void _scrolleZuHeute(DateTime heute) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_liste.hasClients) return;
      final tage = DateTime(heute.year, heute.month + 1, 0).day;
      final position = _liste.position;
      final gesamt = position.maxScrollExtent + position.viewportDimension;
      final zeilenHoehe = gesamt / tage;
      final ziel = (zeilenHoehe * (heute.day - 1) -
              position.viewportDimension / 2 +
              zeilenHoehe / 2)
          .clamp(0.0, position.maxScrollExtent);
      _liste.animateTo(ziel,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  /// Automatischer SMTP-Versand des Vormonats beim ersten Start im neuen Monat.
  Future<void> _autoVersand() async {
    final db = ref.read(dbProvider);
    final export = ref.read(exportProvider);
    if (!await db.getBoolSetting(SettingsKeys.autoSendAktiv)) return;
    if (!await export.smtpKonfiguriert()) return;
    final heute = DateTime.now();
    final vJahr = heute.month == 1 ? heute.year - 1 : heute.year;
    final vMonat = heute.month == 1 ? 12 : heute.month - 1;
    final key = monatsKey(vJahr, vMonat);
    if (await export.istVersendet(widget.user.id, key)) return;
    final eintraege = await db.entriesForMonth(widget.user.id, vJahr, vMonat);
    if (eintraege.isEmpty) return;
    try {
      final dateien = await export.erzeuge(widget.user, vJahr, vMonat);
      await export.sendeSmtp(dateien);
      final mitarbeiterEmail = widget.user.mitarbeiterEmail.trim();
      if (mitarbeiterEmail.isNotEmpty) {
        await export.sendeSmtpMitarbeiterKopie(dateien, mitarbeiterEmail);
      }
      await export.markiereVersendet(widget.user.id, key);
      _meldung('Vormonat ${monatsTitel(vJahr, vMonat)} wurde automatisch per Mail versendet.');
    } catch (e) {
      _meldung('Automatischer Versand fehlgeschlagen: $e');
    }
  }

  void _meldung(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  /// Ist die Erfassung wegen der Sende-Sperre blockiert?
  /// Gesperrt sind alle Monate NACH dem nicht versendeten Vormonat.
  bool get _gesperrt {
    final sperre = _sperrMonat;
    if (sperre == null) return false;
    return monatsKey(_jahr, _monat).compareTo(sperre) > 0;
  }

  void _wechsleMonat(int delta) {
    setState(() {
      final d = DateTime(_jahr, _monat + delta, 1);
      _jahr = d.year;
      _monat = d.month;
    });
  }

  Future<void> _oeffneEintrag(DateTime datum, TimeEntry? eintrag) async {
    if (_gesperrt) {
      _meldung('Bitte zuerst den Vormonat per Mail senden.');
      return;
    }
    await showEintragDialog(context, ref,
        user: widget.user, datum: datum, eintrag: eintrag);
  }

  Future<void> _exportMenu({String? erzwungenerMonat}) async {
    final export = ref.read(exportProvider);
    var jahr = _jahr, monat = _monat;
    if (erzwungenerMonat != null) {
      jahr = int.parse(erzwungenerMonat.split('-')[0]);
      monat = int.parse(erzwungenerMonat.split('-')[1]);
    }
    final smtpBereit = await export.smtpKonfiguriert();
    final mitarbeiterEmail = widget.user.mitarbeiterEmail.trim();
    var kopieAnMitarbeiter = mitarbeiterEmail.isNotEmpty;
    if (!mounted) return;
    final aktion = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Monat ${monatsTitel(jahr, monat)} exportieren',
                    style: Theme.of(context).textTheme.titleMedium),
                subtitle: const Text('JSON + Excel + PDF'),
              ),
              if (smtpBereit && mitarbeiterEmail.isNotEmpty)
                SwitchListTile(
                  title: const Text('Kopie an Mitarbeiter (nur Excel-Liste)'),
                  subtitle: Text(mitarbeiterEmail),
                  value: kopieAnMitarbeiter,
                  onChanged: (v) =>
                      setSheetState(() => kopieAnMitarbeiter = v),
                ),
              if (smtpBereit)
                ListTile(
                  leading: const Icon(Icons.send),
                  title: const Text('Per Mail senden (automatisch)'),
                  onTap: () => Navigator.pop(context, 'smtp'),
                ),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Per Mail-App / Teilen weitergeben'),
                onTap: () => Navigator.pop(context, 'teilen'),
              ),
              if (export.smtpMoeglich)
                ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: const Text('Nur als Dateien speichern'),
                  onTap: () => Navigator.pop(context, 'speichern'),
                ),
            ],
          ),
        ),
      ),
    );
    if (aktion == null || !mounted) return;

    try {
      final dateien = await export.erzeuge(widget.user, jahr, monat);
      final key = monatsKey(jahr, monat);
      switch (aktion) {
        case 'smtp':
          await export.sendeSmtp(dateien);
          if (kopieAnMitarbeiter && mitarbeiterEmail.isNotEmpty) {
            await export.sendeSmtpMitarbeiterKopie(dateien, mitarbeiterEmail);
          }
          await export.markiereVersendet(widget.user.id, key);
          _meldung('Mail wurde gesendet.');
        case 'teilen':
          await export.teilePerMailApp(dateien);
          if (!mounted) return;
          final bestaetigt = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Wurde die Mail gesendet?'),
              content: const Text(
                  'Wenn du die Datei per Mail verschickt hast, wird der Monat als versendet markiert.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Nein')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Ja, gesendet')),
              ],
            ),
          );
          if (bestaetigt == true) {
            await export.markiereVersendet(widget.user.id, key);
          }
        case 'speichern':
          final pfade = await export.speichereLokal(dateien);
          _meldung(pfade.isEmpty
              ? 'Speichern ist auf dieser Plattform nicht möglich.'
              : 'Gespeichert unter:\n${pfade.first.substring(0, pfade.first.lastIndexOf(RegExp(r'[/\\]')))}');
      }
      await _lade(); // Sperre neu bewerten
    } catch (e) {
      _meldung('Export fehlgeschlagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final regel = _regel;
    final settings = _settings;
    if (regel == null || settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final heute = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text('${monatsTitel(_jahr, _monat)} – ${widget.user.displayName}'),
        actions: [
          TextButton.icon(
              onPressed: _heute,
              style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.onSurfaceVariant),
              icon: const Icon(Icons.today),
              label: const Text('Heute')),
          IconButton(
              tooltip: 'Voriger Monat',
              onPressed: () => _wechsleMonat(-1),
              icon: const Icon(Icons.chevron_left)),
          IconButton(
              tooltip: 'Nächster Monat',
              onPressed: () => _wechsleMonat(1),
              icon: const Icon(Icons.chevron_right)),
          PopupMenuButton<String>(
            onSelected: (wert) async {
              switch (wert) {
                case 'export':
                  await _exportMenu();
                case 'einstellungen':
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              EinstellungenScreen(user: widget.user)));
                  _lade();
                case 'admin':
                  await oeffneAdminBereich(context, ref);
                  _lade();
                case 'ueber':
                  await zeigeUeberDialog(context, ref);
                case 'abmelden':
                  ref.read(angemeldeterUserProvider.notifier).abmelden();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                      leading: Icon(Icons.outbox), title: Text('Monat exportieren/senden'))),
              PopupMenuItem(
                  value: 'einstellungen',
                  child: ListTile(
                      leading: Icon(Icons.settings), title: Text('Einstellungen'))),
              PopupMenuItem(
                  value: 'admin',
                  child: ListTile(
                      leading: Icon(Icons.admin_panel_settings),
                      title: Text('Chef-Bereich'))),
              PopupMenuItem(
                  value: 'ueber',
                  child: ListTile(
                      leading: Icon(Icons.info_outline), title: Text('Über Zeitexa'))),
              PopupMenuItem(
                  value: 'abmelden',
                  child: ListTile(
                      leading: Icon(Icons.logout), title: Text('Abmelden'))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_gesperrt)
            MaterialBanner(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              content: Text(
                  'Der Vormonat wurde noch nicht per Mail gesendet. '
                  'Neue Einträge sind erst nach dem Senden möglich.'),
              actions: [
                FilledButton(
                  onPressed: () => _exportMenu(erzwungenerMonat: _sperrMonat),
                  child: const Text('Jetzt senden'),
                ),
              ],
            ),
          Expanded(
            child: StreamBuilder<List<TimeEntry>>(
              stream:
                  ref.read(dbProvider).watchMonth(widget.user.id, _jahr, _monat),
              builder: (context, snap) {
                final eintraege = snap.data ?? const <TimeEntry>[];
                return StreamBuilder<List<TimeEntry>>(
                  stream: ref.read(dbProvider).watchAllEntries(widget.user.id),
                  builder: (context, alleSnap) {
                    final alleEintraege = alleSnap.data ?? const <TimeEntry>[];
                    return FutureBuilder<Map<int, String>>(
                      future: ref
                          .read(dbProvider)
                          .select(ref.read(dbProvider).places)
                          .get()
                          .then((ps) => {for (final p in ps) p.id: p.name}),
                      builder: (context, orteSnap) {
                        final orte = orteSnap.data ?? const <int, String>{};
                        final zeilen = monatsZeilen(
                            jahr: _jahr,
                            monat: _monat,
                            eintraege: eintraege,
                            ortNamen: orte,
                            regel: regel);
                        final summe = monatsSumme(eintraege, regel);
                        final konten = berechneKonten(
                          alleEintraege: alleEintraege,
                          regel: regel,
                          jahr: _jahr,
                          monat: _monat,
                          anfangsstandUrlaubTage:
                              settings.anfangsstandUrlaubTage,
                          anfangsstandZeitausgleichStunden:
                              settings.anfangsstandZeitausgleichMin / 60.0,
                          anfangsstandStichtag: settings.anfangsstandStichtag,
                          urlaubFrGetrennt: settings.urlaubFrGetrennt,
                          anfangsstandUrlaubFrTage:
                              settings.anfangsstandUrlaubFrTage,
                          firmenurlaubAktiv: settings.firmenurlaubAktiv,
                          anfangsstandFirmenurlaubTage:
                              settings.anfangsstandFirmenurlaubTage,
                        );
                        return Column(children: [
                          _UebersichtKarte(
                              summe: summe,
                              konten: konten,
                              urlaubFrGetrennt: settings.urlaubFrGetrennt,
                              firmenurlaubAktiv: settings.firmenurlaubAktiv),
                          Expanded(
                            child: ListView.separated(
                              controller: _liste,
                              itemCount: zeilen.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) => _TagZeile(
                                zeile: zeilen[i],
                                istHeute: zeilen[i].datum.year == heute.year &&
                                    zeilen[i].datum.month == heute.month &&
                                    zeilen[i].datum.day == heute.day,
                                onTap: () => _oeffneEintrag(
                                    zeilen[i].datum, zeilen[i].eintrag),
                              ),
                            ),
                          ),
                        ]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TagZeile extends StatelessWidget {
  final MonatsZeile zeile;
  final bool istHeute;
  final VoidCallback onTap;

  const _TagZeile(
      {required this.zeile, required this.istHeute, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = zeile.eintrag;
    final erg = zeile.ergebnis;
    final istFeiertag = zeile.feiertagsname != null;

    Color? hintergrund;
    if (istHeute) {
      hintergrund = theme.colorScheme.primaryContainer.withValues(alpha: 0.35);
    } else if (zeile.istWochenende) {
      hintergrund = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    } else if (istFeiertag) {
      hintergrund = theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3);
    }

    String mitte;
    if (e == null) {
      mitte = zeile.feiertagsname ?? '';
    } else {
      switch (e.tagesart) {
        case Tagesart.arbeit:
          mitte =
              '${formatUhrzeit(e.beginnMin)}–${formatUhrzeit(e.endeMin)}'
              '${e.pauseMin > 0 ? ' · ${e.pauseMin} min Pause' : ''}'
              '${zeile.ort.isNotEmpty ? ' · ${zeile.ort}' : ''}';
        default:
          mitte = tagesartLabel[e.tagesart] ?? '';
          if (e.tagesart == Tagesart.feiertag && zeile.feiertagsname != null) {
            mitte = 'Feiertag – ${zeile.feiertagsname}';
          }
          final grund = e.sonderurlaubGrund;
          if (grund != null) mitte += ' – ${sonderurlaubGrundLabel[grund]}';
          // Teil-Urlaub: Anteil und ggf. die daneben gearbeitete Zeit.
          if (e.urlaubMinuten != null) {
            mitte += ' · ${formatStunden(e.urlaubMinuten! / 60.0)} h';
            if (e.beginnMin != null && e.endeMin != null) {
              mitte += ' · gearbeitet '
                  '${formatUhrzeit(e.beginnMin)}–${formatUhrzeit(e.endeMin)}';
            }
          }
      }
      if (e.notiz.isNotEmpty) mitte += '\n${e.notiz}';
    }

    return Material(
      color: hintergrund ?? Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  zeile.tagLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: istHeute ? FontWeight.bold : null,
                    color: zeile.istWochenende || istFeiertag
                        ? theme.colorScheme.error
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  mitte,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (erg != null) ...[
                SizedBox(
                  width: 76,
                  child: Text(
                    '${formatStunden(erg.ist)} / ${formatStunden(erg.soll)}',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    formatStunden(erg.ueberstunden, vorzeichen: true),
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: erg.ueberstunden < 0
                          ? theme.colorScheme.error
                          : (erg.ueberstunden > 0
                              ? Colors.green.shade700
                              : null),
                    ),
                  ),
                ),
              ] else
                const SizedBox(width: 132),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kompakte, farbige Übersichtskarte direkt unter der Monatsauswahl: Block
/// „Zeit" (Ist/Soll/Überstunden, aktueller Monat) und Block „Konten"
/// (Resturlaub/Zeitausgleich/Kranktage, umschaltbar Monat/Laufzeit)
/// nebeneinander.
class _UebersichtKarte extends StatefulWidget {
  final MonatsSumme summe;
  final KontenStand konten;
  final bool urlaubFrGetrennt;
  final bool firmenurlaubAktiv;
  const _UebersichtKarte(
      {required this.summe,
      required this.konten,
      this.urlaubFrGetrennt = false,
      this.firmenurlaubAktiv = false});

  @override
  State<_UebersichtKarte> createState() => _UebersichtKarteState();
}

class _UebersichtKarteState extends State<_UebersichtKarte> {
  bool _laufzeit = true;

  Widget _zeile(ThemeData theme, String label, String wert, {Color? farbe}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(wert,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600, color: farbe)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ueberstunden = widget.summe.ueberstunden;
    final urlaub = _laufzeit ? widget.konten.urlaubGesamt : widget.konten.urlaubMonat;
    final urlaubFr =
        _laufzeit ? widget.konten.urlaubFrGesamt : widget.konten.urlaubFrMonat;
    final zeitausgleich =
        _laufzeit ? widget.konten.zeitausgleichGesamt : widget.konten.zeitausgleichMonat;
    final krank = _laufzeit ? widget.konten.krankGesamt : widget.konten.krankMonat;
    final sonderurlaub = _laufzeit
        ? widget.konten.sonderurlaubGesamt
        : widget.konten.sonderurlaubMonat;
    final firmenurlaub = _laufzeit
        ? widget.konten.firmenurlaubGesamt
        : widget.konten.firmenurlaubMonat;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Zeit – aktueller Monat',
                          style: theme.textTheme.labelMedium),
                      const SizedBox(height: 4),
                      _zeile(theme, 'Ist', '${formatStunden(widget.summe.summeIst)} h'),
                      _zeile(theme, 'Soll', '${formatStunden(widget.summe.summeSoll)} h'),
                      _zeile(theme, 'Überstunden',
                          '${formatStunden(ueberstunden, vorzeichen: true)} h',
                          farbe: ueberstunden < 0
                              ? theme.colorScheme.error
                              : (ueberstunden > 0 ? Colors.green.shade700 : null)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Konten', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          segments: const [
                            ButtonSegment(value: false, label: Text('Monat')),
                            ButtonSegment(value: true, label: Text('Laufzeit')),
                          ],
                          selected: {_laufzeit},
                          onSelectionChanged: (s) =>
                              setState(() => _laufzeit = s.first),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (widget.urlaubFrGetrennt) ...[
                        _zeile(theme, 'Resturlaub Mo–Do',
                            '${formatStunden(urlaub)} Tage'),
                        _zeile(theme, 'Resturlaub Fr',
                            '${formatStunden(urlaubFr)} Tage'),
                      ] else
                        _zeile(theme, 'Resturlaub',
                            '${formatStunden(urlaub)} Tage'),
                      if (widget.firmenurlaubAktiv)
                        _zeile(
                            theme,
                            _laufzeit ? 'Firmenurlaub (Rest)' : 'Firmenurlaub',
                            '${formatStunden(firmenurlaub)} Tage'),
                      // Sonderurlaub hat kein Kontingent – hier steht der
                      // Verbrauch, kein Restsaldo. Erst ab dem ersten Tag
                      // einblenden, damit die Karte sonst ruhig bleibt.
                      if (sonderurlaub > 0)
                        _zeile(theme, 'Sonderurlaub',
                            '${formatStunden(sonderurlaub)} Tage'),
                      _zeile(theme, 'Zeitausgleich',
                          '${formatStunden(zeitausgleich, vorzeichen: true)} h',
                          farbe: zeitausgleich < 0
                              ? theme.colorScheme.error
                              : (zeitausgleich > 0 ? Colors.green.shade700 : null)),
                      _zeile(theme, 'Kranktage', '$krank'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
