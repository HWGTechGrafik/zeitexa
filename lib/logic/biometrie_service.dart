import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

import '../data/database.dart';

/// Anmeldung per Fingerabdruck/Gesicht (Windows Hello, Android-Biometrie,
/// auf iOS Face ID/Touch ID). Es wird KEIN Passwort gespeichert: pro
/// Benutzer gibt es nur ein Opt-in-Flag; nach erfolgreicher
/// Geraete-Authentifizierung wird der Benutzer direkt angemeldet.
///
/// Wichtig: Geraete-Biometrie unterscheidet keine Personen - jeder am
/// Geraet hinterlegte Fingerabdruck kann eine aktivierte Anmeldung nutzen.
/// Deshalb doppelt abgesichert: Admin-Schalter (Chef-Bereich) plus
/// bewusstes Opt-in des Benutzers. Auf Web nicht verfuegbar.
class BiometrieService {
  final ZeitexaDb db;

  /// In Tests injizierbar; in der App der echte local_auth-Dialog
  /// bzw. die echte Geraete-Pruefung.
  final Future<bool> Function(String grund) _authentifizierer;
  final Future<bool> Function() _geraeteCheck;

  BiometrieService(
    this.db, {
    Future<bool> Function(String grund)? authentifizierer,
    Future<bool> Function()? geraeteCheck,
  })  : _authentifizierer = authentifizierer ?? _lokaleAuthentifizierung,
        _geraeteCheck = geraeteCheck ?? _lokaleGeraetePruefung;

  static Future<bool> _lokaleAuthentifizierung(String grund) async {
    if (kIsWeb) return false;
    try {
      return await LocalAuthentication().authenticate(
        localizedReason: grund,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {
      // Abbruch, keine Biometrie eingerichtet, Plattformfehler etc.
      return false;
    }
  }

  static Future<bool> _lokaleGeraetePruefung() async {
    if (kIsWeb) return false;
    try {
      return await LocalAuthentication().isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Unterstuetzt dieses Geraet Biometrie/Geraete-Anmeldung ueberhaupt?
  Future<bool> geraetUnterstuetzt() => _geraeteCheck();

  /// Zeigt den System-Dialog (Fingerabdruck/Gesicht/PIN) mit [grund] an.
  Future<bool> authentifizieren(String grund) => _authentifizierer(grund);

  // ---------- Admin-Schalter (Chef-Bereich) ----------

  Future<bool> istErlaubt() =>
      db.getBoolSetting(SettingsKeys.biometrieErlaubt, fallback: true);

  Future<void> setErlaubt(bool erlaubt) =>
      db.setBoolSetting(SettingsKeys.biometrieErlaubt, erlaubt);

  // ---------- Opt-in pro Benutzer ----------

  Future<bool> istAktiviertFuer(int userId) =>
      db.getBoolSetting(SettingsKeys.biometrie(userId));

  Future<void> aktivierenFuer(int userId) =>
      db.setBoolSetting(SettingsKeys.biometrie(userId), true);

  Future<void> deaktivierenFuer(int userId) =>
      db.setBoolSetting(SettingsKeys.biometrie(userId), false);

  /// Benutzer, die sich auf diesem Geraet biometrisch anmelden koennen
  /// (fuer die Buttons am Login-Screen). Leer, wenn der Admin-Schalter
  /// aus ist oder das Geraet keine Biometrie unterstuetzt.
  Future<List<User>> benutzerMitBiometrie() async {
    if (!await istErlaubt() || !await geraetUnterstuetzt()) return [];
    final ergebnis = <User>[];
    for (final user in await db.allUsers()) {
      if (await istAktiviertFuer(user.id)) ergebnis.add(user);
    }
    return ergebnis;
  }
}
