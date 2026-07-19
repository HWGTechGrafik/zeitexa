import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

import '../data/database.dart';

/// Entsperren per Fingerabdruck/Gesicht (Windows Hello, Android-Biometrie,
/// auf iOS Face ID/Touch ID). Es wird KEIN Passwort gespeichert: es gibt nur
/// ein Opt-in-Flag; nach erfolgreicher Geraete-Authentifizierung gilt die
/// App-Sperre als geoeffnet.
///
/// Nur nutzbar, wenn die optionale App-Sperre eingeschaltet ist - ohne
/// Sperre gibt es nichts zu entsperren. Auf Web nicht verfuegbar.
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

  // ---------- Opt-in ----------

  Future<bool> istAktiviertFuer(int userId) =>
      db.getBoolSetting(SettingsKeys.biometrie(userId));

  Future<void> aktivierenFuer(int userId) =>
      db.setBoolSetting(SettingsKeys.biometrie(userId), true);

  Future<void> deaktivierenFuer(int userId) =>
      db.setBoolSetting(SettingsKeys.biometrie(userId), false);

  /// Darf zum Entsperren ein Fingerabdruck angeboten werden? Setzt voraus,
  /// dass das Geraet es kann und der Nutzer es eingeschaltet hat.
  Future<bool> entsperrenMoeglich(int userId) async =>
      await geraetUnterstuetzt() && await istAktiviertFuer(userId);
}
