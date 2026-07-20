import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/database.dart';

/// Plattformunabhängige Vollsicherung: alle Tabellen der Datenbank als eine
/// JSON-Datei. Anders als das alte SQLite-Format (Kopie der Datenbankdatei,
/// braucht Dateizugriff) laufen Lesen und Schreiben hier über normale
/// SQL-Abfragen – das funktioniert auch in der Web-App, wo die Datenbank
/// hinter dem Drift-Worker im Browser-Speicher liegt. Eine so erstellte
/// Sicherung lässt sich deshalb auf JEDEM Gerät erstellen und einspielen
/// (Windows, Android, iPhone/Web), egal wo sie herkommt.

/// Versionszähler des Dateiformats selbst (unabhängig vom Datenbankschema).
const int kJsonSicherungFormatVersion = 1;

/// Markierung für Binärwerte (Blobs) im JSON: `{"$blob": "<Base64>"}`.
const String _blobMarker = r'$blob';

/// Einspiel-Reihenfolge: referenzierte Tabellen (users, places) zuerst,
/// damit die Fremdschlüssel auch dann stimmen würden, wenn ihre Prüfung
/// einmal eingeschaltet wird. Unbekannte Tabellen kommen ans Ende.
const List<String> _einspielReihenfolge = [
  'users',
  'places',
  'user_settings',
  'time_entries',
  'app_settings',
  'brandings',
  'imported_entries',
];

List<TableInfo> _tabellenSortiert(ZeitexaDb db) {
  int rang(TableInfo t) {
    final i = _einspielReihenfolge.indexOf(t.actualTableName);
    return i < 0 ? _einspielReihenfolge.length : i;
  }

  return db.allTables.toList()..sort((a, b) => rang(a).compareTo(rang(b)));
}

Object? _nachJson(Object? wert) =>
    wert is Uint8List ? {_blobMarker: base64Encode(wert)} : wert;

Object? _ausJson(Object? wert) {
  if (wert is Map && wert.containsKey(_blobMarker)) {
    return base64Decode(wert[_blobMarker] as String);
  }
  return wert;
}

/// Liest alle Tabellen und liefert die fertige Sicherungsdatei als Bytes.
Future<Uint8List> erzeugeJsonSicherung(ZeitexaDb db) async {
  final tabellen = <String, List<Map<String, Object?>>>{};
  for (final tabelle in db.allTables) {
    final zeilen = await db
        .customSelect('SELECT * FROM "${tabelle.actualTableName}"')
        .get();
    tabellen[tabelle.actualTableName] = [
      for (final zeile in zeilen)
        zeile.data.map((spalte, wert) => MapEntry(spalte, _nachJson(wert))),
    ];
  }
  final text = const JsonEncoder.withIndent(' ').convert({
    'app': 'Zeitexa',
    'inhalt': 'vollsicherung',
    'formatVersion': kJsonSicherungFormatVersion,
    'schemaVersion': db.schemaVersion,
    'produktKennung': kProduktKennung,
    'erstellt': DateTime.now().toIso8601String(),
    'tabellen': tabellen,
  });
  return Uint8List.fromList(utf8.encode(text));
}

/// Ersetzt den kompletten Datenbestand durch den Inhalt der Sicherung
/// (in einer Transaktion – schlägt etwas fehl, bleibt alles beim Alten).
/// Wirft [FormatException] bei fremden, kaputten oder zu neuen Dateien.
///
/// Sicherungen ÄLTERER App-Versionen sind einspielbar: Spalten, die es
/// damals noch nicht gab, bekommen ihre Standardwerte (wie bei einer
/// Schema-Migration). Sicherungen NEUERER Versionen werden abgelehnt,
/// weil dabei Daten verloren gingen.
Future<void> spieleJsonSicherungEin(ZeitexaDb db, Uint8List bytes) async {
  const kaputt =
      FormatException('Das ist keine gültige Zeitexa-Sicherungsdatei.');
  final Object? wurzel;
  try {
    wurzel = json.decode(utf8.decode(bytes));
  } on FormatException {
    throw kaputt;
  }
  if (wurzel is! Map<String, dynamic> ||
      wurzel['app'] != 'Zeitexa' ||
      wurzel['inhalt'] != 'vollsicherung' ||
      wurzel['tabellen'] is! Map) {
    throw kaputt;
  }
  if (wurzel['produktKennung'] != kProduktKennung) {
    throw const FormatException(
        'Diese Datei stammt nicht aus Zeitexa (z.B. aus der '
        'Firmenversion Zeitrax) und kann hier nicht eingespielt werden.');
  }
  final schemaVersion = wurzel['schemaVersion'];
  if (schemaVersion is! int) throw kaputt;
  if (schemaVersion > db.schemaVersion) {
    throw const FormatException(
        'Die Sicherung stammt aus einer neueren Zeitexa-Version. '
        'Bitte zuerst die App aktualisieren, dann klappt das Einspielen.');
  }
  final tabellen = (wurzel['tabellen'] as Map).cast<String, Object?>();

  await db.transaction(() async {
    final sortiert = _tabellenSortiert(db);
    // Erst alles leeren (abhängige Tabellen zuerst), dann einspielen.
    for (final tabelle in sortiert.reversed) {
      await db.customStatement('DELETE FROM "${tabelle.actualTableName}"');
    }
    for (final tabelle in sortiert) {
      final name = tabelle.actualTableName;
      final zeilen = tabellen[name];
      if (zeilen is! List) continue; // Tabelle gab es damals noch nicht
      final bekannteSpalten = tabelle.columnsByName.keys.toSet();
      for (final zeile in zeilen) {
        if (zeile is! Map) throw kaputt;
        final spalten = <String>[];
        final werte = <Object?>[];
        zeile.forEach((spalte, wert) {
          if (bekannteSpalten.contains(spalte)) {
            spalten.add('"$spalte"');
            werte.add(_ausJson(wert));
          }
        });
        if (spalten.isEmpty) continue;
        final platzhalter = List.filled(spalten.length, '?').join(', ');
        await db.customStatement(
            'INSERT INTO "$name" (${spalten.join(', ')}) '
            'VALUES ($platzhalter)',
            werte);
      }
    }
  });
}
