# Zeitexa – Offline-Stundenerfassung

Zeitexa ist eine Offline-App zur Stundenerfassung für **eine einzelne
Person** (Einzelunternehmer, Freiberufler, Angestellte, die ihre Zeiten selbst
führen). Alle Daten bleiben lokal am Gerät – kein Server, kein Konto im
Internet.

Zeitexa ist die Einzelplatz-Schwester der Firmenversion **Zeitrax**: gleiche
Rechenlogik, aber ohne Anmeldung, ohne Benutzerverwaltung und ohne
Chef-Bereich. Beide Projekte werden getrennt entwickelt und haben eigene
Lizenzschlüssel; ein Zeitrax-Code funktioniert hier nicht (und umgekehrt).
Nur der JSON-Monatsexport ist zwischen beiden lesbar.

## Funktionen

- **Lizenz (Ed25519)**: Beim allerersten Start wird die App mit einer
  Lizenzdatei (enthält den Namen des Lizenznehmers) oder mit Name +
  Freischaltcode freigeschaltet; ohne gültige Lizenz bleibt sie gesperrt.
  Der Lizenzname ist zugleich der Anzeigename auf allen Berichten und nur
  über eine neue Lizenz änderbar
- **Keine Anmeldung**: genau ein Profil, die App startet direkt in die
  Monatsansicht. Optionale **App-Sperre** mit selbst vergebenem Passwort
  (Standard: aus), auf Wunsch zusätzlich Entsperren per Fingerabdruck
  (Windows Hello / Android-Biometrie; nicht im Browser)
- **Erststart mit Vorgabewerten** plus Hinweiskarte in der Monatsansicht,
  bis die eigenen Zeit- und Urlaubswerte einmal bestätigt wurden
- **Monatsansicht 01–31** mit Wochentag-Kürzel, Ort (Schnellauswahl der
  zuletzt verwendeten Orte), Beginn, Pause, Ende, Ist/Soll, Überstunden (±), Notiz
- **Tagesarten**: Arbeit, Urlaub (auch von–bis und stundenweise geteilt),
  Krankenstand, Feiertag (österreichische Feiertage werden automatisch
  erkannt), Zeitausgleich, Sonderurlaub (mit Anlass), Zusatzurlaub
- **Sollstunden**: ein genereller Tagessatz ODER Mo–Do und Freitag getrennt,
  mit optionalen eigenen Freitags-Standardzeiten; Sa/So zählen nicht als Soll
- **Monatsexport** als JSON + Excel + PDF (Briefkopf mit Name/Adresse,
  Unterschriftszeilen für Nutzer und Auftraggeber)
- **Mailversand**: automatisch per SMTP (wenn konfiguriert) oder über die
  Mail-App des Geräts (Teilen)
- **Verwaltung** (ohne Passwort, alles selbst einstellbar): Profil mit
  Briefkopf-Kontaktdaten und Sollstunden, Anfangsstände, Optionen
  (Mail inkl. Betreffvorlage, Akzentfarbe, Lizenz-Import/-Export),
  Datensicherung, **Auswertung** über einen frei wählbaren Zeitraum mit
  Excel-/PDF-Export. Einen versteckten Entwickler-Bereich gibt es seit
  v1.1.0 nicht mehr
- **Datensicherung** (Windows/Android): komplette Datenbank als
  `.zeitexadb`-Datei sichern und wiederherstellen; Sicherungen fremder
  Produkte werden anhand einer Produktkennung abgewiesen

## Erste Schritte in der App

1. Beim allerersten Start: Lizenzdatei importieren (der Name kommt aus der
   Datei) oder Namen des Lizenznehmers + Freischaltcode eingeben (erzeugt
   `tools\lizenz_gui` bzw. `tools\lizenz_generator`).
2. Willkommensbildschirm mit „Los geht's" bestätigen – das Profil wird mit
   dem Lizenznamen angelegt.
3. Verwaltung → Mein Profil: Briefkopf, Sollstunden, Anfangsstände und
   Standardzeiten setzen und speichern (danach verschwindet die
   Hinweiskarte).
4. Verwaltung → Optionen: Empfänger der Monatsberichte (und optional SMTP)
   eintragen.

## Entwicklung / Builds

Voraussetzungen (bereits eingerichtet auf diesem PC):
- Flutter SDK unter `C:\dev\flutter` (im PATH)
- Android SDK unter `C:\dev\android-sdk`, OpenJDK 17
- Visual Studio 2022 Build Tools (C++) für den Windows-Build
- **Windows-Entwicklermodus** muss aktiv sein (Einstellungen → System →
  Für Entwickler), sonst schlägt `flutter build windows` fehl

```powershell
flutter test                 # Unit-Tests
flutter build apk --release  # Android: build\app\outputs\flutter-apk\app-release.apk
flutter build windows        # Windows: build\windows\x64\runner\Release\
flutter build web --release  # Web/PWA: build\web\
```

## Verteilung

- **Lieferpaket**: `tools\release\erstelle_paket.ps1` baut den
  Ordner „Lieferung an Kunden" mit Windows-Setup (Inno), Windows-ZIP,
  Android-APK und ANLEITUNG.docx.
- **Android**: `Zeitexa_v<Version>.apk` per Datei weitergeben („Unbekannte
  Quellen" am Handy erlauben) – kein Play Store nötig.
- **Windows**: Setup.exe aus dem Lieferpaket ausführen oder das ZIP
  entpacken und „Zeitexa starten" doppelklicken.
- **iPhone (kostenlos, als PWA)**: Die App ist auf GitHub Pages veröffentlicht:
  **https://hwgtechgrafik.github.io/zeitexa/** – am iPhone in Safari öffnen →
  Teilen → **„Zum Home-Bildschirm"**. Die App läuft danach offline; Daten
  bleiben am Gerät. Einschränkung: kein automatischer SMTP-Versand im
  Browser – der Export wird über das Teilen-Menü per Mail geschickt.

  Neue Version veröffentlichen:
  ```powershell
  flutter build web --release --base-href "/zeitexa/"
  # Inhalt von build\web in den gh-pages-Branch von
  # https://github.com/HWGTechGrafik/zeitexa pushen (nur der Web-Build,
  # NIEMALS der Quellcode!) - Pages veroeffentlicht von gh-pages.
  ```

## Technik

Flutter (eine Codebasis für Android/Windows/Web/iOS), drift/SQLite lokal
(auf Web: WASM + IndexedDB), Riverpod, bcrypt, Pakete `excel`, `pdf`,
`mailer`, `share_plus`, `file_picker`, `local_auth` (Windows Hello /
Android-Biometrie); Lizenz mit Ed25519 (`packages/lizenz_shared`, eigenes
Schlüsselpaar).

App-Symbole werden aus `toolselease\erzeuge_icons.py` erzeugt (ein Aufruf
schreibt alle Größen für Windows, Android und die PWA).
