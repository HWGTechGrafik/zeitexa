import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Tagesart eines Eintrags.
///
/// ACHTUNG: Der Wert wird als INDEX gespeichert (`intEnum`). Neue Arten
/// dürfen nur HINTEN angehängt werden – ein Einfügen in der Mitte würde
/// alle Bestandsdaten verschieben.
enum Tagesart {
  arbeit,
  urlaub,
  krank,
  feiertag,
  zeitausgleich,
  frei,
  sonderurlaub,
  firmenurlaub,
}

/// Anlass eines Sonderurlaubs ([Tagesart.sonderurlaub]). Bei [sonstiges]
/// steht der Klartext in `TimeEntries.notiz`.
///
/// Wie [Tagesart] als Index gespeichert – nur hinten anhängen.
enum SonderurlaubGrund {
  pflegefreistellung,
  umzug,
  hochzeit,
  geburt,
  todesfall,
  sonstiges,
}

/// Modus für die Sollstunden eines Mitarbeiters.
enum SollModus {
  /// Ein genereller Stundensatz für Mo–Fr.
  gleich,

  /// Mo–Do und Freitag getrennt (z.B. Fr nur halber Tag).
  moDoFrGetrennt,
}

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get displayName => text()();
  BoolColumn get isAdmin => boolean().withDefault(const Constant(false))();
  BoolColumn get mustChangePassword =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// E-Mail-Adresse des Mitarbeiters selbst (für die Excel-Kopie beim
  /// Mail-Export, siehe lib/export/export_service.dart).
  TextColumn get mitarbeiterEmail => text().withDefault(const Constant(''))();
}

class UserSettings extends Table {
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get sollModus => intEnum<SollModus>()();
  RealColumn get sollStundenTag => real().withDefault(const Constant(8.0))();
  RealColumn get sollStundenMoDo => real().withDefault(const Constant(8.0))();
  RealColumn get sollStundenFr => real().withDefault(const Constant(5.0))();

  /// Vorbelegung für neue Arbeits-Einträge (Minuten seit Mitternacht bzw.
  /// Pausendauer in Minuten). Vom Chef bei der Anlage gesetzt, danach vom
  /// Mitarbeiter selbst in seinen Einstellungen änderbar.
  IntColumn get standardBeginnMin =>
      integer().withDefault(const Constant(7 * 60))();
  IntColumn get standardEndeMin =>
      integer().withDefault(const Constant(16 * 60))();
  IntColumn get standardPauseMin =>
      integer().withDefault(const Constant(30))();

  /// Abweichende Standardzeiten für den Freitag – nur relevant, wenn der
  /// Sollmodus [SollModus.moDoFrGetrennt] ist (der Freitag ist dort meist
  /// kürzer). `null` heißt „wie Mo–Do", damit sich für Bestandsbenutzer
  /// nichts ändert.
  IntColumn get standardBeginnFrMin => integer().nullable()();
  IntColumn get standardEndeFrMin => integer().nullable()();
  IntColumn get standardPauseFrMin => integer().nullable()();

  /// Anfangsstand (vom Chef bei der Profilanlage gesetzt, später
  /// korrigierbar) zu einem Stichtag; die App schreibt die Stände danach
  /// automatisch fort, siehe lib/logic/konten.dart.
  DateTimeColumn get anfangsstandStichtag => dateTime().nullable()();
  RealColumn get anfangsstandUrlaubTage =>
      real().withDefault(const Constant(0))();
  IntColumn get anfangsstandZeitausgleichMin =>
      integer().withDefault(const Constant(0))();

  /// Freitags-Urlaub als eigenes Konto führen (manche Firmen vergeben
  /// Mo–Do- und Fr-Urlaub getrennt). Wenn aktiv, bucht Urlaub am Freitag
  /// vom Fr-Konto ab und [anfangsstandUrlaubTage] gilt nur für Mo–Do.
  BoolColumn get urlaubFrGetrennt =>
      boolean().withDefault(const Constant(false))();
  RealColumn get anfangsstandUrlaubFrTage =>
      real().withDefault(const Constant(0))();

