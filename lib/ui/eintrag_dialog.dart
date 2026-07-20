import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../export/monats_daten.dart';
import '../logic/berechnung.dart';
import '../logic/feiertage.dart';
import '../main.dart';
import 'standardzeiten_felder.dart';

/// Öffnet den Dialog zum Anlegen/Bearbeiten eines Tages-Eintrags.
Future<void> showEintragDialog(
  BuildContext context,
  WidgetRef ref, {
  required User user,
  required DateTime datum,
  TimeEntry? eintrag,
}) =>
    showDialog(
      context: context,
      builder: (_) => _EintragDialog(user: user, datum: datum, eintrag: eintrag),
    );

class _EintragDialog extends ConsumerStatefulWidget {
  final User user;
  final DateTime datum;
  final TimeEntry? eintrag;

  const _EintragDialog(
      {required this.user, required this.datum, this.eintrag});

  @override
  ConsumerState<_EintragDialog> createState() => _EintragDialogState();
}

class _EintragDialogState extends ConsumerState<_EintragDialog> {
  late Tagesart _tagesart;
  TimeOfDay? _beginn;
  TimeOfDay? _ende;
  int _pauseMin = 30;
  SonderurlaubGrund? _grund;
  late final TextEditingController _ort;
  late final TextEditingController _notiz;

  /// Urlaubsanteil des Tages in Stunden, als Text (z.B. „8" oder „6,25").
  late final TextEditingController _urlaubStunden;
  DateTime? _bisDatum; // für Bereichseintrag (Urlaub von–bis)
  List<Place> _orte = const [];
  String? _fehler;

  /// Benutzereinstellungen – für Sollstunden (Vorbelegung des
  /// Urlaubsanteils) und den Schalter „Firmenurlaub führen".
  UserSetting? _settings;

  @override
  void initState() {
    super.initState();
    final e = widget.eintrag;
    _tagesart = e?.tagesart ??
        (feiertagsName(widget.datum) != null ? Tagesart.feiertag : Tagesart.arbeit);
    _grund = e?.sonderurlaubGrund;
    if (e != null) {
      _beginn = _vonMinuten(e.beginnMin);
      _ende = _vonMinuten(e.endeMin);
      _pauseMin = e.pauseMin;
    } else {
      // Vorbelegung folgt den Standardzeiten des Benutzers, siehe
      // _ladeEinstellungen().
      _beginn = null;
      _ende = null;
    }
    _ort = TextEditingController();
    _notiz = TextEditingController(text: e?.notiz ?? '');
    _urlaubStunden = TextEditingController();
    _ladeOrte(e?.ortId);
    _ladeEinstellungen();
  }

  /// Lädt die Benutzereinstellungen und belegt neue Einträge mit den
  /// Standardzeiten vor (Chef-Vorgabe bzw. vom Mitarbeiter selbst in den
  /// Einstellungen geändert). Am Freitag gelten – falls hinterlegt – die
  /// abweichenden Freitagszeiten, weil der Freitag bei getrenntem Soll
  /// meist kürzer ist.
  Future<void> _ladeEinstellungen() async {
    final s = await ref.read(dbProvider).settingsFor(widget.user.id);
    if (!mounted) return;
    final e = widget.eintrag;
    final standard = standardzeitenFuer(s, widget.datum);
    setState(() {
      _settings = s;
      if (e == null) {
        _beginn = _vonMinuten(standard.beginnMin) ??
            const TimeOfDay(hour: 7, minute: 0);
        _ende = _vonMinuten(standard.endeMin) ??
            const TimeOfDay(hour: 16, minute: 0);
        _pauseMin = standard.pauseMin;
      }
      // Urlaubsanteil: aus dem Eintrag, sonst der ganze Tag (= Tagessoll).
      final minuten = e?.urlaubMinuten ??
          (e != null && e.halberTag ? (_tagesSoll * 30).round() : null);
      _urlaubStunden.text =
          formatStunden(minuten != null ? minuten / 60.0 : _tagesSoll);
    });
  }

  /// Sollstunden des bearbeiteten Tages laut Benutzereinstellungen.
  double get _tagesSoll {
    final s = _settings;
    if (s == null) return 8;
    return SollRegel(
      modus: s.sollModus,
      stundenTag: s.sollStundenTag,
      stundenMoDo: s.sollStundenMoDo,
      stundenFr: s.sollStundenFr,
    ).sollFuer(widget.datum);
  }

  /// Eingegebener Urlaubsanteil in Stunden (null = unlesbar).
  double? get _urlaubStundenWert =>
      double.tryParse(_urlaubStunden.text.replaceAll(',', '.'));

  /// Wird an diesem Tag nur ein Teil als Urlaub genommen? Dann dürfen
  /// zusätzlich Arbeitszeiten erfasst werden.
  bool get _istTeilUrlaub {
    final wert = _urlaubStundenWert;
    return wert != null && wert > 0 && wert < _tagesSoll;
  }

