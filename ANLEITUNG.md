# Zeitexa – Installations- und Bedienungsanleitung

Zeitexa ist eine Stundenerfassungs-App, die komplett **offline** funktioniert. Alle Daten bleiben auf dem jeweiligen Gerät – es gibt keinen Server und kein Benutzerkonto im Internet. Internet wird nur für den optionalen Mail-Versand des Monatsberichts gebraucht.

Die Anleitung ist so aufgebaut, dass jeder nur seinen Teil lesen muss:

| Abschnitt | Für wen |
|---|---|
| 1 – Installation | Alle (je nach Gerät) |
| 2 – Freischaltung und Ersteinrichtung | Chef (einmalig pro Gerät) |
| 3 – Anmeldung | Alle |
| 4 – Tägliche Bedienung | Mitarbeiter |
| 5 – Chef-Bereich | Chef |
| 6 – Firmen-Logo und Farben | Chef (optional) |
| 7 – Häufige Fragen | Alle |

**Wichtig – Freischaltung:** Beim ersten Start muss die App einmalig mit einem **Freischaltcode** oder einer **Lizenzdatei** für Ihre Firma freigeschaltet werden. Beides bekommen Sie vom Entwickler. Ohne Freischaltung lässt sich die App nicht verwenden.

---

## 1. Installation

### 1.1 Windows-PC

Es gibt zwei Wege – der Installer ist der einfachste:

**Weg A – Installer (empfohlen):** Im Lieferpaket liegt unter „Windows Setup" die Datei `Zeitexa_Setup_v….exe`.

