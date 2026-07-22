import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../export/auswertung_export.dart';
import '../export/monats_daten.dart' show tagBloeckeAus;
import '../logic/auswertung.dart';
import '../logic/backup_stub.dart'
    if (dart.library.io) '../logic/backup_io.dart' as plattform;
import '../logic/berechnung.dart';
import '../main.dart';

/// Auswertung des eigenen Profils: fasst alle erfassten Monate automatisch
/// zusammen (Diagramme + Tabelle) und hält sich über den Datenbank-Stream
/// von selbst aktuell. Kein Import nötig – anders als in der Firmenversion
/// liegen die Daten ja schon auf diesem Gerät.
class AuswertungView extends ConsumerStatefulWidget {
  const AuswertungView({super.key});

  @override
  ConsumerState<AuswertungView> createState() => _AuswertungViewState();
}

class _AuswertungViewState extends ConsumerState<AuswertungView> {
  User? _user;
  SollRegel? _regel;

  @override
  void initState() {
    super.initState();
    _lade();
  }

  Future<void> _lade() async {
    final user = await ref.read(authProvider).einzelUser();
    if (user == null) return;
    final regel = await ref.read(exportProvider).regelFuer(user.id);
    if (mounted) {
      setState(() {
        _user = user;
        _regel = regel;
      });
    }
  }