  /// Interner Firmenurlaub als eigenes Konto führen: ein von der Firma
  /// bereitgestelltes Zusatz-Kontingent (z.B. eine Extra-Woche), das pro
  /// Mitarbeiter unterschiedlich hoch sein kann und nicht verfällt.
  /// Verbraucht wird es über [Tagesart.firmenurlaub]; den Anfangsstand
  /// erhöht der Chef jährlich selbst.
  BoolColumn get firmenurlaubAktiv =>
      boolean().withDefault(const Constant(false))();
  RealColumn get anfangsstandFirmenurlaubTage =>
      real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {userId};
}

class TimeEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();

  /// Nur das Datum (Zeitanteil 00:00).
  DateTimeColumn get datum => dateTime()();
  IntColumn get tagesart => intEnum<Tagesart>()();
  IntColumn get ortId => integer().nullable().references(Places, #id)();

  /// Minuten seit Mitternacht, null wenn nicht erfasst.
  IntColumn get beginnMin => integer().nullable()();
  IntColumn get pauseMin => integer().withDefault(const Constant(0))();
  IntColumn get endeMin => integer().nullable()();
  TextColumn get notiz => text().withDefault(const Constant(''))();

  /// Anlass bei [Tagesart.sonderurlaub], sonst null.
  IntColumn get sonderurlaubGrund =>
      intEnum<SonderurlaubGrund>().nullable()();

  /// Urlaubsanteil des Tages in Minuten – gilt für Urlaub, Sonderurlaub und
  /// Firmenurlaub. `null` bedeutet „ganzer Tag". Ist der Anteil kleiner als
  /// das Tagessoll, darf am selben Tag zusätzlich gearbeitet werden.
  IntColumn get urlaubMinuten => integer().nullable()();

  /// ALTFORMAT (bis Schema 3): halber Urlaubstag als Ja/Nein. Wird nicht
  /// mehr geschrieben, aber weiterhin gelesen – aufgelöst ausschließlich in
  /// `urlaubAnteil()` in lib/logic/berechnung.dart. Nicht migrierbar, weil
  /// der zugehörige Sollwert vom Wochentag und den Benutzereinstellungen
  /// abhängt.
  BoolColumn get halberTag => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, datum},
      ];
}

class Places extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  DateTimeColumn get lastUsedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get useCount => integer().withDefault(const Constant(0))();
}

