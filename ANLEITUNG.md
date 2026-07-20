# Zeitexa – Installations- und Bedienungsanleitung

Zeitexa ist eine Stundenerfassung für **eine Person**. Sie funktioniert komplett **offline**: Alle Daten bleiben auf dem Gerät – es gibt keinen Server und kein Benutzerkonto im Internet. Internet wird nur für den optionalen Mail-Versand des Monatsberichts gebraucht.

Es gibt keine Anmeldung, keinen Chef-Bereich und keine Benutzerverwaltung. Alle Einstellungen treffen Sie selbst.

| Abschnitt | Inhalt |
|---|---|
| 1 – Installation | Windows, Android, iPhone |
| 2 – Freischaltung und erster Start | einmalig pro Gerät |
| 3 – Tägliche Bedienung | Monatsansicht, Tage eintragen, Monat weitergeben |
| 4 – Verwaltung | Profil, Optionen, Auswertung |
| 5 – Häufige Fragen | |

**Wichtig – Freischaltung:** Beim ersten Start muss die App einmalig mit einem **Freischaltcode** oder einer **Lizenzdatei** freigeschaltet werden. Beides bekommen Sie vom Entwickler; die Lizenz läuft auf Ihren Namen. Ohne Freischaltung lässt sich die App nicht verwenden.

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

**Wo liegen die Daten?** Zeitexa speichert alles (Stundeneinträge, Einstellungen) in der Datei `zeitexa.sqlite` im **Dokumente-Ordner** des Windows-Benutzers – also außerhalb des Programms.

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

