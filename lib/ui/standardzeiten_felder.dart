import 'package:flutter/material.dart';

import '../data/database.dart';

/// Die für [datum] geltenden Standardzeiten eines Profils.
///
/// Bei getrenntem Freitags-Soll gelten am Freitag die abweichenden
/// Freitagswerte – sofern hinterlegt. Ist dort nichts gesetzt (`null`),
/// bleibt es bei den Mo–Do-Werten, damit sich für Bestandsbenutzer nichts
/// ändert.
({int beginnMin, int endeMin, int pauseMin}) standardzeitenFuer(
    UserSetting s, DateTime datum) {
  final freitag = s.sollModus == SollModus.moDoFrGetrennt &&
      datum.weekday == DateTime.friday;
  if (!freitag) {
    return (
      beginnMin: s.standardBeginnMin,
      endeMin: s.standardEndeMin,
      pauseMin: s.standardPauseMin,
    );
  }
  return (
    beginnMin: s.standardBeginnFrMin ?? s.standardBeginnMin,
    endeMin: s.standardEndeFrMin ?? s.standardEndeMin,
    pauseMin: s.standardPauseFrMin ?? s.standardPauseMin,
  );
}

/// Eingabefelder für die Standard-Beginn/-Ende/-Pausenzeit eines Profils –
/// dient als Vorbelegung neuer Arbeits-Einträge. Wird sowohl bei der
/// Profilanlage im Chef-Bereich als auch in den persönlichen Einstellungen
/// des Mitarbeiters verwendet.
///
/// Bei getrenntem Freitags-Soll ([zeigeFreitag]) lässt sich zusätzlich ein
/// abweichender Freitag hinterlegen; [beginnFr] & Co. sind dann `null`,
/// solange „wie Mo–Do" gilt.
class StandardzeitenFelder extends StatelessWidget {
  final TimeOfDay beginn;
  final TimeOfDay ende;
  final int pauseMin;
  final ValueChanged<TimeOfDay> onBeginn;
  final ValueChanged<TimeOfDay> onEnde;
  final ValueChanged<int> onPause;

  /// Freitags-Block anzeigen (nur sinnvoll bei SollModus.moDoFrGetrennt).
  final bool zeigeFreitag;

  /// Abweichende Freitagszeiten; null = wie Mo–Do.
  final TimeOfDay? beginnFr;
  final TimeOfDay? endeFr;
  final int? pauseFrMin;

  /// Schalter „Freitag abweichend": Der Aufrufer setzt bei `true` alle drei
  /// Freitagswerte auf die Mo–Do-Werte, bei `false` zurück auf null.
  final ValueChanged<bool>? onFreitagAbweichend;
  final ValueChanged<TimeOfDay>? onBeginnFr;
  final ValueChanged<TimeOfDay>? onEndeFr;
  final ValueChanged<int>? onPauseFr;

  const StandardzeitenFelder({
    super.key,
    required this.beginn,
    required this.ende,
    required this.pauseMin,
    required this.onBeginn,
    required this.onEnde,
    required this.onPause,
    this.zeigeFreitag = false,
    this.beginnFr,
    this.endeFr,
    this.pauseFrMin,
    this.onFreitagAbweichend,
    this.onBeginnFr,
    this.onEndeFr,
    this.onPauseFr,
  });

  Future<void> _zeitWaehlen(
      BuildContext context, TimeOfDay aktuell, ValueChanged<TimeOfDay> onNeu) async {
    final neu = await showTimePicker(
      context: context,
      initialTime: aktuell,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (neu != null) onNeu(neu);
  }

  /// Beginn-/Ende-Zeile plus Pausen-Knopf für einen Zeiten-Satz.
  Widget _zeitenBlock(
    BuildContext context, {
    required TimeOfDay beginn,
    required TimeOfDay ende,
    required int pauseMin,
    required ValueChanged<TimeOfDay> onBeginn,
    required ValueChanged<TimeOfDay> onEnde,
    required ValueChanged<int> onPause,
  }) {
    String uhr(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.login),
                label: Text('Beginn ${uhr(beginn)}'),
                onPressed: () => _zeitWaehlen(context, beginn, onBeginn),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: Text('Ende ${uhr(ende)}'),
                onPressed: () => _zeitWaehlen(context, ende, onEnde),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.free_breakfast_outlined),
          label: Text('Pause ${formatPause(pauseMin)}'),
          onPressed: () async {
            final neu = await zeigePauseUhr(context, initialMinuten: pauseMin);
            if (neu != null) onPause(neu);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final abweichend = beginnFr != null || endeFr != null || pauseFrMin != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            zeigeFreitag
                ? 'Standardzeiten für neue Einträge (Mo–Do)'
                : 'Standardzeiten für neue Einträge',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        _zeitenBlock(
          context,
          beginn: beginn,
          ende: ende,
          pauseMin: pauseMin,
          onBeginn: onBeginn,
          onEnde: onEnde,
          onPause: onPause,
        ),
        if (zeigeFreitag) ...[
          const SizedBox(height: 8),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('Freitag hat andere Zeiten'),
            subtitle: const Text(
                'Aus: der Freitag wird wie Mo–Do vorbelegt. Ein: eigene '
                'Beginn-/Ende-/Pausenzeit für den kürzeren Freitag.'),
            value: abweichend,
            onChanged: onFreitagAbweichend,
          ),
          if (abweichend)
            _zeitenBlock(
              context,
              beginn: beginnFr ?? beginn,
              ende: endeFr ?? ende,
              pauseMin: pauseFrMin ?? pauseMin,
              onBeginn: onBeginnFr ?? (_) {},
              onEnde: onEndeFr ?? (_) {},
              onPause: onPauseFr ?? (_) {},
            ),
        ],
      ],
    );
  }
}

/// Eingabe einer Pausendauer über die runde Uhr (wie bei Beginn/Ende):
/// Stundenzeiger = Stunden, Minutenzeiger = Minuten der Pause.
///
/// Gibt die Dauer in Minuten zurück, oder null bei Abbruch.
Future<int?> zeigePauseUhr(BuildContext context,
    {required int initialMinuten}) async {
  final neu = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
        hour: (initialMinuten ~/ 60).clamp(0, 23),
        minute: initialMinuten % 60),
    helpText: 'Pause (Std:Min)',
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  return neu == null ? null : neu.hour * 60 + neu.minute;
}

/// Formatiert Minuten als „HH:MM" (z.B. für Buttons, die die Uhr öffnen).
String formatPause(int minuten) {
  final h = minuten ~/ 60, m = minuten % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}