/// Gerätweite Einstellungen als Key-Value-Paare.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Branding (eine Zeile, id = 1), nur über den versteckten
/// Entwickler-Bereich änderbar.
class Brandings extends Table {
  IntColumn get id => integer()();
  TextColumn get firmenname => text().withDefault(const Constant('Zeitexa'))();
  TextColumn get adresse => text().withDefault(const Constant(''))();
  TextColumn get telefon => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  BlobColumn get logo => blob().nullable()();
  IntColumn get akzentFarbe =>
      integer().withDefault(const Constant(0xFF1565C0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Vom Chef importierte Monatsdaten der Mitarbeiter (aus den JSON-Dateien).
class ImportedEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get quellUsername => text()();
  TextColumn get quellDisplayName => text()();

  /// 'JJJJ-MM' des exportierten Monats.
  TextColumn get monat => text()();
  DateTimeColumn get datum => dateTime()();
  IntColumn get tagesart => intEnum<Tagesart>()();
  TextColumn get ort => text().withDefault(const Constant(''))();
  IntColumn get beginnMin => integer().nullable()();
  IntColumn get pauseMin => integer().withDefault(const Constant(0))();
  IntColumn get endeMin => integer().nullable()();
  TextColumn get notiz => text().withDefault(const Constant(''))();

  /// Anlass bei [Tagesart.sonderurlaub] laut Export, sonst null.
  IntColumn get sonderurlaubGrund =>
      intEnum<SonderurlaubGrund>().nullable()();

  /// Urlaubsanteil in Minuten laut Export; `null` = ganzer Tag. Das
  /// exportierende Gerät löst das Altformat `halberTag` bereits auf, hier
  /// steht also immer der fertige Minutenwert.
  IntColumn get urlaubMinuten => integer().nullable()();

  /// Sollstunden des Tages laut Export (damit die Auswertung nicht von
  /// lokalen Einstellungen abhängt).
  RealColumn get sollStunden => real()();
  DateTimeColumn get importZeit => dateTime().withDefault(currentDateAndTime)();
}

/// Schlüssel für AppSettings.
abstract class SettingsKeys {
  static const adminPasswordHash = 'adminPasswordHash';
  static const brandingPasswordHash = 'brandingPasswordHash';
  static const zielEmail = 'zielEmail';
  static const smtpHost = 'smtpHost';
  static const smtpPort = 'smtpPort';
  static const smtpUser = 'smtpUser';
  static const smtpPass = 'smtpPass';
  static const smtpSsl = 'smtpSsl';
  static const autoSendAktiv = 'autoSendAktiv';
  static const sendeSperreAktiv = 'sendeSperreAktiv';
  static const selbstRegistrierungErlaubt = 'selbstRegistrierungErlaubt';
  static const defaultSollModus = 'defaultSollModus';
  static const defaultSollTag = 'defaultSollTag';
  static const defaultSollMoDo = 'defaultSollMoDo';
  static const defaultSollFr = 'defaultSollFr';

  /// Vorlage für den Mail-Betreff beim Export, siehe
  /// lib/export/export_service.dart. Platzhalter: {Mitarbeiter} {Monat}
  /// {Jahr} {Firma} {Zeitraum}.
  static const betreffVorlage = 'betreffVorlage';

  /// Signierte Firmenlizenz (Base64), siehe lib/logic/lizenz_service.dart.
  static const lizenzPayload = 'lizenzPayloadB64';
  static const lizenzSignatur = 'lizenzSignaturB64';

  /// Biometrische Anmeldung: firmenweiter Admin-Schalter und
  /// Opt-in pro Benutzer, siehe lib/logic/biometrie_service.dart.
  static const biometrieErlaubt = 'biometrieErlaubt';
  static String biometrie(int userId) => 'biometrie.$userId';

  /// Heute-Knopf öffnet zusätzlich den Tageseintrag: firmenweite Vorgabe
  /// des Chefs plus persönliche Übersteuerung pro Benutzer, siehe
  /// [ZeitexaDb.heuteOeffnetEintragFuer] und lib/ui/monats_screen.dart.
  static const heuteOeffnetEintragStandard = 'heuteOeffnetEintragStandard';
  static String heuteOeffnetEintrag(int userId) =>
      'heuteOeffnetEintrag.$userId';

  /// Pro Benutzer und Monat: `versendet.<userId>.<JJJJ-MM>` = '1'
  static String versendet(int userId, String monat) =>
      'versendet.$userId.$monat';
}

@DriftDatabase(tables: [
  Users,
  UserSettings,
  TimeEntries,
  Places,
  AppSettings,
  Brandings,
  ImportedEntries,
])
class ZeitexaDb extends _$ZeitexaDb {
  ZeitexaDb()
      : super(driftDatabase(
          name: 'zeitexa',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ));

  ZeitexaDb.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(brandings).insert(
            BrandingsCompanion.insert(id: const Value(1)),
            mode: InsertMode.insertOrIgnore,
          );
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(users, users.mitarbeiterEmail);
            await m.addColumn(userSettings, userSettings.standardBeginnMin);
            await m.addColumn(userSettings, userSettings.standardEndeMin);
            await m.addColumn(userSettings, userSettings.standardPauseMin);
            await m.addColumn(
                userSettings, userSettings.anfangsstandStichtag);
            await m.addColumn(
                userSettings, userSettings.anfangsstandUrlaubTage);
            await m.addColumn(
                userSettings, userSettings.anfangsstandZeitausgleichMin);
            await m.addColumn(timeEntries, timeEntries.halberTag);
          }
          if (from < 3) {
            await m.addColumn(userSettings, userSettings.urlaubFrGetrennt);
            await m.addColumn(
                userSettings, userSettings.anfangsstandUrlaubFrTage);
          }
          if (from < 4) {
            await m.addColumn(userSettings, userSettings.firmenurlaubAktiv);
            await m.addColumn(
                userSettings, userSettings.anfangsstandFirmenurlaubTage);
            await m.addColumn(userSettings, userSettings.standardBeginnFrMin);
            await m.addColumn(userSettings, userSettings.standardEndeFrMin);
            await m.addColumn(userSettings, userSettings.standardPauseFrMin);
            await m.addColumn(timeEntries, timeEntries.sonderurlaubGrund);
            await m.addColumn(timeEntries, timeEntries.urlaubMinuten);
            await m.addColumn(
                importedEntries, importedEntries.sonderurlaubGrund);
            await m.addColumn(importedEntries, importedEntries.urlaubMinuten);
            // halberTag wird bewusst NICHT umgeschrieben: der zugehörige
            // Sollwert hängt vom Wochentag und den Benutzereinstellungen ab
            // und lässt sich in SQL nicht korrekt auflösen. Der Lesepfad
            // versteht beide Formate, siehe urlaubAnteil() in
            // lib/logic/berechnung.dart.
          }
        },
      );

  // ---------- AppSettings ----------

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value));

  Future<bool> getBoolSetting(String key, {bool fallback = false}) async =>
      switch (await getSetting(key)) {
        null => fallback,
        final v => v == '1',
      };

  Future<void> setBoolSetting(String key, bool value) =>
      setSetting(key, value ? '1' : '0');

  /// Öffnet der Heute-Knopf den Tageseintrag? Die eigene Wahl des
  /// Mitarbeiters (falls je gesetzt) geht vor, sonst gilt die Vorgabe des
  /// Chefs (Chef-Bereich → Mail & Optionen).
  Future<bool> heuteOeffnetEintragFuer(int userId) async {
    final eigene = await getSetting(SettingsKeys.heuteOeffnetEintrag(userId));
    if (eigene != null) return eigene == '1';
    return getBoolSetting(SettingsKeys.heuteOeffnetEintragStandard);
  }

  // ---------- Benutzer ----------

  Future<User?> userByName(String username) =>
      (select(users)..where((t) => t.username.equals(username)))
          .getSingleOrNull();

  Future<List<User>> allUsers() =>
      (select(users)..orderBy([(t) => OrderingTerm.asc(t.displayName)])).get();

  Future<UserSetting> settingsFor(int userId) async {
    final row = await (select(userSettings)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
    if (row != null) return row;
    final companion = UserSettingsCompanion.insert(
        userId: Value(userId), sollModus: SollModus.moDoFrGetrennt);
    await into(userSettings).insert(companion, mode: InsertMode.insertOrIgnore);
    return (select(userSettings)..where((t) => t.userId.equals(userId)))
        .getSingle();
  }

  // ---------- Zeiteinträge ----------

  Future<List<TimeEntry>> entriesForMonth(int userId, int jahr, int monat) {
    final von = DateTime(jahr, monat, 1);
    final bis = DateTime(jahr, monat + 1, 1);
    return (select(timeEntries)
          ..where((t) =>
              t.userId.equals(userId) &
              t.datum.isBiggerOrEqualValue(von) &
              t.datum.isSmallerThanValue(bis))
          ..orderBy([(t) => OrderingTerm.asc(t.datum)]))
        .get();
  }

  Stream<List<TimeEntry>> watchMonth(int userId, int jahr, int monat) {
    final von = DateTime(jahr, monat, 1);
    final bis = DateTime(jahr, monat + 1, 1);
    return (select(timeEntries)
          ..where((t) =>
              t.userId.equals(userId) &
              t.datum.isBiggerOrEqualValue(von) &
              t.datum.isSmallerThanValue(bis))
          ..orderBy([(t) => OrderingTerm.asc(t.datum)]))
        .watch();
  }

  /// Alle Einträge des Benutzers (für den kumulierten Überstundensaldo).
  Future<List<TimeEntry>> allEntriesUntil(int userId, DateTime bisExklusiv) =>
      (select(timeEntries)
            ..where((t) =>
                t.userId.equals(userId) &
                t.datum.isSmallerThanValue(bisExklusiv)))
          .get();

  Future<void> upsertEntry(TimeEntriesCompanion entry) =>
      into(timeEntries).insert(entry,
          onConflict: DoUpdate.withExcluded(
            (old, excluded) => TimeEntriesCompanion.custom(
              tagesart: excluded.tagesart,
              ortId: excluded.ortId,
              beginnMin: excluded.beginnMin,
              pauseMin: excluded.pauseMin,
              endeMin: excluded.endeMin,
              notiz: excluded.notiz,
              halberTag: excluded.halberTag,
              sonderurlaubGrund: excluded.sonderurlaubGrund,
              urlaubMinuten: excluded.urlaubMinuten,
            ),
            target: [timeEntries.userId, timeEntries.datum],
          ));

  Future<void> deleteEntry(int userId, DateTime datum) =>
      (delete(timeEntries)
            ..where((t) =>
                t.userId.equals(userId) & t.datum.equals(datum)))
          .go();

  /// Alle Einträge eines Benutzers (für die Konten-Berechnung, siehe
  /// lib/logic/konten.dart).
  Future<List<TimeEntry>> allEntries(int userId) => (select(timeEntries)
        ..where((t) => t.userId.equals(userId))
        ..orderBy([(t) => OrderingTerm.asc(t.datum)]))
      .get();

  Stream<List<TimeEntry>> watchAllEntries(int userId) => (select(timeEntries)
        ..where((t) => t.userId.equals(userId))
        ..orderBy([(t) => OrderingTerm.asc(t.datum)]))
      .watch();

  // ---------- Orte ----------

  Future<List<Place>> recentPlaces({int limit = 8}) => (select(places)
        ..orderBy([
          (t) => OrderingTerm.desc(t.useCount),
          (t) => OrderingTerm.desc(t.lastUsedAt),
        ])
        ..limit(limit))
      .get();

  /// Liefert die Ort-Id; legt den Ort bei Bedarf an und zählt die Nutzung hoch.
  Future<int> touchPlace(String name) async {
    final trimmed = name.trim();
    final existing = await (select(places)
          ..where((t) => t.name.equals(trimmed)))
        .getSingleOrNull();
    if (existing != null) {
      await (update(places)..where((t) => t.id.equals(existing.id))).write(
          PlacesCompanion(
              useCount: Value(existing.useCount + 1),
              lastUsedAt: Value(DateTime.now())));
      return existing.id;
    }
    return into(places).insert(PlacesCompanion.insert(
        name: trimmed, useCount: const Value(1)));
  }

  // ---------- Branding ----------

  Future<Branding> branding() async =>
      (select(brandings)..where((t) => t.id.equals(1))).getSingle();

  Stream<Branding> watchBranding() =>
      (select(brandings)..where((t) => t.id.equals(1))).watchSingle();

  // ---------- Import / Auswertung ----------

  /// Führt die Monatsdaten eines Mitarbeiters TAGGENAU in die Auswertung ein:
  /// Nur die Tage, die die neue Datei mitbringt, werden ersetzt – Tage aus
  /// früheren Importen (z.B. von einem zweiten Gerät desselben Benutzers)
  /// bleiben erhalten. So ergeben zwei Geräte zusammen den vollen Monat, und
  /// ein erneut geschickter, korrigierter Tag überschreibt genau diesen Tag.
  Future<void> mergeImport(String quellUsername, String monat,
      List<ImportedEntriesCompanion> rows) async {
    await transaction(() async {
      final tage = [for (final r in rows) r.datum.value];
      if (tage.isNotEmpty) {
        await (delete(importedEntries)
              ..where((t) =>
                  t.quellUsername.equals(quellUsername) &
                  t.monat.equals(monat) &
                  t.datum.isIn(tage)))
            .go();
      }
      await batch((b) => b.insertAll(importedEntries, rows));
    });
  }

  Future<List<ImportedEntry>> importedForUser(String quellUsername) =>
      (select(importedEntries)
            ..where((t) => t.quellUsername.equals(quellUsername))
            ..orderBy([(t) => OrderingTerm.asc(t.datum)]))
          .get();

  Future<List<ImportedEntry>> allImported() => (select(importedEntries)
        ..orderBy([
          (t) => OrderingTerm.asc(t.quellUsername),
          (t) => OrderingTerm.asc(t.datum),
        ]))
      .get();
}