  Future<void> _exportieren(List<MonatsAuswertung> auswertungen) async {
    if (auswertungen.isEmpty) return;
    final branding = await ref.read(dbProvider).branding();
    final xlsx = auswertungExcel(branding, auswertungen);
    final pdf = await auswertungPdf(branding, auswertungen);
    // Auf dem Desktop gibt es keinen System-Teilen-Dialog für Dateien –
    // dort „Speichern unter" (Excel und PDF nacheinander), wie beim
    // Lizenz-/Benutzer-Export. Sonst der Teilen-Dialog.
    final desktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
    if (desktop) {
      final xlsxPfad = await plattform.speichereDatei(
          'Auswertung als Excel speichern', 'Zeitexa_Auswertung.xlsx',
          ['xlsx'], xlsx);
      final pdfPfad = await plattform.speichereDatei(
          'Auswertung als PDF speichern', 'Zeitexa_Auswertung.pdf',
          ['pdf'], pdf);
      if (mounted && (xlsxPfad != null || pdfPfad != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Auswertung gespeichert.')));
      }
      return;
    }
    await SharePlus.instance.share(ShareParams(
      files: [
        XFile.fromData(xlsx,
            name: 'Zeitexa_Auswertung.xlsx',
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        XFile.fromData(pdf,
            name: 'Zeitexa_Auswertung.pdf', mimeType: 'application/pdf'),
      ],
      subject: 'Zeitexa Gesamtauswertung',
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Nach „Speichern" im Profil (neue Sollstunden) frisch nachladen.
    ref.listen(einzelUserProvider, (_, _) => _lade());
    final user = _user;
    final regel = _regel;
    if (user == null || regel == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<List<TimeEntry>>(
      stream: ref.read(dbProvider).watchAllEntries(user.id),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final eintraege = snap.data!;
        return FutureBuilder<Map<int, List<Zeitblock>>>(
          future: ref.read(dbProvider).alleBloeckeMap(user.id),
          builder: (context, blkSnap) {
            final bloecke =
                tagBloeckeAus(blkSnap.data ?? const <int, List<Zeitblock>>{});
            final auswertungen = monatsAuswertungenAusEintraegen(
              username: user.username,
              anzeigename: user.displayName,
              eintraege: eintraege,
              regel: regel,
              bloecke: bloecke,
            );
            return Scaffold(
          floatingActionButton: auswertungen.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _exportieren(auswertungen),
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Auswertung exportieren'),
                ),
          body: auswertungen.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Noch keine Einträge vorhanden.\n\nSobald du Zeiten '
                      'erfasst, erscheint hier automatisch die Auswertung '
                      'aller Monate – ganz ohne Import.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
                  children: [
                    Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            title: Text(user.displayName),
                            subtitle: Text(
                                'Überstunden gesamt: ${formatStunden(auswertungen.fold(0.0, (s, a) => s + a.ueberstunden), vorzeichen: true)} h · '
                                'Urlaub: ${formatStunden(auswertungen.fold(0.0, (s, a) => s + a.urlaub))} Tage\n'
                                'Wird automatisch aus deinen Einträgen berechnet.'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: _UeberstundenDiagramm(monate: auswertungen),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: _IstSollDiagramm(monate: auswertungen),
                          ),
                          _MonatsTabelle(monate: auswertungen),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
            );
          },
        );
      },
    );
  }
}

/// Einfaches Balkendiagramm der Überstunden je Monat (ohne Fremd-Bibliothek):
/// grüner Balken über der Nulllinie = Plus, roter darunter = Minus.
class _UeberstundenDiagramm extends StatelessWidget {
  final List<MonatsAuswertung> monate;
  const _UeberstundenDiagramm({required this.monate});

  @override
  Widget build(BuildContext context) {
    const halbe = 46.0; // Höhe je Richtung (Plus oben, Minus unten)
    final maxAbs = monate
        .map((m) => m.ueberstunden.abs())
        .fold(0.0, (a, b) => a > b ? a : b);
    final nenner = maxAbs < 0.5 ? 0.5 : maxAbs;
    final gruen = Colors.green.shade600;
    final rot = Theme.of(context).colorScheme.error;
    final linie = Theme.of(context).dividerColor;
    final labelStil = Theme.of(context).textTheme.labelSmall;

    String kurz(String monat) {
      final t = monat.split('-');
      return t.length == 2 ? '${t[1]}/${t[0].substring(2)}' : monat;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Überstunden je Monat',
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final m in monate)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 14,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            formatStunden(m.ueberstunden, vorzeichen: true),
                            style: labelStil?.copyWith(
                                color: m.ueberstunden < 0 ? rot : gruen),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: halbe,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 16,
                            height: m.ueberstunden > 0
                                ? (m.ueberstunden / nenner) * halbe
                                : 0,
                            decoration: BoxDecoration(
                              color: gruen,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3)),
                            ),
                          ),
                        ),
                      ),
                      Container(height: 1, color: linie),
                      SizedBox(
                        height: halbe,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 16,
                            height: m.ueberstunden < 0
                                ? (m.ueberstunden.abs() / nenner) * halbe
                                : 0,
                            decoration: BoxDecoration(
                              color: rot,
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(3)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(kurz(m.monat), style: labelStil),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Kompakte Monatsübersicht: genau EINE Zeile je Monat.
///
/// Die Monatsspalte steht fest links, der Rest scrollt auf schmalen Geräten
/// seitlich weg – so bleibt immer erkennbar, zu welchem Monat eine Zahl
/// gehört. Nullwerte werden als „–" gezeigt, damit die Tabelle ruhig bleibt.
class _MonatsTabelle extends StatelessWidget {
  final List<MonatsAuswertung> monate;
  const _MonatsTabelle({required this.monate});

  static const _zeilenHoehe = 34.0;
  static const _kopfHoehe = 28.0;

  String _tage(double wert) => wert == 0 ? '–' : formatStunden(wert);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kopfStil = theme.textTheme.labelSmall
        ?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor);
    final zellStil = theme.textTheme.bodySmall;

    Widget zelle(String text, {TextStyle? stil, double breite = 56}) =>
        SizedBox(
          width: breite,
          height: _zeilenHoehe,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: stil ?? zellStil),
            ),
          ),
        );

    Widget kopf(String text, {double breite = 56}) => SizedBox(
          width: breite,
          height: _kopfHoehe,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(text, style: kopfStil),
            ),
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Feste Monatsspalte.
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: _kopfHoehe,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Monat', style: kopfStil))),
              for (final a in monate)
                SizedBox(
                  height: _zeilenHoehe,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(a.monat, style: zellStil)),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  kopf('Ist'),
                  kopf('Soll'),
                  kopf('+/−', breite: 62),
                  kopf('Url', breite: 44),
                  kopf('Sond', breite: 48),
                  kopf('Firma', breite: 52),
                  kopf('Krank', breite: 48),
                  kopf('ZA', breite: 40),
                  kopf('Feiert', breite: 48),
                ]),
                for (final a in monate)
                  Row(children: [
                    zelle(formatStunden(a.ist)),
                    zelle(formatStunden(a.soll)),
                    zelle(formatStunden(a.ueberstunden, vorzeichen: true),
                        breite: 62,
                        stil: zellStil?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: a.ueberstunden < 0
                              ? theme.colorScheme.error
                              : Colors.green.shade700,
                        )),
                    zelle(_tage(a.urlaub), breite: 44),
                    zelle(_tage(a.sonderurlaub), breite: 48),
                    zelle(_tage(a.firmenurlaub), breite: 52),
                    zelle(_tage(a.krank.toDouble()), breite: 48),
                    zelle(_tage(a.zeitausgleich.toDouble()), breite: 40),
                    zelle(_tage(a.feiertage.toDouble()), breite: 48),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Ist-Stunden je Monat als Balken, dazu eine waagrechte Soll-Marke.
///
/// Der Balkenteil bis zum Soll bleibt neutral, der Überstand darüber ist
/// grün; bleibt der Balken unter der Marke, wird die Lücke rot angedeutet.
/// Wie [_UeberstundenDiagramm] bewusst ohne Fremd-Bibliothek.
class _IstSollDiagramm extends StatelessWidget {
  final List<MonatsAuswertung> monate;
  const _IstSollDiagramm({required this.monate});

  @override
  Widget build(BuildContext context) {
    const hoehe = 80.0;
    final maxWert = monate
        .map((m) => m.ist > m.soll ? m.ist : m.soll)
        .fold(0.0, (a, b) => a > b ? a : b);
    final nenner = maxWert < 1 ? 1.0 : maxWert;
    final theme = Theme.of(context);
    final gruen = Colors.green.shade600;
    final rot = theme.colorScheme.error;
    final neutral = theme.colorScheme.primary.withValues(alpha: 0.55);
    final labelStil = theme.textTheme.labelSmall;

    String kurz(String monat) {
      final t = monat.split('-');
      return t.length == 2 ? '${t[1]}/${t[0].substring(2)}' : monat;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Ist gegen Soll je Monat',
                style: theme.textTheme.labelMedium),
            const SizedBox(width: 8),
            Container(width: 14, height: 2, color: theme.colorScheme.onSurface),
            const SizedBox(width: 4),
            Text('= Soll', style: labelStil),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final m in monate)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 14,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(formatStunden(m.ist),
                              style: labelStil?.copyWith(
                                  color: m.ist < m.soll ? rot : gruen)),
                        ),
                      ),
                      SizedBox(
                        height: hoehe,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Ist-Balken: bis zum Soll neutral, darüber grün.
                            Container(
                              width: 18,
                              height: (m.ist / nenner) * hoehe,
                              decoration: BoxDecoration(
                                color: m.ist > m.soll ? gruen : neutral,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(3)),
                              ),
                            ),
                            if (m.ist > m.soll)
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: 18,
                                  height: (m.soll / nenner) * hoehe,
                                  color: neutral,
                                ),
                              ),
                            // Fehlbetrag zwischen Balkenende und Soll-Marke.
                            if (m.ist < m.soll)
                              Positioned(
                                bottom: (m.ist / nenner) * hoehe,
                                child: Container(
                                  width: 18,
                                  height:
                                      ((m.soll - m.ist) / nenner) * hoehe,
                                  color: rot.withValues(alpha: 0.25),
                                ),
                              ),
                            // Soll-Marke.
                            Positioned(
                              bottom: (m.soll / nenner) * hoehe,
                              child: Container(
                                  width: 24,
                                  height: 2,
                                  color: theme.colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(kurz(m.monat), style: labelStil),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
