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

/// Prueft und verwaltet die Offline-Lizenz (Freischaltcode oder signierte
/// Datei). Die Lizenz ist an den Namen des Lizenznehmers gebunden; dieser
/// Name ist zugleich der Anzeigename des Profils und laesst sich nur ueber
/// eine neue Lizenz aendern. Verwendet nur den in der App eingebetteten
/// OEFFENTLICHEN Schluessel - kann Lizenzen also nur pruefen, nicht
/// erzeugen.
class LizenzService {
  final ZeitexaDb db;

  /// In Tests injizierbar; in der App immer der eingebettete Schluessel.
  final List<int> _oeffentlicherSchluessel;

  LizenzService(this.db, {List<int>? oeffentlicherSchluessel})
      : _oeffentlicherSchluessel =
            oeffentlicherSchluessel ?? oeffentlicherSchluesselBytes;

  /// Ist aktuell eine gueltige, zum Lizenznamen passende Lizenz gespeichert?
  Future<bool> istFreigeschaltet() async {
    final lizenz = await _geladeneLizenz();
    if (lizenz == null) return false;
    final name = (await db.branding()).firmenname;
    return pruefeLizenz(lizenz, name, _oeffentlicherSchluessel);
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

  /// Loest einen vom Nutzer eingetippten Freischaltcode ein. Der Code
  /// enthaelt den Namen nur als Pruefsumme, deshalb muss er hier exakt so
  /// mitgegeben werden, wie ihn der Entwickler vorgegeben hat.
  Future<LizenzErgebnis> codeEinloesen(String code, String name) async {
    if (name.trim().isEmpty) {
      return LizenzFehler('Bitte den Namen des Lizenznehmers eingeben.');
    }
    if (code.trim().isEmpty) {
      return LizenzFehler('Bitte einen Freischaltcode eingeben.');
    }
    try {
      return await _pruefenUndSpeichern(parseFreischaltcode(code), name);
    } on FormatException {
      return LizenzFehler(
          'Der Freischaltcode ist ungueltig (falsches Format).');
    }
  }

  /// Importiert eine signierte Lizenzdatei (JSON-Inhalt als Text). Der Name
  /// des Lizenznehmers steht in der Datei selbst und wird gegen die
  /// Signatur geprueft - eingetippt werden muss nichts.
  Future<LizenzErgebnis> dateiEinloesen(String jsonInhalt) async {
    try {
      final inhalt = parseLizenzdatei(jsonInhalt);
      final name = inhalt.name;
      if (name == null) {
        return LizenzFehler(
            'Die Lizenzdatei enthaelt keinen Namen - bitte eine aktuelle '
            'Datei vom Entwickler anfordern.');
      }
      return await _pruefenUndSpeichern(inhalt.lizenz, name);
    } on FormatException {
      return LizenzFehler('Die Lizenzdatei ist ungueltig oder beschaedigt.');
    } catch (_) {
      return LizenzFehler('Die Lizenzdatei konnte nicht gelesen werden.');
    }
  }

  /// Prueft die Lizenz gegen [name]; bei Erfolg wird der Name als
  /// Lizenzname UND als Anzeigename des Profils uebernommen und die Lizenz
  /// gespeichert.
  Future<LizenzErgebnis> _pruefenUndSpeichern(
      SignierteLizenz lizenz, String name) async {
    final gueltig = await pruefeLizenz(lizenz, name, _oeffentlicherSchluessel);
    if (!gueltig) {
      return LizenzFehler(
          'Dieser Freischaltcode/diese Datei passt nicht zum Namen '
          '"${name.trim()}" oder ist ungueltig. Den Namen genau wie vom '
          'Entwickler vorgegeben eingeben, oder einen passenden Code '
          'anfordern.');
    }
    await (db.update(db.brandings)..where((t) => t.id.equals(1)))
        .write(BrandingsCompanion(firmenname: Value(name.trim())));
    await db.setSetting(SettingsKeys.lizenzPayload, base64.encode(lizenz.payload));
    await db.setSetting(
        SettingsKeys.lizenzSignatur, base64.encode(lizenz.signatur));
    await synchronisiereAnzeigename();
    return LizenzOk();
  }

  /// Gleicht den Anzeigenamen des (einzigen) Profils an den Lizenznamen an.
  /// Vor der Ersteinrichtung gibt es noch kein Profil - dann passiert
  /// nichts. Wird auch beim Start aufgerufen, damit Installationen aus der
  /// Zeit, als der Name noch frei waehlbar war, einmalig nachziehen.
  Future<void> synchronisiereAnzeigename() async {
    final name = (await db.branding()).firmenname;
    await db.update(db.users).write(UsersCompanion(displayName: Value(name)));
  }

  /// Erstellt den JSON-Inhalt der signierten Lizenzdatei zum Exportieren
  /// (z.B. um sie an ein anderes Geraet/Plattform weiterzugeben).
  /// Wirft [StateError], wenn keine gueltige Lizenz vorliegt.
  Future<String> exportiereLizenzdatei() async {
    final lizenz = await _geladeneLizenz();
    if (lizenz == null) {
      throw StateError('Keine Lizenz vorhanden.');
    }
    final name = (await db.branding()).firmenname;
    return erstelleLizenzdateiJson(lizenz, name);
  }
}
