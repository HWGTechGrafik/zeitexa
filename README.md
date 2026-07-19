# Zeitexa – Offline-Stundenerfassung

Zeitexa ist eine Offline-App zur Stundenerfassung für Mitarbeiter. Alle Daten
bleiben lokal am Gerät – kein Server, kein Konto im Internet.

## Funktionen

- **Firmenlizenz (Ed25519)**: Beim allerersten Start wird die App mit
  Firmenname + Freischaltcode (oder Lizenzdatei) freigeschaltet – vor der
  Einrichtung; ohne gültige Lizenz bleibt sie gesperrt
- **Login bei jedem Start** (Benutzername + Passwort, bcrypt-gehasht),
  mehrere Benutzer pro Gerät möglich; optional **Anmeldung per
  Fingerabdruck/Gesicht** (Windows Hello / Android-Biometrie, Opt-in pro
  Benutzer, Admin-Schalter; nicht im Browser)
- **Monatsansicht 01–31** mit Wochentag-Kürzel, Ort (Schnellauswahl der
  zuletzt verwendeten Orte), Beginn, Pause, Ende, Ist/Soll, Überstunden (±), Notiz
- **Tagesarten**: Arbeit, Urlaub (auch von–bis), Krankenstand, Feiertag
  (österreichische Feiertage werden automatisch erkannt), Zeitausgleich
- **Sollstunden pro Mitarbeiter**: ein genereller Tagessatz ODER Mo–Do und
  Freitag getrennt; Sa/So zählen nicht als Soll
- **Monatsexport** als JSON (für die Auswertung) + Excel + PDF (mit Branding
  und Unterschriftszeile)
- **Mailversand**: automatisch per SMTP (wenn konfiguriert) oder über die
  Mail-App des Geräts (Teilen); optionale **Sende-Sperre**: ab dem 1. muss
  zuerst der Vormonat gesendet werden, bevor neu erfasst werden kann
- **Chef-Bereich** (Adminpasswort): Mitarbeiterprofile anlegen, Sollstunden,
  SMTP/Ziel-Mailadresse, Schalter, **Auswertung** (JSON-Dateien importieren →
  Zusammenfassung pro Mitarbeiter/Monat, Gesamt-Export als Excel/PDF)
- **Datensicherung** (Chef-Bereich, Windows/Android): komplette Datenbank
  als eine Datei exportieren/wiederherstellen – auch zum Übertragen einer
  fertig eingerichteten Installation auf einen weiteren PC (USB-Stick)
- **Versteckter Entwickler-Bereich** (7× auf die Versionsnummer im
  „Über Zeitexa"-Dialog tippen, eigenes langes Passwort): Firmenname, Adresse,
  Logo, Akzentfarbe – erscheint in der App und auf allen Exporten

## Erste Schritte in der App

1. Beim allerersten Start: Firmenname + Freischaltcode eingeben (Codes
   erzeugt `tools\lizenz_gui` bzw. `tools\lizenz_generator`).
2. Danach einmalige Einrichtung: Adminpasswort, Entwickler-Passwort und das
   eigene Profil festlegen.
3. Chef-Bereich → Benutzer → Mitarbeiter anlegen (Start-Passwort wird beim
   ersten Login geändert).
4. Chef-Bereich → Mail & Optionen → Ziel-Mailadresse (und optional SMTP)
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

- **Lieferpaket für Firmen**: `tools\release\erstelle_paket.ps1` baut den
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
  Browser – der Export wird über das Teilen-Menü per Mail geschickt
  (die Sende-Sperre erinnert daran).

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
Android-Biometrie); Firmenlizenz mit Ed25519 (`packages/lizenz_shared`).
