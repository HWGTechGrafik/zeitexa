import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart';

import '../data/database.dart';

/// Benutzername des einen Zeitexa-Profils. Zeitexa kennt keine Anmeldung –
/// der Name existiert nur, weil die Datenbank (gemeinsam mit der
/// Firmenversion) eine Benutzerspalte hat. Sichtbar ist immer nur der frei
/// wählbare Anzeigename.
const String kEinzelBenutzername = 'ich';

class AuthService {
  final ZeitexaDb db;
  AuthService(this.db);

  static String hash(String passwort) =>
      BCrypt.hashpw(passwort, BCrypt.gensalt());

  static bool pruefe(String passwort, String hash) =>
      BCrypt.checkpw(passwort, hash);

  /// Ist die Ersteinrichtung schon erledigt (Profil vorhanden)?
  Future<bool> istEingerichtet() async => await einzelUser() != null;

  /// Das eine Profil dieser Installation, oder null vor der Einrichtung.
  Future<User?> einzelUser() async {
    final alle = await db.allUsers();
    return alle.isEmpty ? null : alle.first;
  }

  /// Ersteinrichtung: legt das einzige Profil an. Gefragt wird nur der
  /// Anzeigename – alle Zeit- und Urlaubswerte starten mit Vorgaben und
  /// werden vom Nutzer selbst in der Verwaltung gesetzt (Hinweiskarte in
  /// der Monatsansicht, siehe [SettingsKeys.einstellungenGeprueft]).
  Future<User> ersteinrichtung({required String anzeigename}) async {
    final id = await db.into(db.users).insert(UsersCompanion.insert(
          username: kEinzelBenutzername,
          // Ohne Anmeldung wird der Hash nie geprüft; er bleibt gesetzt,
          // damit die gemeinsame Datenbankspalte gültig befüllt ist.
          passwordHash: hash('-'),
          displayName: anzeigename.trim(),
          isAdmin: const Value(true),
        ));
    await db.settingsFor(id);
    return (db.select(db.users)..where((t) => t.id.equals(id))).getSingle();
  }

  // ---------- App-Sperre (optional, standardmäßig aus) ----------

  /// Ist die App durch ein Passwort geschützt?
  Future<bool> appSperreAktiv() async =>
      await db.getSetting(SettingsKeys.appSperreHash) != null;

  Future<void> setzeAppSperre(String passwort) =>
      db.setSetting(SettingsKeys.appSperreHash, hash(passwort));

  Future<void> entferneAppSperre() =>
      db.loescheSetting(SettingsKeys.appSperreHash);

  Future<bool> pruefeAppSperre(String passwort) async {
    final gespeichert = await db.getSetting(SettingsKeys.appSperreHash);
    return gespeichert != null && pruefe(passwort, gespeichert);
  }

  /// Legt einen Benutzer an. In Zeitexa nur für Tests und den internen
  /// Testmodus relevant – die App legt genau ein Profil an.
  Future<User> benutzerAnlegen({
    required String username,
    required String anzeigename,
    required String passwort,
    bool mustChangePassword = false,
    SollModus? sollModus,
    double? sollTag,
    double? sollMoDo,
    double? sollFr,
    String? mitarbeiterEmail,
    int? standardBeginnMin,
    int? standardEndeMin,
    int? standardPauseMin,
    DateTime? anfangsstandStichtag,
    double? anfangsstandUrlaubTage,
    int? anfangsstandZeitausgleichMin,
    bool? urlaubFrGetrennt,
    double? anfangsstandUrlaubFrTage,
    bool? firmenurlaubAktiv,
    double? anfangsstandFirmenurlaubTage,
    int? standardBeginnFrMin,
    int? standardEndeFrMin,
    int? standardPauseFrMin,
  }) async {
    final vorhanden = await db.userByName(username.trim());
    if (vorhanden != null) {
      throw ArgumentError('Benutzername ist schon vergeben.');
    }
    final id = await db.into(db.users).insert(UsersCompanion.insert(
          username: username.trim(),
          passwordHash: hash(passwort),
          displayName: anzeigename.trim(),
          mustChangePassword: Value(mustChangePassword),
          mitarbeiterEmail: Value(mitarbeiterEmail?.trim() ?? ''),
        ));
    final defaults = await _defaultSoll();
    await db.into(db.userSettings).insert(UserSettingsCompanion.insert(
          userId: Value(id),
          sollModus: sollModus ?? defaults.modus,
          sollStundenTag: Value(sollTag ?? defaults.stundenTag),
          sollStundenMoDo: Value(sollMoDo ?? defaults.stundenMoDo),
          sollStundenFr: Value(sollFr ?? defaults.stundenFr),
          standardBeginnMin: Value(standardBeginnMin ?? 7 * 60),
          standardEndeMin: Value(standardEndeMin ?? 16 * 60),
          standardPauseMin: Value(standardPauseMin ?? 30),
          anfangsstandStichtag: Value(anfangsstandStichtag),
          anfangsstandUrlaubTage: Value(anfangsstandUrlaubTage ?? 0),
          anfangsstandZeitausgleichMin:
              Value(anfangsstandZeitausgleichMin ?? 0),
          urlaubFrGetrennt: Value(urlaubFrGetrennt ?? false),
          anfangsstandUrlaubFrTage: Value(anfangsstandUrlaubFrTage ?? 0),
          firmenurlaubAktiv: Value(firmenurlaubAktiv ?? false),
          anfangsstandFirmenurlaubTage:
              Value(anfangsstandFirmenurlaubTage ?? 0),
          standardBeginnFrMin: Value(standardBeginnFrMin),
          standardEndeFrMin: Value(standardEndeFrMin),
          standardPauseFrMin: Value(standardPauseFrMin),
        ));
    return (db.select(db.users)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<({SollModus modus, double stundenTag, double stundenMoDo, double stundenFr})>
      _defaultSoll() async {
    final modusRaw = await db.getSetting(SettingsKeys.defaultSollModus);
    final modus = modusRaw == SollModus.gleich.index.toString()
        ? SollModus.gleich
        : SollModus.moDoFrGetrennt;
    double lese(String? v, double fallback) =>
        double.tryParse(v ?? '') ?? fallback;
    return (
      modus: modus,
      stundenTag: lese(await db.getSetting(SettingsKeys.defaultSollTag), 8),
      stundenMoDo: lese(await db.getSetting(SettingsKeys.defaultSollMoDo), 8),
      stundenFr: lese(await db.getSetting(SettingsKeys.defaultSollFr), 5),
    );
  }

  Future<void> passwortAendern(int userId, String neuesPasswort) =>
      (db.update(db.users)..where((t) => t.id.equals(userId))).write(
          UsersCompanion(
              passwordHash: Value(hash(neuesPasswort)),
              mustChangePassword: const Value(false)));
}
