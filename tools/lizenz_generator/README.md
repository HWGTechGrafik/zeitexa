# Zeitexa Lizenzgenerator

Entwickler-Tool zum Erzeugen von Firmenlizenzen fuer Zeitexa. Dieses Tool ist
bewusst getrennt vom App-Code: der private Schluessel, den es verwendet,
darf niemals in die App oder ein oeffentliches Repository gelangen.

**Tipp:** Fuer den Alltag gibt es eine grafische Oberflaeche unter
`tools/lizenz_gui` (EXE nach dem Bauen unter
`tools/lizenz_gui/build/windows/x64/runner/Release/lizenz_gui.exe`):
Firmenname eintippen, Code kopieren, fertig. Dieses CLI bleibt fuer
`keygen` und als Fallback bestehen. Beide nutzen dieselbe Logik und
liefern fuer denselben Firmennamen denselben Code.

## Einmalige Einrichtung

```
cd tools/lizenz_generator
dart pub get
dart run bin/lizenz_generator.dart keygen
```

Das erzeugt `schluessel/privater_schluessel.json` (bleibt lokal, ist per
`.gitignore` ausgeschlossen) und gibt den **oeffentlichen** Schluessel als
Dart-Liste aus. Diese Liste EINMALIG eintragen in:

```
packages/lizenz_shared/lib/oeffentlicher_schluessel.dart
```

Danach `keygen` nie wieder ausfuehren, solange bereits Lizenzen im Umlauf
sind - ein neues Schluesselpaar macht alle bisher ausgegebenen Codes/Dateien
ungueltig (die App kennt dann einen anderen oeffentlichen Schluessel).

**Sicherung des privaten Schluessels:** `schluessel/privater_schluessel.json`
an einem sicheren Ort ausserhalb des Repos sichern (z.B. Passwort-Manager,
verschluesseltes Backup). Ohne diese Datei koennen keine neuen Lizenzen mehr
erzeugt werden.

## Lizenz fuer eine Firma erzeugen

```
dart run bin/lizenz_generator.dart erzeugen --firma "Muster GmbH" --entwickler-passwort "<geheim>"
```

Ausgabe:
- Ein **Freischaltcode** (Base32, gruppiert) zum Eintippen in der App.
- Eine **signierte Lizenzdatei** unter `ausgabe/<firma>.zeitexalizenz.json`
  zum Importieren in der App (z.B. auf Geraeten ohne bequeme Texteingabe,
  oder um die Datei per Mail zu verschicken).

Beide schalten dieselbe Firma frei und sind austauschbar - der Chef braucht
nur eines von beiden.

**Entwickler-Passwort:** Mit `--entwickler-passwort` (mind. 12 Zeichen,
empfohlen: immer dasselbe verwenden) wird der bcrypt-Hash des Passworts
mitsigniert in die LIZENZDATEI eingebettet. Beim Import uebernimmt die App
den Hash als Passwort fuer den versteckten Entwickler-/Branding-Bereich -
der Kunde legt es seit v1.2.1 nicht mehr selbst fest. Der Freischaltcode
bleibt davon unberuehrt (und liefert daher auch KEIN Entwickler-Passwort).
Bereits freigeschaltete Installationen koennen die neue Datei im
Chef-Bereich unter "Lizenz" nachtraeglich importieren.

**Wichtig:** Der Freischaltcode/die Datei ist an den Firmennamen gebunden,
den der Chef in der App unter "Firmendaten" eintraegt (nach Normalisierung:
Gross-/Kleinschreibung, Umlaute und mehrfache Leerzeichen spielen keine
Rolle, der Kern des Namens muss aber uebereinstimmen). Am besten den exakten
Firmennamen wie vom Chef gewuenscht als `--firma`-Wert verwenden und ihm
mitteilen, dass er in der App denselben Namen eintragen soll.

Fuer eine andere Firma einfach erneut mit anderem `--firma`-Wert aufrufen -
das ergibt automatisch einen anderen Code.