  Future<void> _ladeOrte(int? aktuellerOrtId) async {
    final db = ref.read(dbProvider);
    final orte = await db.recentPlaces();
    String ortName = '';
    if (aktuellerOrtId != null) {
      final alle = await db.select(db.places).get();
      ortName = alle
          .where((p) => p.id == aktuellerOrtId)
          .map((p) => p.name)
          .firstOrNull ??
          '';
    }
    if (mounted) {
      setState(() {
        _orte = orte;
        if (ortName.isNotEmpty) _ort.text = ortName;
      });
    }
  }

  @override
  void dispose() {
    _ort.dispose();
    _notiz.dispose();
    _urlaubStunden.dispose();
    super.dispose();
  }

  TimeOfDay? _vonMinuten(int? minuten) => minuten == null
      ? null
      : TimeOfDay(hour: minuten ~/ 60, minute: minuten % 60);

  int _zuMinuten(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _speichern() async {
    final db = ref.read(dbProvider);
    int? beginnMin, endeMin;
    var pauseMin = 0;
    int? ortId;

    final istUrlaubsart = urlaubsArten.contains(_tagesart);
    // Urlaubsanteil: null heißt „ganzer Tag". Nur beim Einzeltag
    // einstellbar, ein Bereichseintrag gilt immer voll.
    int? urlaubMinuten;
    if (istUrlaubsart && _bisDatum == null) {
      final wert = _urlaubStundenWert;
      if (wert == null || wert <= 0) {
        setState(() => _fehler = 'Urlaubsstunden angeben (z.B. 6,25).');
        return;
      }
      if (wert > _tagesSoll) {
        setState(() => _fehler =
            'Mehr als das Tagessoll (${formatStunden(_tagesSoll)} h) geht nicht.');
        return;
      }
      // Voller Tag bleibt bewusst null, damit er einer späteren
      // Soll-Änderung folgt.
      if (wert < _tagesSoll) urlaubMinuten = (wert * 60).round();
    }

    if (_tagesart == Tagesart.arbeit || (istUrlaubsart && _istTeilUrlaub)) {
      beginnMin = _beginn == null ? null : _zuMinuten(_beginn!);
      endeMin = _ende == null ? null : _zuMinuten(_ende!);
      pauseMin = _pauseMin;
      if (beginnMin == null || endeMin == null || endeMin <= beginnMin) {
        if (_tagesart == Tagesart.arbeit) {
          setState(() => _fehler = 'Ende muss nach Beginn liegen.');
          return;
        }
        // Beim Teil-Urlaub sind Arbeitszeiten freiwillig: wer nur halbtags
        // Urlaub nimmt und den Rest nicht arbeitet, bekommt Minusstunden.
        beginnMin = null;
        endeMin = null;
        pauseMin = 0;
      }
      if (_ort.text.trim().isNotEmpty) {
        ortId = await db.touchPlace(_ort.text);
      }
    }

    final tage = <DateTime>[widget.datum];
    if (_bisDatum != null && _tagesart != Tagesart.arbeit) {
      var d = widget.datum;
      while (d.isBefore(_bisDatum!)) {
        d = DateTime(d.year, d.month, d.day + 1);
        // Sa/So bei Bereichseinträgen überspringen
        if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) {
          tage.add(d);
        }
      }
    }

    for (final tag in tage) {
      await db.upsertEntry(TimeEntriesCompanion.insert(
        userId: widget.user.id,
        datum: DateTime(tag.year, tag.month, tag.day),
        tagesart: _tagesart,
        ortId: Value(ortId),
        beginnMin: Value(beginnMin),
        pauseMin: Value(pauseMin),
        endeMin: Value(endeMin),
        notiz: Value(_notiz.text.trim()),
        // Altformat wird nicht mehr geschrieben, siehe urlaubAnteil().
        halberTag: const Value(false),
        urlaubMinuten: Value(urlaubMinuten),
        sonderurlaubGrund:
            Value(_tagesart == Tagesart.sonderurlaub ? _grund : null),
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _loeschen() async {
    await ref.read(dbProvider).deleteEntry(widget.user.id,
        DateTime(widget.datum.year, widget.datum.month, widget.datum.day));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _zeitWaehlen(bool istBeginn) async {
    final aktuell = istBeginn ? _beginn : _ende;
    final neu = await showTimePicker(
      context: context,
      initialTime: aktuell ?? const TimeOfDay(hour: 7, minute: 0),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (neu != null) {
      setState(() => istBeginn ? _beginn = neu : _ende = neu);
    }
  }

  /// Übernimmt die aktuelle Geräte-Uhrzeit (minutengenau) als Beginn/Ende.
  void _jetzt(bool istBeginn) {
    final jetzt = TimeOfDay.now();
    setState(() => istBeginn ? _beginn = jetzt : _ende = jetzt);
  }

  /// Ort-Eingabe mit Schnellauswahl der zuletzt verwendeten Orte.
  List<Widget> _ortFelder() => [
        TextField(
          controller: _ort,
          decoration: const InputDecoration(
              labelText: 'Ort (z.B. Baustelle)',
              prefixIcon: Icon(Icons.place_outlined)),
        ),
        if (_orte.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: -6,
              children: [
                for (final ort in _orte)
                  ActionChip(
                    label: Text(ort.name),
                    onPressed: () => setState(() => _ort.text = ort.name),
                  ),
              ],
            ),
          ),
      ];

  /// Beginn/Ende/Pause – bei Arbeit und beim Teil-Urlaub.
  List<Widget> _zeitFelder() {
    String uhr(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return [
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.login),
              label:
                  Text(_beginn == null ? 'Beginn' : 'Beginn ${uhr(_beginn!)}'),
              onPressed: () => _zeitWaehlen(true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: Text(_ende == null ? 'Ende' : 'Ende ${uhr(_ende!)}'),
              onPressed: () => _zeitWaehlen(false),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('Jetzt Beginn'),
              onPressed: () => _jetzt(true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('Jetzt Ende'),
              onPressed: () => _jetzt(false),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        icon: const Icon(Icons.free_breakfast_outlined),
        label: Text('Pause ${formatPause(_pauseMin)}'),
        onPressed: () async {
          final neu = await zeigePauseUhr(context, initialMinuten: _pauseMin);
          if (neu != null) setState(() => _pauseMin = neu);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final feiertag = feiertagsName(widget.datum);
    final titel =
        '${widget.datum.day.toString().padLeft(2, '0')}.${widget.datum.month.toString().padLeft(2, '0')}.${widget.datum.year} '
        '(${wochentagKurz[widget.datum.weekday - 1]})';

    return AlertDialog(
      title: Text(titel),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (feiertag != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Feiertag: $feiertag',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary)),
                ),
              Wrap(
                spacing: 6,
                children: [
                  for (final art in Tagesart.values)
                    // „Frei" ist kein wählbarer Eintrag; Firmenurlaub nur,
                    // wenn der Chef das Konto für diesen Mitarbeiter führt.
                    if (art != Tagesart.frei &&
                        (art != Tagesart.firmenurlaub ||
                            (_settings?.firmenurlaubAktiv ?? false)))
                      ChoiceChip(
                        label: Text(tagesartLabel[art]!),
                        selected: _tagesart == art,
                        onSelected: (_) => setState(() => _tagesart = art),
                      ),
                ],
              ),
              const SizedBox(height: 12),
              if (_tagesart == Tagesart.arbeit) ...[
                ..._ortFelder(),
                const SizedBox(height: 12),
                ..._zeitFelder(),
              ] else ...[
                // Bereichseintrag: z.B. Urlaub von–bis
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_bisDatum == null
                      ? 'Nur dieser Tag (optional: bis-Datum wählen)'
                      : 'Bis ${_bisDatum!.day.toString().padLeft(2, '0')}.${_bisDatum!.month.toString().padLeft(2, '0')}.${_bisDatum!.year}'),
                  onPressed: () async {
                    final bis = await showDatePicker(
                      context: context,
                      initialDate: widget.datum,
                      firstDate: widget.datum,
                      lastDate: DateTime(widget.datum.year + 1, 12, 31),
                    );
                    setState(() => _bisDatum = bis);
                  },
                ),
                if (_bisDatum != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Sa/So werden übersprungen.',
                        style: TextStyle(fontSize: 12)),
                  ),
                if (_tagesart == Tagesart.sonderurlaub) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SonderurlaubGrund>(
                    initialValue: _grund,
                    decoration: const InputDecoration(
                        labelText: 'Grund',
                        prefixIcon: Icon(Icons.help_outline)),
                    items: [
                      for (final g in SonderurlaubGrund.values)
                        DropdownMenuItem(
                            value: g, child: Text(sonderurlaubGrundLabel[g]!)),
                    ],
                    onChanged: (g) => setState(() => _grund = g),
                  ),
                ],
                if (urlaubsArten.contains(_tagesart) &&
                    _bisDatum == null) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlaubStunden,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText:
                          '${tagesartLabel[_tagesart]} (Stunden an diesem Tag)',
                      prefixIcon: const Icon(Icons.beach_access_outlined),
                      helperText: 'Ganzer Tag = ${formatStunden(_tagesSoll)} h. '
                          'Weniger eingeben, wenn du den Rest arbeitest.',
                      helperMaxLines: 2,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_istTeilUrlaub) ...[
                    const SizedBox(height: 12),
                    ..._ortFelder(),
                    const SizedBox(height: 12),
                    ..._zeitFelder(),
                  ],
                ],
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _notiz,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Notiz (was/wie/wo/wer)',
                    prefixIcon: Icon(Icons.notes)),
              ),
              if (_fehler != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_fehler!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.eintrag != null)
          TextButton(
            onPressed: _loeschen,
            child: Text('Löschen',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen')),
        FilledButton(onPressed: _speichern, child: const Text('Speichern')),
      ],
    );
  }
}