- Die Daten liegen im **Browser-Speicher** des Geräts. Achtung: Wer in Safari „Verlauf und Websitedaten löschen" ausführt, löscht auch die Zeitexa-Daten. Deshalb regelmäßig eine **Sicherung erstellen** (Verwaltung → Optionen → Datensicherung) und den Monatsbericht versenden.
- **Kein automatischer Mail-Versand:** Der Monatsbericht wird über das **Teilen-Menü** weitergegeben (z. B. an die Mail-App). Auch die Sicherungsdatei geht über das Teilen-Menü hinaus (z. B. „In Dateien sichern" oder per Mail an sich selbst).
- **Kein Entsperren per Fingerabdruck** – diese Funktion gibt es nur in der Windows- und Android-Version.
- **Updates kommen automatisch:** Neue Versionen holt sich die App beim nächsten Öffnen mit Internetverbindung selbst (gegebenenfalls die App einmal schließen und neu öffnen).

---

## 2. Freischaltung und erster Start

Beim allerersten Start führt Zeitexa durch zwei kurze Schritte.

### Schritt 1: Freischalten

Es erscheint der Bildschirm **„Zeitexa freischalten"**. Zwei Wege:

- **Lizenzdatei (empfohlen):** auf **„Lizenzdatei importieren"** tippen und die Datei (`….zeitexalizenz.json`) auswählen – fertig. Ihr Name steckt bereits in der Datei.
- **Freischaltcode:** zuerst den **Namen des Lizenznehmers** eingeben – genau der Name, für den die Freischaltung ausgestellt ist (Groß-/Kleinschreibung und Leerzeichen spielen keine Rolle) – und dann den Code eintippen bzw. hineinkopieren (langer Buchstaben-/Zahlencode; Leerzeichen und Zeilenumbrüche stören nicht). Auf **„Code prüfen & freischalten"** tippen.

Dieselbe Freischaltung gilt für alle Ihre Geräte (PC, Handy, iPhone).

### Schritt 2: Willkommen

Danach erscheint **„Willkommen bei Zeitexa"** mit dem Namen, für den die Lizenz gilt. Dieser Name steht später auf allen Berichten; er kommt aus der Lizenz und lässt sich in der App nicht ändern. Auf **„Los geht's"** tippen, fertig.

**Danach unbedingt einmal die Verwaltung öffnen:** Zeitexa rechnet zunächst mit Vorgabewerten (8 Stunden Mo–Do, 5 Stunden Freitag, Urlaubsstände auf 0). Solange Sie diese Werte nicht bestätigt haben, steht in der Monatsansicht ein Hinweisbalken mit dem Knopf **„Jetzt einstellen"**. Ein Klick darauf führt direkt an die richtige Stelle (siehe Abschnitt 4.1). Der Balken verschwindet, sobald Sie dort einmal gespeichert haben.

Die Werte lassen sich jederzeit ändern – Zeitexa rechnet immer mit den aktuellen Einstellungen, auch rückwirkend.

---

## 3. Tägliche Bedienung

### 3.1 Die Monatsansicht

Nach dem Start sehen Sie den aktuellen Monat:

- **Übersichtskarte** oben:
  - **„Zeit – aktueller Monat":** Ist-Stunden, Soll-Stunden und Überstunden (grün = Plus, rot = Minus).
  - **„Konten"** mit Umschalter **Monat / Laufzeit**: Resturlaub in Tagen (bei getrennter Führung zwei Werte: „Resturlaub Mo–Do" und „Resturlaub Fr"), **Zeitausgleich** in Stunden (Plus oder Minus) und **Kranktage**. „Monat" zeigt nur den angezeigten Monat, „Laufzeit" den Gesamtstand.
- **Tagesliste:** eine Zeile pro Tag. Wochenenden und Feiertage sind farbig hervorgehoben, der heutige Tag ist markiert. Jede Zeile zeigt die Uhrzeiten, Pause und Ort (bzw. die Tagesart wie „Urlaub"), eine eventuelle Notiz sowie Ist/Soll und Überstunden des Tages.
- **Pfeile** links/rechts oben wechseln den Monat.
- **„Heute"-Knopf:** springt zurück zum aktuellen Monat und rollt die Liste zum heutigen Tag. Je nach Einstellung (Abschnitt 4.2) öffnet er zusätzlich gleich den heutigen Tageseintrag.

### 3.2 Einen Tag eintragen

Einfach die gewünschte Tageszeile **antippen** – es öffnet sich der Tageseintrag:

1. Oben die **Tagesart** wählen: **Arbeit, Urlaub, Krank, Feiertag, Zeitausgleich, Sonderurlaub** und – falls Sie das Konto führen – **Zusatzurlaub**. (Feiertage schlägt die App bei österreichischen gesetzlichen Feiertagen automatisch vor.)
2. Bei **Arbeit**:
   - **Ort** eintragen (z. B. die Baustelle). Zuletzt verwendete Orte erscheinen als Schnellauswahl zum Antippen.
   - **Beginn** und **Ende** über die Uhr einstellen. Mit **„Jetzt Beginn"** bzw. **„Jetzt Ende"** übernimmt die App die aktuelle Uhrzeit mit einem Tipp – praktisch, wenn man direkt beim Kommen oder Gehen stempelt.
   - **Pause** über die runde Pausen-Uhr einstellen (in 5-Minuten-Schritten).
   - Beginn, Ende und Pause sind mit Ihren Standardzeiten vorbelegt – meist muss man gar nichts ändern. Ist Ihr **Freitag kürzer** und sind eigene Freitagszeiten hinterlegt, verwendet die App am Freitag automatisch diese.
3. Bei allen anderen Tagesarten kann man über **„bis-Datum wählen"** gleich einen ganzen Zeitraum eintragen (z. B. zwei Wochen Urlaub) – Samstage und Sonntage werden automatisch übersprungen.
4. **Halbe und geteilte Urlaubstage:** Bei einem einzelnen Urlaubs-, Sonderurlaubs- oder Zusatzurlaubstag steht im Feld **„… (Stunden an diesem Tag)"** zunächst Ihr volles Tagessoll. Tragen Sie **weniger** ein (z. B. **6,25**), erscheinen darunter zusätzlich Ort, Beginn, Ende und Pause – so lässt sich ein Tag sauber aufteilen: ein Teil Urlaub, der Rest gearbeitet. Ein halber Tag ist also einfach die halbe Stundenzahl. Das Urlaubskonto wird entsprechend anteilig belastet.
5. Bei **Sonderurlaub** zusätzlich den **Grund** wählen: Pflegefreistellung, Umzug, Hochzeit, Geburt, Todesfall oder Sonstiges (bei „Sonstiges" den Anlass in die Notiz schreiben). Sonderurlaub wird **gezählt, aber nicht vom Urlaubskonto abgezogen**.
6. Optional eine **Notiz** ergänzen (was/wie/wo/wer).
7. **Speichern.** Über **Löschen** lässt sich ein bestehender Eintrag wieder entfernen.

### 3.3 Monat weitergeben

Menü (⋮) → **„Monat exportieren/senden"**. Der Bericht enthält immer eine Excel-Liste, ein PDF und eine Datendatei. Je nach Einrichtung stehen bis zu drei Wege zur Wahl:

- **„Per Mail senden (automatisch)":** verschickt den Bericht direkt an den hinterlegten Empfänger (nur wenn Sie den Mailversand eingerichtet haben; nicht in der Web-App).
- **„Per Mail-App / Teilen weitergeben":** öffnet das normale Teilen-Menü des Geräts (z. B. Mail-App).
- **„Nur als Dateien speichern":** legt die Dateien lokal ab (Windows: Ordner „Zeitexa-Exporte" in Dokumente; nicht in der Web-App).

Ist der **automatische Versand** eingeschaltet, verschickt Zeitexa den Vormonat beim ersten Start im neuen Monat von selbst und meldet das kurz.

---

## 4. Verwaltung

Menü (⋮) → **„Verwaltung"**. Drei Reiter:

### 4.1 Reiter „Mein Profil"

Hier stehen alle Werte, mit denen Zeitexa rechnet:

- **Ihr Name (aus der Lizenz):** wird nur angezeigt – er ist an die Lizenz gebunden und lässt sich nur über eine neue Lizenzdatei des Entwicklers ändern. Dazu Ihre **E-Mail-Adresse** (für die eigene Kopie beim Mail-Export).
- **Briefkopf der Berichte:** Adresse, Telefon und E-Mail, die unter Ihrem Namen im Kopf der PDF-Berichte erscheinen. Leere Felder werden weggelassen.
- **Sollstunden:** entweder gleich für alle Tage (Mo–Fr) oder **Mo–Do und Freitag getrennt**.
- **Anfangsstand:** Der **Stichtag** ist der Tag, ab dem Zeitexa mitrechnet. Tragen Sie hier ein, wie viel Resturlaub und wie viele Plus-/Minusstunden Sie an diesem Tag hatten – alles Weitere schreibt die App selbst fort.
  - **„Freitags-Urlaub getrennt führen":** eigenes Urlaubskonto für Freitage.
  - **„Zusatzurlaub führen":** eigenes Konto für zusätzlichen Urlaub (z. B. eine Extra-Woche). Verfällt nicht; den Stand erhöhen Sie jährlich selbst.
  - **Zeitausgleich-Anfangsstand:** Dezimalstunden mit **+/−**-Umschalter (z. B. 43,35 oder −5).
- **Standardzeiten** für neue Arbeitstage (Beginn, Ende, Pause), auf Wunsch mit eigenen **Freitagszeiten**.

Nicht vergessen: unten auf **„Speichern"**. Damit verschwindet auch der Hinweisbalken aus Abschnitt 2.

### 4.2 Reiter „Optionen"

- **Mailversand:** Empfänger der Monatsberichte (z. B. Auftraggeber, Steuerberater oder die eigene Adresse), der **Betreff der Export-Mails** (mit Platzhaltern wie {Monat} und {Jahr}) sowie die Zugangsdaten Ihres Postausgangsservers (SMTP-Server, Port, Benutzer, Passwort). Mit **„Testmail senden"** lässt sich das sofort prüfen. Optional: **automatischer Versand am Monatsanfang**. Mit **„Sicherung an die Export-Mail anhängen"** bekommt jede Monats-Mail (auch die automatische) zusätzlich eine komplette Datensicherung als Anhang – so liegt jeden Monat ein aktueller Stand im Postfach, ohne dass Sie daran denken müssen. Standardmäßig ist der Schalter aus.
- **Bedienung:** „Heute-Knopf öffnet den Tageseintrag".
- **Sicherheit – App-Sperre:** Standardmäßig **aus**. Eingeschaltet fragt Zeitexa beim Start nach einem Passwort, das Sie selbst vergeben. **Dieses Passwort lässt sich nicht wiederherstellen – notieren Sie es.** Zusätzlich kann (Windows/Android) das **Entsperren per Fingerabdruck** aktiviert werden. Hinweis: Das Gerät unterscheidet keine Personen – jeder dort hinterlegte Fingerabdruck kann entsperren.
- **Darstellung:** eine **Akzentfarbe** wählen. Sie erscheint in der App und auf dem PDF-Bericht.
- **Datensicherung:** **„Sicherung erstellen…"** schreibt alle Daten in eine Datei `Zeitexa_Sicherung_JJJJ-MM-TT.zeitexadb`, **„Sicherung wiederherstellen…"** spielt sie zurück. Das funktioniert auf **allen Geräten** – auch in der Web-App (dort geht die Datei über das Teilen-Menü hinaus bzw. wird heruntergeladen, z. B. „In Dateien sichern") – und die Datei lässt sich **geräteübergreifend** einspielen, etwa vom alten Handy am neuen oder vom PC am iPhone. Beim Wiederherstellen wird der gesamte Bestand ersetzt. Sicherungen anderer Programme (etwa der Firmenversion Zeitrax) weist Zeitexa ab. Hinweis: Sicherungen aus Zeitexa-Versionen **vor 1.3** lassen sich nur in der Windows- und Android-App einspielen, nicht in der Web-App – bei Bedarf einfach dort eine neue Sicherung erstellen.
- **Lizenz:** zeigt, für wen die App freigeschaltet ist. **„Lizenzdatei importieren…"** spielt eine neue Datei des Entwicklers ein (z. B. bei einer Namenskorrektur – der neue Name gilt dann sofort überall). **„Lizenzdatei exportieren…"** speichert Ihre Lizenz als Datei, um sie auf einem anderen Gerät zu importieren.

### 4.3 Reiter „Auswertung"

Die Auswertung entsteht **automatisch** aus Ihren Einträgen – nichts importieren, nichts anstoßen: Jeder erfasste Monat erscheint hier von selbst als eine Zeile mit Ist, Soll, Überstunden, Urlaub, Sonder- und Zusatzurlaub, Krank, Zeitausgleich und Feiertagen, dazu zwei Diagramme (Überstunden je Monat sowie Ist gegen Soll). Über **„Auswertung exportieren"** lässt sich das Ganze als Excel- und PDF-Datei ausgeben – praktisch für den Jahresabschluss oder den Steuerberater.

---

## 5. Häufige Fragen

**Ich habe mein App-Sperre-Passwort vergessen.**
Es lässt sich nicht zurücksetzen – es ist verschlüsselt gespeichert. Ohne Sicherung hilft nur eine Neuinstallation, dabei gehen die Daten verloren. Deshalb: Passwort notieren und regelmäßig eine Sicherung erstellen.

**Mein Name ist in der Lizenz falsch geschrieben (oder hat sich geändert).**
Melden Sie sich beim Entwickler – er stellt eine korrigierte Lizenzdatei aus. Diese unter Verwaltung → Optionen → **„Lizenzdatei importieren…"** einspielen; der neue Name gilt sofort überall (auch auf den Berichten).

**Kann ich Zeitexa auf mehreren Geräten nutzen?**
Ja. Am einfachsten unter Verwaltung → Optionen die **Lizenzdatei exportieren** und am neuen Gerät importieren (oder dort denselben Freischaltcode eingeben). Die Geräte gleichen sich aber **nicht** miteinander ab – jedes führt seinen eigenen Bestand. Um komplett umzuziehen (z. B. auf ein neues Handy), verwenden Sie „Sicherung erstellen" und spielen die Datei am neuen Gerät ein – das geht auf allen Geräten, auch in der Web-App am iPhone.

**Stimmen die Zahlen auch rückwirkend, wenn ich meine Sollstunden später ändere?**
Ja. Zeitexa rechnet immer mit den aktuellen Einstellungen und schreibt die Konten ab dem Stichtag fort.

**Werden Feiertage automatisch berücksichtigt?**
Die österreichischen gesetzlichen Feiertage schlägt die App beim Eintragen vor.

**Wo bleiben meine Daten?**
Ausschließlich auf Ihrem Gerät. Es gibt keinen Server, keine Anmeldung und keine Übertragung – außer wenn Sie selbst einen Monatsbericht versenden.
