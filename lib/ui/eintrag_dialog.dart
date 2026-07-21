import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../export/export_service.dart' show sollRegelAus;
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

/// Ein einzelner Stempel-Block in der Eingabemaske (Beginn/Ende). Ende darf
/// leer bleiben (noch nicht ausgestempelt).
class _Block {
  TimeOfDay? beginn;
  TimeOfDay? ende;
  _Block({this.beginn, this.ende});
}

class _EintragDialogState extends ConsumerState<_EintragDialog> {
  late Tagesart _tagesart;

  /// Stempel-Blöcke des Tages. Bei einem Block gilt zusätzlich [_pauseMin];
  /// bei mehreren zählen die Lücken zwischen den Blöcken als Pause.
  final List<_Block> _bloecke = [];
  int _pauseMin = 30;
  SonderurlaubGrund? _grund;

  /// Sperrt Speichern/Löschen gegen versehentliches Doppeltippen (sonst
  /// schließt der zweite Tipp die dahinterliegende Monatsansicht → weißer
  /// Bildschirm).
  bool _busy = false;

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
      // Ein Block aus den flachen Feldern; mehrere Blöcke lädt
      // _ladeEinstellungen() bei Bedarf aus der Zeitblock-Tabelle nach.
      _bloecke.add(_Block(
          beginn: _vonMinuten(e.beginnMin), ende: _vonMinuten(e.endeMin)));
      _pauseMin = e.pauseMin;
    } else {
      // Ein leerer Block; Vorbelegung folgt den Standardzeiten des
      // Benutzers, siehe _ladeEinstellungen().
      _bloecke.add(_Block());
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
    final db = ref.read(dbProvider);
    final s = await db.settingsFor(widget.user.id);
    final e = widget.eintrag;
    // Mehrere Blöcke des Tages aus der Zeitblock-Tabelle nachladen.
    List<_Block>? mehrfach;
    if (e != null) {
      final blk = await db.bloeckeFuer(e.id);
      if (blk.length >= 2) {
        mehrfach = [
          for (final b in blk)
            _Block(beginn: _vonMinuten(b.beginnMin), ende: _vonMinuten(b.endeMin))
        ];
      }
    }
    if (!mounted) return;
    final standard = standardzeitenFuer(s, widget.datum);
    setState(() {
      _settings = s;
      if (e == null) {
        _bloecke
          ..clear()
          ..add(_Block(
            beginn: _vonMinuten(standard.beginnMin) ??
                const TimeOfDay(hour: 7, minute: 0),
            ende: _vonMinuten(standard.endeMin) ??
                const TimeOfDay(hour: 16, minute: 0),
          ));
        _pauseMin = standard.pauseMin;
      } else if (mehrfach != null) {
        _bloecke
          ..clear()
          ..addAll(mehrfach);
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
    return sollRegelAus(s).sollFuer(widget.datum);
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

  /// Wertet die Blockliste aus. Liefert die flachen Felder für den Tageskopf
  /// (bei mehreren Blöcken stecken die Lücken in [pauseMin] und ein noch
  /// offener Block ergibt `endeMin == null`) sowie die zu speichernden
  /// Blöcke (leer bei höchstens einem Block). Bei einem Fehler wird
  /// [_fehler] gesetzt und `null` zurückgegeben.
  ({
    int? beginnMin,
    int? endeMin,
    int pauseMin,
    List<({int beginnMin, int? endeMin})> bloecke,
  })? _sammleZeiten() {
    final gueltig = <({int beginnMin, int? endeMin})>[];
    for (final b in _bloecke) {
      if (b.beginn == null) continue; // leerer Block wird ignoriert
      final bm = _zuMinuten(b.beginn!);
      final em = b.ende == null ? null : _zuMinuten(b.ende!);
      if (em != null && em <= bm) {
        _fehler = 'Ende muss nach Beginn liegen.';
        return null;
      }
      gueltig.add((beginnMin: bm, endeMin: em));
    }
    gueltig.sort((a, b) => a.beginnMin.compareTo(b.beginnMin));
    final offene = gueltig.where((b) => b.endeMin == null).length;
    if (offene > 1) {
      _fehler = 'Nur ein Block darf offen (ohne Ende) sein.';
      return null;
    }
    if (offene == 1 && gueltig.last.endeMin != null) {
      _fehler = 'Der offene Block muss der letzte des Tages sein.';
      return null;
    }
    if (gueltig.isEmpty) {
      return (beginnMin: null, endeMin: null, pauseMin: 0, bloecke: const []);
    }
    if (gueltig.length == 1) {
      return (
        beginnMin: gueltig[0].beginnMin,
        endeMin: gueltig[0].endeMin,
        pauseMin: gueltig[0].endeMin == null ? 0 : _pauseMin,
        bloecke: const [],
      );
    }
    final ersterBeginn = gueltig.first.beginnMin;
    if (gueltig.last.endeMin == null) {
      // Noch offen → ganzer Tag zählt 0 Ist, bis ausgestempelt wird.
      return (
        beginnMin: ersterBeginn,
        endeMin: null,
        pauseMin: 0,
        bloecke: gueltig,
      );
    }
    final letztesEnde = gueltig.last.endeMin!;
    var gearbeitet = 0;
    for (final b in gueltig) {
      gearbeitet += b.endeMin! - b.beginnMin;
    }
    final luecken = (letztesEnde - ersterBeginn) - gearbeitet;
    return (
      beginnMin: ersterBeginn,
      endeMin: letztesEnde,
      pauseMin: luecken < 0 ? 0 : luecken,
      bloecke: gueltig,
    );
  }

  /// Speichern mit Doppeltipp-Sperre. Bei Erfolg wird der Dialog geschlossen;
  /// bei einem Eingabefehler bleibt er offen und gibt die Knöpfe wieder frei.
  Future<void> _speichern() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _fehler = null;
    });
    final erfolg = await _speichernIntern();
    if (!erfolg && mounted) setState(() => _busy = false);
  }

  Future<bool> _speichernIntern() async {
    final db = ref.read(dbProvider);
    int? beginnMin, endeMin;
    var pauseMin = 0;
    int? ortId;
    var bloecke = const <({int beginnMin, int? endeMin})>[];

    final istUrlaubsart = urlaubsArten.contains(_tagesart);
    // Urlaubsanteil: null heißt „ganzer Tag". Nur beim Einzeltag
    // einstellbar, ein Bereichseintrag gilt immer voll.
    int? urlaubMinuten;
    if (istUrlaubsart && _bisDatum == null) {
      final wert = _urlaubStundenWert;
      if (wert == null || wert <= 0) {
        _fehler = 'Urlaubsstunden angeben (z.B. 6,25).';
        return false;
      }
      if (wert > _tagesSoll) {
        _fehler =
            'Mehr als das Tagessoll (${formatStunden(_tagesSoll)} h) geht nicht.';
        return false;
      }
      // Voller Tag bleibt bewusst null, damit er einer späteren
      // Soll-Änderung folgt.
      if (wert < _tagesSoll) urlaubMinuten = (wert * 60).round();
    }

    if (_tagesart == Tagesart.arbeit || (istUrlaubsart && _istTeilUrlaub)) {
      final z = _sammleZeiten();
      if (z == null) return false;
      beginnMin = z.beginnMin;
      endeMin = z.endeMin;
      pauseMin = z.pauseMin;
      bloecke = z.bloecke;
      if (_tagesart == Tagesart.arbeit && beginnMin == null) {
        _fehler = 'Bitte mindestens einen Beginn angeben.';
        return false;
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
    // Zeitblöcke des bearbeiteten Tages setzen (leer = zurück auf einen
    // Block; räumt auch alte Blöcke weg, wenn der Tag jetzt Urlaub o.Ä. ist).
    final tagOhneZeit =
        DateTime(widget.datum.year, widget.datum.month, widget.datum.day);
    final id = await db.eintragId(widget.user.id, tagOhneZeit);
    if (id != null) await db.setzeBloecke(id, bloecke);

    if (mounted) Navigator.pop(context);
    return true;
  }

  Future<void> _loeschen() async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref.read(dbProvider).deleteEntry(widget.user.id,
        DateTime(widget.datum.year, widget.datum.month, widget.datum.day));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _zeitWaehlen(_Block block, bool istBeginn) async {
    final aktuell = istBeginn ? block.beginn : block.ende;
    final neu = await showTimePicker(
      context: context,
      initialTime: aktuell ?? const TimeOfDay(hour: 7, minute: 0),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (neu != null) {
      setState(() => istBeginn ? block.beginn = neu : block.ende = neu);
    }
  }

  /// Übernimmt die aktuelle Geräte-Uhrzeit (minutengenau) als Beginn/Ende.
  void _jetzt(_Block block, bool istBeginn) {
    final jetzt = TimeOfDay.now();
    setState(() => istBeginn ? block.beginn = jetzt : block.ende = jetzt);
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

  /// Ein einzelner Block: Beginn/Ende + Jetzt-Knöpfe, bei mehreren Blöcken
  /// zusätzlich ein Entfernen-Knopf.
  Widget _blockFeld(int index) {
    String uhr(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final block = _bloecke[index];
    final mehrere = _bloecke.length > 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mehrere)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Block ${index + 1}',
                      style: Theme.of(context).textTheme.labelMedium),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Block entfernen',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _bloecke.removeAt(index)),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.login),
                  label: Text(block.beginn == null
                      ? 'Beginn'
                      : 'Beginn ${uhr(block.beginn!)}'),
                  onPressed: () => _zeitWaehlen(block, true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text(
                      block.ende == null ? 'Ende' : 'Ende ${uhr(block.ende!)}'),
                  onPressed: () => _zeitWaehlen(block, false),
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
                  onPressed: () => _jetzt(block, true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: const Text('Jetzt Ende'),
                  onPressed: () => _jetzt(block, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Beginn/Ende/Pause – bei Arbeit und beim Teil-Urlaub. Mehrere Blöcke
  /// bilden mehrmaliges An-/Abstempeln am selben Tag ab; die Pause ergibt
  /// sich dann aus den Lücken und das Pausenfeld entfällt.
  List<Widget> _zeitFelder() {
    final mehrere = _bloecke.length > 1;
    return [
      for (var i = 0; i < _bloecke.length; i++) _blockFeld(i),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Block hinzufügen'),
          onPressed: () => setState(() => _bloecke.add(_Block())),
        ),
      ),
      if (mehrere)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'Bei mehreren Blöcken zählen die Lücken automatisch als Pause.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        )
      else ...[
        const SizedBox(height: 4),
        OutlinedButton.icon(
          icon: const Icon(Icons.free_breakfast_outlined),
          label: Text('Pause ${formatPause(_pauseMin)}'),
          onPressed: () async {
            final neu = await zeigePauseUhr(context, initialMinuten: _pauseMin);
            if (neu != null) setState(() => _pauseMin = neu);
          },
        ),
      ],
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
            onPressed: _busy ? null : _loeschen,
            child: Text('Löschen',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        TextButton(
            onPressed: _busy ? null : () => Navigator.pop(context),
            child: const Text('Abbrechen')),
        FilledButton(
            onPressed: _busy ? null : _speichern,
            child: const Text('Speichern')),
      ],
    );
  }
}