1. Doppelklick auf die Setup-Datei.
2. **Falls Windows warnt** („Der Computer wurde durch Windows geschützt" / SmartScreen): auf **„Weitere Informationen"** klicken und dann **„Trotzdem ausführen"**. Die Warnung erscheint, weil die App nicht digital signiert ist – das ist bei selbst verteilten Programmen normal.
3. Den Anweisungen folgen (keine Admin-Rechte nötig). Auf Wunsch legt das Setup ein **Desktop-Symbol** an; einen Startmenü-Eintrag gibt es immer.
4. Fertig – Zeitexa startet am Ende der Installation automatisch.

**Weg B – ZIP-Ordner (ohne Installation):** Im Lieferpaket liegt unter „Windows ZIP" die Datei `Zeitexa_Windows_v….zip`.

1. Die ZIP-Datei zuerst **komplett entpacken** (Rechtsklick → „Alle extrahieren…"). Nicht direkt aus dem ZIP-Fenster starten!
2. Im entpackten Ordner **„Zeitexa starten"** doppelklicken.
3. Im Ordner „App" liegen die Programmdateien – dort nichts löschen oder verschieben.

**Wo liegen die Daten?** Zeitexa speichert alles (Stundeneinträge, Benutzer, Einstellungen) in der Datei `zeitexa.sqlite` im **Dokumente-Ordner** des Windows-Benutzers – also außerhalb des Programms.

**Update auf eine neue Version:** Einfach das neue Setup ausführen (bzw. den neuen ZIP-Ordner verwenden). Die Daten bleiben erhalten, auch beim Deinstallieren wird die Datenbank nicht gelöscht.

### 1.2 Android-Handy

1. Die Datei **`Zeitexa_v….apk`** (Lieferpaket, Ordner „Android") aufs Handy übertragen – z. B. per USB-Kabel, E-Mail an sich selbst oder über einen Cloud-Speicher.
2. Die APK-Datei am Handy antippen (z. B. im Datei-Manager oder unter „Downloads").
3. Android fragt beim ersten Mal, ob Apps aus dieser Quelle installiert werden dürfen („**Unbekannte Apps installieren**"). Das **erlauben** – die Frage kommt, weil die App nicht aus dem Play Store stammt.
4. **Installieren** antippen, fertig. Zeitexa erscheint wie jede andere App im App-Menü.

**Update:** Die neue APK einfach über die alte installieren – Daten bleiben erhalten.

### 1.3 iPhone / iPad (Web-App)

Für das iPhone gibt es keine App aus dem App Store. Stattdessen läuft Zeitexa als **Web-App**, die sich wie eine echte App auf den Home-Bildschirm legen lässt.

1. Am iPhone **Safari** öffnen (wichtig: Safari, nicht Chrome).
2. Diese Adresse aufrufen: **https://hwgtechgrafik.github.io/zeitexa/**
3. Unten in der Mitte auf das **Teilen-Symbol** tippen (Quadrat mit Pfeil nach oben).
4. **„Zum Home-Bildschirm"** wählen und mit **„Hinzufügen"** bestätigen.
5. Zeitexa liegt jetzt als App-Symbol am Home-Bildschirm und startet ab sofort wie eine normale App – auch **ohne Internet**.

**Besonderheiten der Web-App** (gilt auch, wenn Zeitexa am PC im Browser genutzt wird):

- Die Daten liegen im **Browser-Speicher** des Geräts. Achtung: Wer in Safari „Verlauf und Websitedaten löschen" ausführt, löscht auch die Zeitexa-Daten. Deshalb den Monatsbericht regelmäßig versenden.
- **Kein automatischer Mail-Versand:** Der Monatsbericht wird über das **Teilen-Menü** weitergegeben (z. B. an die Mail-App).
- **Keine Datensicherung und keine Anmeldung per Fingerabdruck/Gesicht** – diese Funktionen gibt es nur in der Windows- und Android-Version.
- **Updates kommen automatisch:** Neue Versionen holt sich die App beim nächsten Öffnen mit Internetverbindung selbst (gegebenenfalls die App einmal schließen und neu öffnen).

---

## 2. Freischaltung und Ersteinrichtung (einmalig pro Gerät)

Beim allerersten Start führt Zeitexa durch zwei kurze Schritte:

### Schritt 1: Freischalten

Es erscheint der Bildschirm **„Zeitexa freischalten"**:

1. **Firmenname** eingeben – genau der Name, für den die Freischaltung ausgestellt ist (Groß-/Kleinschreibung und Leerzeichen spielen keine Rolle).
2. Dann entweder:
   - den **Freischaltcode** eintippen bzw. hineinkopieren (langer Buchstaben-/Zahlencode; Leerzeichen und Zeilenumbrüche stören nicht) und auf **„Code prüfen & freischalten"** tippen, **oder**
   - auf **„Lizenzdatei importieren"** tippen und die Lizenzdatei (`….zeitexalizenz.json`) auswählen, falls Sie eine bekommen haben.

Die Freischaltung gilt für alle Geräte Ihrer Firma – derselbe Code funktioniert auf jedem Gerät.

### Schritt 2: Einrichten

Danach erscheint **„Zeitexa einrichten"**:

1. **Adminpasswort** festlegen (mit Wiederholung, mindestens 4 Zeichen). Es schützt den Chef-Bereich.
   **Ganz wichtig: Dieses Passwort gut merken bzw. sicher notieren – es kann nachträglich nicht geändert werden!**
2. **Eigenes Benutzerprofil des Chefs** anlegen: Benutzername, Anzeigename und persönliches Passwort.
3. Auf **„Einrichten und starten"** tippen – Sie sind sofort angemeldet und landen in der Monatsansicht.

Alle weiteren Mitarbeiter legt der Chef anschließend im Chef-Bereich an (Abschnitt 5.1).

---

## 3. Anmeldung

- Beim Start meldet man sich mit **Benutzername und Passwort** an.
- **Erster Login:** Neue Mitarbeiter bekommen vom Chef ein Start-Passwort und müssen beim ersten Anmelden ein **eigenes neues Passwort festlegen**.
- **Anmeldung per Fingerabdruck/Gesicht** (nur Windows/Android): Wenn der Chef die biometrische Anmeldung erlaubt hat und man sie in den eigenen Einstellungen aktiviert hat, erscheint am Anmeldebildschirm ein Knopf **„Als ‚Name' anmelden"** – ein Fingertipp genügt.
- **„Neu hier? Registrieren":** Dieser Knopf erscheint nur, wenn der Chef die Selbst-Registrierung erlaubt hat. Damit können sich Mitarbeiter selbst ein Profil anlegen.
- **Abmelden:** oben rechts über das Menü (⋮) → „Abmelden".

---

## 4. Tägliche Bedienung (für Mitarbeiter)

### 4.1 Die Monatsansicht

Nach der Anmeldung sehen Sie den aktuellen Monat:

- **Übersichtskarte** oben:
  - **„Zeit – aktueller Monat":** Ist-Stunden, Soll-Stunden und Überstunden (grün = Plus, rot = Minus).
  - **„Konten"** mit Umschalter **Monat / Laufzeit**: Resturlaub in Tagen (bei getrennter Führung zwei Werte: „Resturlaub Mo–Do" und „Resturlaub Fr"), **Zeitausgleich** in Stunden (Plus oder Minus) und **Kranktage**. „Monat" zeigt nur den angezeigten Monat, „Laufzeit" den Gesamtstand.
- **Tagesliste:** eine Zeile pro Tag. Wochenenden und Feiertage sind farbig hervorgehoben, der heutige Tag ist markiert. Jede Zeile zeigt die Uhrzeiten, Pause und Ort (bzw. die Tagesart wie „Urlaub"), eine eventuelle Notiz sowie Ist/Soll und Überstunden des Tages.
- **Pfeile** links/rechts oben wechseln den Monat.
- **„Heute"-Knopf:** springt zurück zum aktuellen Monat und rollt die Liste zum heutigen Tag. Je nach Einstellung (siehe 4.4 bzw. 5.2) öffnet er zusätzlich gleich den heutigen Tageseintrag.

### 4.2 Einen Tag eintragen

Einfach die gewünschte Tageszeile **antippen** – es öffnet sich der Tageseintrag:

1. Oben die **Tagesart** wählen: **Arbeit, Urlaub, Krank, Feiertag, Zeitausgleich, Sonderurlaub** und – falls der Chef das Konto für Sie führt – **Firmenurlaub**. (Feiertage schlägt die App bei österreichischen gesetzlichen Feiertagen automatisch vor.)
2. Bei **Arbeit**:
   - **Ort** eintragen (z. B. die Baustelle). Zuletzt verwendete Orte erscheinen als Schnellauswahl zum Antippen.
   - **Beginn** und **Ende** über die Uhr einstellen.
   - **Pause** über die runde Pausen-Uhr einstellen (in 5-Minuten-Schritten).
   - Beginn, Ende und Pause sind mit Ihren Standardzeiten vorbelegt – meist muss man gar nichts ändern. Ist Ihr **Freitag kürzer** und sind eigene Freitagszeiten hinterlegt, verwendet die App am Freitag automatisch diese.
3. Bei allen anderen Tagesarten kann man über **„bis-Datum wählen"** gleich einen ganzen Zeitraum eintragen (z. B. zwei Wochen Urlaub) – Samstage und Sonntage werden automatisch übersprungen.
4. **Halbe und geteilte Urlaubstage:** Bei einem einzelnen Urlaubs-, Sonderurlaubs- oder Firmenurlaubstag steht im Feld **„… (Stunden an diesem Tag)"** zunächst Ihr volles Tagessoll. Tragen Sie **weniger** ein (z. B. **6,25**), erscheinen darunter zusätzlich Ort, Beginn, Ende und Pause – so lässt sich ein Tag sauber aufteilen: ein Teil Urlaub, der Rest gearbeitet. Ein halber Tag ist also einfach die halbe Stundenzahl. Das Urlaubskonto wird entsprechend anteilig belastet.
5. Bei **Sonderurlaub** zusätzlich den **Grund** wählen: Pflegefreistellung, Umzug, Hochzeit, Geburt, Todesfall oder Sonstiges (bei „Sonstiges" den Anlass in die Notiz schreiben). Sonderurlaub wird **gezählt, aber nicht vom Urlaubskonto abgezogen**.
6. Optional eine **Notiz** ergänzen (was/wie/wo/wer).
7. **Speichern.** Über **Löschen** lässt sich ein bestehender Eintrag wieder entfernen.

### 4.3 Monat senden / exportieren

Am Monatsende (oder wann immer nötig) den Monatsbericht an die Firma übergeben: Menü (⋮) → **„Monat exportieren/senden"**. Der Bericht enthält immer eine Excel-Liste, ein PDF und eine Datendatei für die Auswertung. Je nach Einrichtung stehen bis zu vier Wege zur Wahl:

- **„Per Mail senden (automatisch)":** verschickt den Bericht direkt an die Firmen-Mailadresse (nur wenn der Chef den Mailversand eingerichtet hat; nicht in der Web-App).
- **„Kopie an Mitarbeiter":** zusätzlicher Schalter – schickt Ihnen selbst die Excel-Liste an Ihre hinterlegte Mailadresse.
- **„Per Mail-App / Teilen weitergeben":** öffnet das normale Teilen-Menü des Geräts (z. B. Mail-App). Danach fragt Zeitexa nach, ob die Mail wirklich gesendet wurde.
- **„Nur als Dateien speichern":** legt die Dateien lokal ab (Windows: Ordner „Zeitexa-Exporte" in Dokumente; nicht in der Web-App).

**Automatik und Sende-Sperre** (je nach Chef-Einstellung):

- Ist der **automatische Versand** aktiv, verschickt Zeitexa den Vormonat beim ersten Start im neuen Monat von selbst und meldet das kurz.
- Ist die **Sende-Sperre** aktiv, erscheint am Monatsanfang ein Hinweisbalken „Vormonat noch nicht gesendet" mit dem Knopf **„Jetzt senden"**. Solange der Vormonat nicht versendet ist, lassen sich im neuen Monat keine Einträge anlegen.

### 4.4 Persönliche Einstellungen

Menü (⋮) → **„Einstellungen"**:

- **Passwort ändern** (aktuelles Passwort + neues Passwort mit Wiederholung).
- **„Anmeldung per Fingerabdruck/Gesicht"** ein-/ausschalten (nur Windows/Android, und nur wenn der Chef es erlaubt hat; beim Einschalten einmal per Fingerabdruck/Gesicht bestätigen).
- **„Heute-Knopf öffnet den Tageseintrag":** eigene Vorliebe einstellen – übersteuert die Vorgabe des Chefs.
- **Deine Sollstunden:** nur zur Ansicht (ändern kann sie nur der Chef).
- **Standardzeiten für neue Einträge** (Beginn/Ende/Pause) selbst anpassen – damit sind neue Arbeitstage gleich richtig vorbelegt.
- **„Freitag hat andere Zeiten":** Wenn Ihre Sollstunden Mo–Do und Freitag getrennt geführt werden, lässt sich hier ein eigener Freitag hinterlegen (z. B. 07:00–12:00 ohne Pause). Ausgeschaltet gilt am Freitag dieselbe Vorbelegung wie Mo–Do.

---

## 5. Der Chef-Bereich

Menü (⋮) → **„Chef-Bereich"** → **Adminpasswort** eingeben. Der Bereich hat drei Karteireiter: **Benutzer**, **Mail & Optionen** und **Auswertung**.

### 5.1 Reiter „Benutzer" – Mitarbeiter verwalten

**Mitarbeiter anlegen** (Knopf unten rechts):

- **Benutzername, Anzeigename** und ein **Start-Passwort** (der Mitarbeiter muss es beim ersten Login ändern).
- **E-Mail-Adresse des Mitarbeiters** (optional): dorthin geht auf Wunsch die Excel-Kopie des Monatsberichts.
- **Sollstunden:** Modus „Gleich Mo–Fr" oder „Mo–Do und Freitag getrennt", jeweils mit Stundenwerten (Kommazahlen möglich, z. B. 7,5).
- **Anfangsstand mit Stichtag:** Überstunden-Übertrag aus der Zeit vor Zeitexa.
- **„Freitags-Urlaub getrennt führen":** wenn eingeschaltet, führt Zeitexa zwei Urlaubskonten (Mo–Do und Freitag) – passend zur getrennten Sollzeit.
- **Resturlaub-Anfangsstand** in Tagen (halbe Tage mit Komma, z. B. 12,5; bei getrennter Führung je Konto).
- **„Firmenurlaub führen":** eigenes Konto für internen Zusatzurlaub der Firma – z. B. eine Extra-Woche, die nicht jedem zusteht. Ist der Schalter an, erscheint das Feld **„Firmenurlaub-Kontingent (Tage)"**. Dieses Konto **verfällt nicht**; wenn im nächsten Jahr wieder Tage dazukommen, erhöhen Sie den Wert einfach selbst (aus 5 werden dann 10). Der Mitarbeiter bucht davon über die Tagesart **Firmenurlaub** ab – das normale Urlaubskonto bleibt unberührt.
- **Zeitausgleich-Anfangsstand** als Dezimalzahl in Stunden, z. B. **43,35 = 43 Stunden 21 Minuten** (Komma oder Punkt), mit **+/−-Umschalter** für Guthaben oder Schulden.
- **Standardzeiten** (Beginn/Ende/Pause) als Vorbelegung für neue Einträge; bei getrenntem Freitags-Soll zusätzlich der Schalter **„Freitag hat andere Zeiten"** für einen kürzeren Freitag.

**Pro Mitarbeiter** gibt es außerdem im Menü der Zeile:

- **Profil bearbeiten** – alle obigen Felder nachträglich korrigierbar.
- **Passwort zurücksetzen** – neues Start-Passwort vergeben (Wechsel beim nächsten Login erzwungen). So hilft man Mitarbeitern, die ihr Passwort vergessen haben.
- **Löschen** – entfernt den Benutzer **mitsamt allen Einträgen** auf diesem Gerät (Warnung wird angezeigt).

**Benutzer übertragen** (Karte oben im Reiter) – damit Sie die Mitarbeiter **nur einmal anlegen** und auf allen Geräten nutzen können (funktioniert auf **allen** Geräten, auch am iPhone):

- **„Benutzer exportieren…":** speichert alle Mitarbeiter mit ihrem vollständigen Profil und (verschlüsseltem) Passwort in einer Datei – seit Version 1.3.0 zusammen mit dem **Adminpasswort**. Am Windows-PC per „Speichern unter", am Handy/iPhone über das Teilen-Menü. **Die Datei enthält Zugangsdaten – vertraulich behandeln.**
- **„Benutzer importieren…":** spielt diese Datei auf einem anderen Gerät ein. **Neue** Mitarbeiter werden angelegt, sodass sich alle sofort mit demselben Passwort anmelden können. **Bereits vorhandene** Mitarbeiter behalten ihr Passwort, ihre bisherigen Einträge und ihre Anfangsstände – nur die Stundeneinteilung (Sollstunden, Standardzeiten) und die E-Mail-Adresse werden aus der Datei aktualisiert. Das Adminpasswort dieses Geräts wird dabei **nie** überschrieben.

So richten Sie z. B. alle Mitarbeiter an Ihrem Rechner ein und verteilen die Datei anschließend an die einzelnen Geräte, statt überall alles neu einzutippen.

**Neues Gerät ohne Tipparbeit einrichten (ab 1.3.0):** Auf einem frischen Gerät genügt es, nach der Lizenz-Freischaltung im Einrichtungs-Bildschirm auf **„Benutzerdatei übernehmen…"** zu tippen und die exportierte Datei zu wählen. Weil die Datei auch das Adminpasswort mitbringt, ist die Einrichtung damit **fertig** – es erscheint sofort der Anmeldebildschirm, und Sie melden sich mit Ihrem gewohnten Passwort an. Es muss kein einziges Feld mehr ausgefüllt werden. (Bei einer älteren Datei aus Version 1.2.5 werden die Mitarbeiter zwar übernommen, das Adminpasswort ist dann aber noch einmal zu vergeben.)

### 5.2 Reiter „Mail & Optionen"

**Mailversand** (nur Windows/Android; in der Web-App erscheint stattdessen ein Hinweis):

- **Ziel-Mailadresse** (dorthin gehen die Monatsberichte, z. B. die Chef-Adresse).
- Zugangsdaten des Mail-Anbieters: **SMTP-Server, Port** (465 = SSL), **SSL-Schalter, SMTP-Benutzer, SMTP-Passwort**.
- **„Testmail senden"** prüft die Einstellungen sofort.
- **„Automatischer Versand am Monatsanfang":** wenn aktiv, verschickt jedes Gerät den Vormonat selbstständig.

**Regeln:**

- **„Sende-Sperre am Monatswechsel":** neue Monatseinträge erst nach Versand des Vormonats (empfehlenswert, wenn Mitarbeiter die Web-App nutzen und selbst senden müssen).
- **„Heute-Knopf öffnet den Tageseintrag":** Vorgabe für alle Mitarbeiter (jeder kann sie in den eigenen Einstellungen übersteuern).
- **„Selbst-Registrierung erlauben":** Mitarbeiter dürfen sich am Anmeldebildschirm selbst ein Profil anlegen.
- **„Biometrische Anmeldung erlauben":** schaltet die Anmeldung per Fingerabdruck/Gesicht firmenweit frei.

Nach Änderungen unten auf **Speichern** tippen.

**Datensicherung** (nur Windows/Android):

- **„Sicherung erstellen…":** speichert die komplette Datenbank (alle Benutzer, Einträge, Einstellungen und die Freischaltung) als eine Datei `Zeitexa_Sicherung_<Datum>.zeitexadb` an einen wählbaren Ort. Regelmäßig machen – z. B. auf einen USB-Stick!
- **„Sicherung wiederherstellen…":** spielt eine Sicherungsdatei zurück. **Achtung:** Ersetzt alle aktuellen Daten auf dem Gerät (Warnhinweis); danach startet die App neu. So zieht man auch auf einen neuen PC um.

**Lizenz:**

- **„Lizenzdatei importieren…":** spielt eine neue Lizenzdatei vom Entwickler ein (z. B. eine aktualisierte Lizenz). Die bestehende Freischaltung und alle Daten bleiben erhalten.

### 5.3 Reiter „Auswertung" – Monatsberichte der Mitarbeiter

Hier führt der Chef die Berichte aller Mitarbeiter zusammen (auch von fremden Geräten):

1. **„JSON-Dateien importieren":** die Datendateien auswählen, die die Mitarbeiter per Mail geschickt haben (Mehrfachauswahl möglich).
2. Zeitexa zeigt eine **Karte pro Mitarbeiter** mit den Überstunden gesamt – zum Aufklappen. Beim Aufklappen erscheinen:
   - ein **Balkendiagramm der Überstunden je Monat** (grün = Plus, rot = Minus),
   - ein **Ist/Soll-Diagramm**: ein Balken je Monat für die geleisteten Stunden, darüber eine waagrechte Marke für das Soll – wer darüber liegt, hat einen grünen Überstand, wer darunter bleibt, eine rote Lücke,
   - und darunter eine **kompakte Tabelle mit genau einer Zeile je Monat**: Monat, Ist, Soll, +/−, Urlaub, Sonderurlaub, Firmenurlaub, Krank, Zeitausgleich, Feiertage. Auf schmalen Bildschirmen lässt sich die Tabelle seitlich schieben, die Monatsspalte bleibt dabei stehen. Ein Strich („–") heißt: in diesem Monat gab es davon nichts. **Halbe und geteilte Urlaubstage zählen korrekt mit Nachkommastelle** (ein halber Tag ist 0,5, nicht mehr 1).
3. **Ein Mitarbeiter an mehreren Geräten:** Schreibt dieselbe Person (gleicher Benutzername) auf mehreren Geräten Stunden, werden die importierten Berichte **taggenau zusammengeführt** – die Tage von allen Geräten ergeben zusammen den Monat, es geht nichts verloren. Schickt jemand denselben Monat korrigiert erneut, wird nur der geänderte Tag ersetzt.
4. **„Auswertung exportieren":** erzeugt eine Gesamtübersicht als **Excel und PDF**. Am Windows-PC per „Speichern unter", auf Handy/Tablet über das Teilen-Menü.

---

## 6. Firmen-Logo und Farben (versteckter Bereich)

Zeitexa kann mit dem eigenen Firmenauftritt versehen werden – Logo und Akzentfarbe erscheinen in der App und auf den Excel-/PDF-Berichten. Dieser Bereich ist bewusst versteckt und durch ein eigenes Passwort geschützt:

1. Menü (⋮) → **„Über Zeitexa"**.
2. **7-mal auf die Versionsnummer tippen.**
3. Das **Entwickler-Passwort** eingeben (steht in den Lizenzunterlagen vom Entwickler).

Im Bereich lassen sich einstellen:

- **Firmendaten** (Name, Adresse, Telefon, E-Mail – erscheinen auf den Berichten).
- **Logo** wählen, ändern oder entfernen.
- **Akzentfarbe** (8 Farben zur Auswahl) – färbt die ganze App und die Berichte.
- **Vorlage für den Mail-Betreff** mit Platzhaltern wie {Mitarbeiter}, {Monat}, {Jahr}, {Firma}.
- **„Lizenzdatei exportieren":** speichert die Lizenz dieses Geräts als Datei – praktisch, um ein weiteres Gerät der Firma per Datei-Import freizuschalten (Abschnitt 2, Schritt 1).

---

## 7. Häufige Fragen

**Wo sind meine Daten?**
Immer nur lokal am jeweiligen Gerät. Windows: `zeitexa.sqlite` im Dokumente-Ordner. Android: im App-Speicher. iPhone/Web-App: im Browser-Speicher.

**Ich habe mein Passwort vergessen.**
Der Chef setzt es im Chef-Bereich zurück (Reiter „Benutzer" → „Passwort zurücksetzen"). **Ausnahme Adminpasswort:** Das Passwort für den Chef-Bereich kann **nicht** geändert oder zurückgesetzt werden – deshalb bei der Einrichtung gut aufbewahren.

**Neuer PC / neues Gerät – wie ziehe ich um?**
Windows/Android: Im Chef-Bereich eine **Datensicherung erstellen**, am neuen Gerät Zeitexa installieren, freischalten und die **Sicherung wiederherstellen** – alles ist wieder da. Am iPhone gibt es keine Sicherung; dort schützt der regelmäßige Monatsversand vor Datenverlust.

**Ich habe ein neues Handy – sind die Daten weg?**
Die Daten bleiben am alten Gerät. Android: vorher eine Datensicherung erstellen und am neuen Handy wiederherstellen. Generell gilt: Monat für Monat den Bericht verschicken, dann ist nichts verloren.

**Wie richte ich viele Geräte ein, ohne die Mitarbeiter überall neu anzulegen?**
Legen Sie alle Mitarbeiter einmal an einem Gerät an und exportieren Sie sie im Chef-Bereich (Reiter „Benutzer" → **„Benutzer exportieren…"**). Auf jedem weiteren Gerät nach der Freischaltung und der kurzen Ersteinrichtung die Datei über **„Benutzer importieren…"** einspielen – schon können sich alle mit demselben Passwort anmelden (Abschnitt 5.1). Das funktioniert auch am iPhone.

**Der Freischaltcode wird nicht angenommen.**
Prüfen, ob der **Firmenname** exakt zur Firma gehört, für die der Code ausgestellt wurde (Tippfehler?). Der Code selbst darf Leerzeichen und Zeilenumbrüche enthalten – das stört nicht.

**Die App zeigt eine alte Versionsnummer (iPhone/Web-App).**
Das ist der Browser-Zwischenspeicher. Die App einmal komplett schließen und mit Internetverbindung neu öffnen – sie holt sich die neue Version dann selbst.

**Windows meldet einen Virus-/SmartScreen-Hinweis.**
Siehe Abschnitt 1.1 – „Weitere Informationen" → „Trotzdem ausführen". Die Warnung kommt nur, weil die App nicht digital signiert ist.

**Verfällt mein Zeitausgleich am Jahresende?**
Nein. Das Zeitausgleich-Konto läuft unbegrenzt weiter (Anfangsstand plus alle Überstunden) – es verfällt nichts.

**Woher kommen die Feiertage?**
Die österreichischen gesetzlichen Feiertage sind fest eingebaut, werden in der Liste farbig markiert und beim Eintragen automatisch als „Feiertag" vorgeschlagen.
