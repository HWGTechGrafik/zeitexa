# Zeitexa Lizenzgenerator

Entwickler-Tool zum Erzeugen von Einzelnutzer-Lizenzen fuer Zeitexa (die
Lizenz laeuft auf den NAMEN DES NUTZERS). Dieses Tool ist bewusst getrennt
vom App-Code: der private Schluessel, den es verwendet, darf niemals in die
App oder ein oeffentliches Repository gelangen.

**Tipp:** Fuer den Alltag gibt es eine grafische Oberflaeche unter
`tools/lizenz_gui` (EXE nach dem Bauen unter
`tools/lizenz_gui/build/windows/x64/runner/Release/lizenz_gui.exe`):
Namen eintippen, Code kopieren, fertig. Dieses CLI bleibt fuer
`keygen` und als Fallback bestehen. Beide nutzen dieselbe Logik und
liefern fuer denselben Namen denselben Code.

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

## Lizenz fuer einen Nutzer erzeugen

```
dart run bin/lizenz_generator.dart erzeugen --name "Max Muster"
```

Ausgabe:
- Ein **Freischaltcode** (Base32, gruppiert) zum Eintippen in der App
  (dazu muss der Nutzer seinen Namen exakt wie hier angegeben eintippen).
- Eine **signierte Lizenzdatei** unter `ausgabe/<name>.zeitexalizenz.json`
  zum Importieren in der App - der bequemste Weg, denn die Datei enthaelt
  den Namen bereits und die App uebernimmt ihn automatisch.

Beide schalten denselben Nutzer frei und sind austauschbar.

**Entwickler-Passwort:** Mit `--entwickler-passwort` wird der bcrypt-Hash
des Passworts mitsigniert in die LIZENZDATEI eingebettet (Version-2-Payload).
Seit Zeitexa v1.1.0 gibt es in der App aber KEINEN versteckten
Entwickler-Bereich mehr - die App ignoriert den Hash einfach. Die Option
bleibt nur aus Kompatibilitaet erhalten; fuer Zeitexa-Lizenzen kann sie
schlicht weggelassen werden.
Bereits freigeschaltete Installationen koennen eine neue Datei in der
Verwaltung unter Optionen -> "Lizenzdatei importieren" einspielen; der in
der Datei enthaltene Name wird dabei (signiert geprueft) uebernommen.

**Wichtig:** Der Freischaltcode/die Datei ist an den Namen des Nutzers
gebunden (nach Normalisierung: Gross-/Kleinschreibung, Umlaute und mehrfache
Leerzeichen spielen keine Rolle, der Kern des Namens muss aber
uebereinstimmen). Dieser Name ist in der App zugleich der Anzeigename auf
allen Berichten und laesst sich dort nicht aendern - bei Tippfehlern oder
Namensaenderung einfach eine neue Lizenzdatei erzeugen und schicken.

Fuer einen anderen Nutzer einfach erneut mit anderem `--name`-Wert
aufrufen - das ergibt automatisch einen anderen Code.
