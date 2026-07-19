import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/database.dart';
import '../logic/berechnung.dart';

/// Verlustfreies Austauschformat: wird am Monatsende per Mail an den Chef
/// geschickt und von dessen App für die Auswertung importiert.
///
/// Version 2 ergänzt `urlaubMinuten` (Teil-Urlaub; löst zugleich das
/// Altformat `halberTag` auf, das bis dahin gar nicht übertragen wurde) und
/// `sonderurlaubGrund`. Dateien der Version 1 bleiben importierbar.
class ZeitexaJson {
  static const formatVersion = 2;

  static String export({
    required User user,
    required SollRegel regel,
    required String monat, // 'JJJJ-MM'
    required List<TimeEntry> eintraege,
    required Map<int, String> ortNamen,
  }) {
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'Zeitexa',
      'version': formatVersion,
      'benutzer': {
        'username': user.username,
        'anzeigename': user.displayName,
      },
      'monat': monat,
      'eintraege': [
        for (final e in eintraege)
          {
            'datum':
                '${e.datum.year.toString().padLeft(4, '0')}-${e.datum.month.toString().padLeft(2, '0')}-${e.datum.day.toString().padLeft(2, '0')}',
            'tagesart': e.tagesart.name,
            'ort': e.ortId == null ? '' : (ortNamen[e.ortId] ?? ''),
            'beginn': e.beginnMin,
            'pause': e.pauseMin,
            'ende': e.endeMin,
            'notiz': e.notiz,
            'soll': regel.sollFuer(e.datum),
            // Bereits aufgelöst: das Altformat halberTag wandert nicht mit
            // ins Austauschformat, der Chef bekommt den fertigen Wert.
            'urlaubMinuten': _urlaubMinuten(e, regel),
            'sonderurlaubGrund': e.sonderurlaubGrund?.name,
          },
      ],
    });
  }

  /// Urlaubsanteil in Minuten für den Export; null = ganzer Tag. Nur bei den
  /// Urlaubsarten relevant. Ein alter `halberTag`-Eintrag wird hier in den
  /// halben Tagessollwert übersetzt.
  static int? _urlaubMinuten(TimeEntry e, SollRegel regel) {
    if (!urlaubsArten.contains(e.tagesart)) return null;
    if (e.urlaubMinuten != null) return e.urlaubMinuten;
    if (!e.halberTag) return null;
    return (regel.sollFuer(e.datum) * 30).round();
  }

  /// Liest eine Exportdatei und liefert Benutzer, Monat und Zeilen für den
  /// Import in die Auswertung. Wirft [FormatException] bei fremden Dateien.
  static ({
    String username,
    String anzeigename,
    String monat,
    List<ImportedEntriesCompanion> zeilen,
  }) parse(String jsonText) {
    final Object? raw = json.decode(jsonText);
    if (raw is! Map<String, dynamic> || raw['app'] != 'Zeitexa') {
      throw const FormatException('Das ist keine Zeitexa-Exportdatei.');
    }
    final benutzer = raw['benutzer'] as Map<String, dynamic>;
    final username = benutzer['username'] as String;
    final anzeigename = benutzer['anzeigename'] as String? ?? username;
    final monat = raw['monat'] as String;
    final zeilen = <ImportedEntriesCompanion>[];
    for (final e in (raw['eintraege'] as List).cast<Map<String, dynamic>>()) {
      zeilen.add(ImportedEntriesCompanion.insert(
        quellUsername: username,
        quellDisplayName: anzeigename,
        monat: monat,
        datum: DateTime.parse(e['datum'] as String),
        tagesart: _tagesart(e['tagesart']),
        ort: Value(e['ort'] as String? ?? ''),
        beginnMin: Value(e['beginn'] as int?),
        pauseMin: Value(e['pause'] as int? ?? 0),
        endeMin: Value(e['ende'] as int?),
        notiz: Value(e['notiz'] as String? ?? ''),
        sollStunden: (e['soll'] as num).toDouble(),
        // Fehlt in Dateien der Version 1 → ganzer Tag bzw. kein Grund.
        urlaubMinuten: Value(e['urlaubMinuten'] as int?),
        sonderurlaubGrund: Value(_grund(e['sonderurlaubGrund'])),
      ));
    }
    return (
      username: username,
      anzeigename: anzeigename,
      monat: monat,
      zeilen: zeilen,
    );
  }

  /// Tagesart aus dem Dateinamen. Schickt ein Mitarbeiter eine Datei aus
  /// einer neueren App-Version mit einer noch unbekannten Art, soll der
  /// Import nicht abbrechen – der Tag zählt dann als „frei".
  static Tagesart _tagesart(Object? name) {
    for (final art in Tagesart.values) {
      if (art.name == name) return art;
    }
    return Tagesart.frei;
  }

  static SonderurlaubGrund? _grund(Object? name) {
    for (final g in SonderurlaubGrund.values) {
      if (g.name == name) return g;
    }
    return null;
  }
}
