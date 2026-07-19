import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lizenz_shared/lizenz_shared.dart';
import 'package:lizenz_shared/oeffentlicher_schluessel.dart';

import '../data/database.dart';

/// Ergebnis eines Lizenz-Imports (Code oder Datei).
sealed class LizenzErgebnis {}

class LizenzOk extends LizenzErgebnis {}

class LizenzFehler extends LizenzErgebnis {
  final String meldung;
  LizenzFehler(this.meldung);
}

/// Prueft und verwaltet die offline Firmenlizenz (Freischaltcode oder
/// signierte Datei), gebunden an den in den Firmendaten hinterlegten
/// Firmennamen. Verwendet nur den in der App eingebetteten OEFFENTLICHEN
/// Schluessel - kann Lizenzen also nur pruefen, nicht erzeugen.
class LizenzService {
  final ZeitexaDb db;

  /// In Tests injizierbar; in der App immer der eingebettete Schluessel.
  final List<int> _oeffentlicherSchluessel;

  LizenzService(this.db, {List<int>? oeffentlicherSchluessel})
      : _oeffentlicherSchluessel =
            oeffentlicherSchluessel ?? oeffentlicherSchluesselBytes;

  /// Ist aktuell eine gueltige, zum Firmennamen passende Lizenz gespeichert?
  Future<bool> istFreigeschaltet() async {
    final lizenz = await _geladeneLizenz();
    if (lizenz == null) return false;
    final firmenname = (await db.branding()).firmenname;
    return pruefeLizenz(lizenz, firmenname, _oeffentlicherSchluessel);
  }

  Future<SignierteLizenz?> _geladeneLizenz() async {
    final payloadB64 = await db.getSetting(SettingsKeys.lizenzPayload);
    final signaturB64 = await db.getSetting(SettingsKeys.lizenzSignatur);
    if (payloadB64 == null || signaturB64 == null) return null;
    try {
      return SignierteLizenz(
        payload: Uint8List.fromList(base64.decode(payloadB64)),
        signatur: Uint8List.fromList(base64.decode(signaturB64)),
      );
    } catch (_) {
      return null;
    }
  }

  /// Loest einen vom Nutzer eingetippten Freischaltcode fuer den
  /// angegebenen Firmennamen ein.
  Future<LizenzErgebnis> codeEinloesen(String code, String firmenname) async {
    if (firmenname.trim().isEmpty) {
      return LizenzFehler('Bitte den Firmennamen eingeben.');
    }
    if (code.trim().isEmpty) {
      return LizenzFehler('Bitte einen Freischaltcode eingeben.');
    }
    try {
      return await _pruefenUndSpeichern(parseFreischaltcode(code), firmenname);
    } on FormatException {
      return LizenzFehler(
          'Der Freischaltcode ist ungueltig (falsches Format).');
    }
  }

  /// Importiert eine signierte Lizenzdatei (JSON-Inhalt als Text) fuer den
  /// angegebenen Firmennamen.
  Future<LizenzErgebnis> dateiEinloesen(
      String jsonInhalt, String firmenname) async {
    if (firmenname.trim().isEmpty) {
      return LizenzFehler('Bitte den Firmennamen eingeben.');
    }
    try {
      return await _pruefenUndSpeichern(
          parseLizenzdateiJson(jsonInhalt), firmenname);
    } on FormatException {
      return LizenzFehler('Die Lizenzdatei ist ungueltig oder beschaedigt.');
    } catch (_) {
      return LizenzFehler('Die Lizenzdatei konnte nicht gelesen werden.');
    }
  }

  /// Prueft die Lizenz gegen [firmenname]; bei Erfolg wird der Firmenname
  /// ins Branding uebernommen und die Lizenz gespeichert.
  Future<LizenzErgebnis> _pruefenUndSpeichern(
      SignierteLizenz lizenz, String firmenname) async {
    final gueltig =
        await pruefeLizenz(lizenz, firmenname, _oeffentlicherSchluessel);
    if (!gueltig) {
      return LizenzFehler(
          'Dieser Freischaltcode/diese Datei passt nicht zum Firmennamen '
          '"${firmenname.trim()}" oder ist ungueltig. Firmenname genau wie '
          'vom Entwickler vorgegeben eingeben, oder einen passenden Code '
          'anfordern.');
    }
    await (db.update(db.brandings)..where((t) => t.id.equals(1)))
        .write(BrandingsCompanion(firmenname: Value(firmenname.trim())));
    await db.setSetting(SettingsKeys.lizenzPayload, base64.encode(lizenz.payload));
    await db.setSetting(
        SettingsKeys.lizenzSignatur, base64.encode(lizenz.signatur));
    // Liefert die Lizenzdatei das Entwickler-Passwort mit (Version-2-Payload,
    // mitsigniert), wird dessen Hash uebernommen - so legt der Entwickler
    // das Passwort fest, nicht der Kunde bei der Ersteinrichtung.
    final entwicklerHash = lizenz.entwicklerPasswortHash;
    if (entwicklerHash != null && entwicklerHash.isNotEmpty) {
      await db.setSetting(SettingsKeys.brandingPasswordHash, entwicklerHash);
    }
    return LizenzOk();
  }

  /// Erstellt den JSON-Inhalt der signierten Lizenzdatei zum Exportieren
  /// (z.B. um sie an ein anderes Geraet/Plattform weiterzugeben).
  /// Wirft [StateError], wenn keine gueltige Lizenz vorliegt.
  Future<String> exportiereLizenzdatei() async {
    final lizenz = await _geladeneLizenz();
    if (lizenz == null) {
      throw StateError('Keine Lizenz vorhanden.');
    }
    final firmenname = (await db.branding()).firmenname;
    return erstelleLizenzdateiJson(lizenz, firmenname);
  }
}
