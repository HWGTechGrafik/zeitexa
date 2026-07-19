import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeitexa/data/database.dart';
import 'package:zeitexa/export/json_export.dart';
import 'package:zeitexa/logic/berechnung.dart';

void main() {
  test('Export → Parse Roundtrip bleibt verlustfrei', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final userId = await db.into(db.users).insert(UsersCompanion.insert(
        username: 'max', passwordHash: 'x', displayName: 'Max Mustermann'));
    final user =
        await (db.select(db.users)..where((t) => t.id.equals(userId))).getSingle();
    final ortId = await db.touchPlace('Baustelle Nord');

    await db.upsertEntry(TimeEntriesCompanion.insert(
      userId: userId,
      datum: DateTime(2026, 7, 13),
      tagesart: Tagesart.arbeit,
      ortId: Value(ortId),
      beginnMin: const Value(420),
      pauseMin: const Value(30),
      endeMin: const Value(960),
      notiz: const Value('Fundament betoniert'),
    ));
    await db.upsertEntry(TimeEntriesCompanion.insert(
      userId: userId,
      datum: DateTime(2026, 7, 14),
      tagesart: Tagesart.urlaub,
    ));

    const regel = SollRegel(
        modus: SollModus.moDoFrGetrennt,
        stundenTag: 8,
        stundenMoDo: 8,
        stundenFr: 5);
    final eintraege = await db.entriesForMonth(userId, 2026, 7);
    final jsonText = ZeitexaJson.export(
      user: user,
      regel: regel,
      monat: '2026-07',
      eintraege: eintraege,
      ortNamen: {ortId: 'Baustelle Nord'},
    );

    final geparst = ZeitexaJson.parse(jsonText);
    expect(geparst.username, 'max');
    expect(geparst.anzeigename, 'Max Mustermann');
    expect(geparst.monat, '2026-07');
    expect(geparst.zeilen, hasLength(2));

    final arbeit = geparst.zeilen[0];
    expect(arbeit.datum.value, DateTime(2026, 7, 13));
    expect(arbeit.tagesart.value, Tagesart.arbeit);
    expect(arbeit.ort.value, 'Baustelle Nord');
    expect(arbeit.beginnMin.value, 420);
    expect(arbeit.pauseMin.value, 30);
    expect(arbeit.endeMin.value, 960);
    expect(arbeit.notiz.value, 'Fundament betoniert');
    expect(arbeit.sollStunden.value, 8);

    final urlaub = geparst.zeilen[1];
    expect(urlaub.tagesart.value, Tagesart.urlaub);
    expect(urlaub.sollStunden.value, 8);

    // Import in die Auswertungstabelle funktioniert; ein erneuter Import
    // derselben Tage ersetzt sie (keine Duplikate).
    await db.mergeImport(geparst.username, geparst.monat, geparst.zeilen);
    await db.mergeImport(geparst.username, geparst.monat, geparst.zeilen);
    expect(await db.allImported(), hasLength(2));
  });

  test('Teil-Urlaub, Sonderurlaub-Grund und Altformat überstehen den Export',
      () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final userId = await db.into(db.users).insert(UsersCompanion.insert(
        username: 'max', passwordHash: 'x', displayName: 'Max'));
    final user = await (db.select(db.users)..where((t) => t.id.equals(userId)))
        .getSingle();

    // 6,25 h Urlaub, Rest gearbeitet.
    await db.upsertEntry(TimeEntriesCompanion.insert(
      userId: userId,
      datum: DateTime(2026, 7, 13),
      tagesart: Tagesart.urlaub,
      urlaubMinuten: const Value(375),
      beginnMin: const Value(480),
      endeMin: const Value(585),
    ));
    // Sonderurlaub mit Grund.
    await db.upsertEntry(TimeEntriesCompanion.insert(
      userId: userId,
      datum: DateTime(2026, 7, 14),
      tagesart: Tagesart.sonderurlaub,
      sonderurlaubGrund: const Value(SonderurlaubGrund.pflegefreistellung),
    ));
    // Altformat: halber Tag ohne urlaubMinuten – muss beim Export in
    // Minuten aufgelöst werden, sonst käme er beim Chef als ganzer Tag an.
    await db.into(db.timeEntries).insert(TimeEntriesCompanion.insert(
          userId: userId,
          datum: DateTime(2026, 7, 15),
          tagesart: Tagesart.urlaub,
          halberTag: const Value(true),
        ));

    const regel = SollRegel(
        modus: SollModus.moDoFrGetrennt,
        stundenTag: 8,
        stundenMoDo: 8,
        stundenFr: 5);
    final geparst = ZeitexaJson.parse(ZeitexaJson.export(
      user: user,
      regel: regel,
      monat: '2026-07',
      eintraege: await db.entriesForMonth(userId, 2026, 7),
      ortNamen: const {},
    ));

    expect(geparst.zeilen[0].urlaubMinuten.value, 375);
    expect(geparst.zeilen[0].beginnMin.value, 480);
    expect(geparst.zeilen[1].tagesart.value, Tagesart.sonderurlaub);
    expect(geparst.zeilen[1].sonderurlaubGrund.value,
        SonderurlaubGrund.pflegefreistellung);
    expect(geparst.zeilen[2].urlaubMinuten.value, 240); // halbes 8-h-Soll
  });

  test('Exportdatei der Version 1 bleibt lesbar', () {
    // Ohne urlaubMinuten/sonderurlaubGrund – so sahen die Dateien bis
    // v1.2.5 aus.
    const alt = '''
{
  "app": "Zeitexa",
  "version": 1,
  "benutzer": {"username": "max", "anzeigename": "Max"},
  "monat": "2026-07",
  "eintraege": [
    {"datum": "2026-07-13", "tagesart": "urlaub", "ort": "", "beginn": null,
     "pause": 0, "ende": null, "notiz": "", "soll": 8.0}
  ]
}
''';
    final geparst = ZeitexaJson.parse(alt);
    expect(geparst.zeilen, hasLength(1));
    expect(geparst.zeilen[0].tagesart.value, Tagesart.urlaub);
    expect(geparst.zeilen[0].urlaubMinuten.value, isNull);
    expect(geparst.zeilen[0].sonderurlaubGrund.value, isNull);
  });

  test('unbekannte Tagesart aus einer neueren Version bricht nicht ab', () {
    const zukunft = '''
{
  "app": "Zeitexa",
  "version": 9,
  "benutzer": {"username": "max", "anzeigename": "Max"},
  "monat": "2026-07",
  "eintraege": [
    {"datum": "2026-07-13", "tagesart": "bildungskarenz", "ort": "",
     "beginn": null, "pause": 0, "ende": null, "notiz": "", "soll": 8.0}
  ]
}
''';
    final geparst = ZeitexaJson.parse(zukunft);
    expect(geparst.zeilen[0].tagesart.value, Tagesart.frei);
  });

  test('mergeImport fasst zwei Geräte taggenau zusammen', () async {
    final db = ZeitexaDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    ImportedEntriesCompanion zeile(DateTime tag) =>
        ImportedEntriesCompanion.insert(
          quellUsername: 'max',
          quellDisplayName: 'Max',
          monat: '2026-07',
          datum: tag,
          tagesart: Tagesart.arbeit,
          sollStunden: 8,
        );

    // Handy A: Tage 1 und 2. Handy B: Tage 3 und 4 (gleicher Benutzer/Monat).
    await db.mergeImport('max', '2026-07',
        [zeile(DateTime(2026, 7, 1)), zeile(DateTime(2026, 7, 2))]);
    await db.mergeImport('max', '2026-07',
        [zeile(DateTime(2026, 7, 3)), zeile(DateTime(2026, 7, 4))]);
    expect(await db.allImported(), hasLength(4));

    // Korrigierter Tag 3 wird erneut geschickt: überschreibt nur Tag 3,
    // die anderen Tage bleiben unberührt (weiterhin genau 4 Tage).
    await db.mergeImport('max', '2026-07', [zeile(DateTime(2026, 7, 3))]);
    expect(await db.allImported(), hasLength(4));
  });

  test('fremde Dateien werden abgelehnt', () {
    expect(() => ZeitexaJson.parse('{"app":"anders"}'),
        throwsA(isA<FormatException>()));
    expect(() => ZeitexaJson.parse('kein json'),
        throwsA(isA<FormatException>()));
  });
}
