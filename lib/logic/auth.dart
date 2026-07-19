import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart';

import '../data/database.dart';

/// Ergebnis eines Login-Versuchs.
sealed class LoginErgebnis {}

class LoginOk extends LoginErgebnis {
  final User user;
  LoginOk(this.user);
}

class LoginFehler extends LoginErgebnis {
  final String meldung;
  LoginFehler(this.meldung);
}

class AuthService {
  final ZeitexaDb db;
  AuthService(this.db);

  static String hash(String passwort) =>
      BCrypt.hashpw(passwort, BCrypt.gensalt());

  static bool pruefe(String passwort, String hash) =>
      BCrypt.checkpw(passwort, hash);

  /// Ist die Ersteinrichtung schon erledigt (Adminpasswort gesetzt)?
  Future<bool> istEingerichtet() async =>
      await db.getSetting(SettingsKeys.adminPasswordHash) != null;

  /// Ersteinrichtung: Adminpasswort und erstes Benutzerprofil (der Chef
  /// selbst) anlegen. Der Firmenname wurde bereits bei der
  /// Lizenz-Freischaltung gespeichert. Das Entwickler-/Branding-Passwort
  /// legt NICHT der Kunde fest - es kommt als Hash aus der importierten
  /// Lizenzdatei (siehe LizenzService).
  Future<User> ersteinrichtung({
    required String adminPasswort,
    required String username,
    required String anzeigename,
    required String benutzerPasswort,
  }) async {
    await setzeAdminPasswort(adminPasswort);
    final id = await db.into(db.users).insert(UsersCompanion.insert(
          username: username.trim(),
          passwordHash: hash(benutzerPasswort),
          displayName: anzeigename.trim(),
          isAdmin: const Value(true),
        ));
    await db.settingsFor(id);
    return (db.select(db.users)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Setzt das Adminpasswort (Chef-Bereich). Wird von [ersteinrichtung]
  /// genutzt und vom Setup-Screen, wenn die Benutzer bereits aus einer
  /// Benutzerdatei übernommen wurden und nur noch das Adminpasswort fehlt.
  Future<void> setzeAdminPasswort(String adminPasswort) =>
      db.setSetting(SettingsKeys.adminPasswordHash, hash(adminPasswort));

  /// Übernimmt einen bereits fertigen bcrypt-Hash als Adminpasswort – für
  /// den Import einer Benutzerdatei, die das Adminpasswort mitbringt. Das
  /// Klartext-Passwort ist dabei nie bekannt.
  Future<void> setzeAdminPasswortHash(String bcryptHash) =>
      db.setSetting(SettingsKeys.adminPasswordHash, bcryptHash);

  Future<LoginErgebnis> login(String username, String passwort) async {
    final user = await db.userByName(username.trim());
    if (user == null || !pruefe(passwort, user.passwordHash)) {
      return LoginFehler('Benutzername oder Passwort falsch.');
    }
    return LoginOk(user);
  }

  /// Legt einen Benutzer an (durch den Admin oder Selbst-Registrierung).
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

  Future<bool> pruefeAdminPasswort(String passwort) async {
    final gespeichert = await db.getSetting(SettingsKeys.adminPasswordHash);
    return gespeichert != null && pruefe(passwort, gespeichert);
  }

  Future<bool> pruefeBrandingPasswort(String passwort) async {
    final gespeichert = await db.getSetting(SettingsKeys.brandingPasswordHash);
    return gespeichert != null && pruefe(passwort, gespeichert);
  }
}
