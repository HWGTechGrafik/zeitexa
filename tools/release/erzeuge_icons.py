# -*- coding: utf-8 -*-
"""Erzeugt alle Zeitexa-Appsymbole aus einer einzigen Vorlage.

Aufruf (aus dem Projektverzeichnis):
    python tools/release/erzeuge_icons.py

Motiv: abgerundetes Quadrat mit Farbverlauf, darin eine weisse Sanduhr mit
bernsteinfarbenem "Sand". Bewusst eine einfache, gut erkennbare Silhouette -
das Symbol muss auch als 16x16-Kachel in der Taskleiste lesbar bleiben.

Ergebnis (ueberschreibt die bisherigen Flutter-Standardsymbole):
    assets/zeitexa_logo.png               (in der App: Freischalt-/Willkommensbildschirm)
    web/icons/Icon-{192,512}.png, Icon-maskable-{192,512}.png, web/favicon.png
    windows/runner/resources/app_icon.ico
    tools/lizenz_gui/windows/runner/resources/app_icon.ico
    android/app/src/main/res/mipmap-*/ic_launcher.png
    ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png  (ohne Alphakanal)
    ios/Runner/Assets.xcassets/LaunchImage.imageset/*.png
    tools/release/zeitexa_icon_1024.png   (Vorlage zum Ersetzen durch eigenes Motiv)

Nach einem Lauf muss noch gebaut werden, damit die Symbole in den Binaries
landen (Windows/Android/Web); die iOS-Dateien sind buildunabhaengig.
"""

import json
import os

from PIL import Image, ImageDraw

BASIS = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Farbverlauf des Hintergrunds (oben -> unten) und Sandfarbe.
OBEN = (0, 150, 136)     # Petrol
UNTEN = (0, 77, 96)      # dunkles Blaugruen
SAND = (255, 179, 0)     # Bernstein
WEISS = (255, 255, 255)

KANTE = 1024             # Arbeitsgroesse, danach wird herunterskaliert


def verlauf(groesse):
    """Senkrechter Farbverlauf als Bild."""
    bild = Image.new("RGB", (1, groesse))
    for y in range(groesse):
        t = y / (groesse - 1)
        bild.putpixel((0, y), tuple(
            round(OBEN[i] + (UNTEN[i] - OBEN[i]) * t) for i in range(3)))
    return bild.resize((groesse, groesse))


def sanduhr(zeichner, kante, farbe_glas, farbe_sand):
    """Zeichnet die Sanduhr mittig in ein Quadrat der Groesse [kante].

    Aufbau: weisse Silhouette aus zwei Dreiecken plus Deckel, darin der
    Sand als bernsteinfarbene Flaeche. Bewusst massiv statt als duenne
    Kontur - eine Umrisszeichnung verschwindet in 16x16 zu Matsch.
    """
    m = kante / 2
    deckel = kante * 0.30          # halbe Breite der Deckel
    glas = kante * 0.255           # halbe Breite des Glaskoerpers
    hoehe = kante * 0.29           # halbe Hoehe des Koerpers
    dicke = round(kante * 0.05)
    taille = kante * 0.022

    oben = m - hoehe
    unten = m + hoehe

    # Glaskoerper (weiss), oben und unten je ein Dreieck zur Taille hin
    zeichner.polygon(
        [(m - glas, oben), (m + glas, oben),
         (m + taille, m), (m - taille, m)], fill=farbe_glas)
    zeichner.polygon(
        [(m - glas, unten), (m + glas, unten),
         (m + taille, m), (m - taille, m)], fill=farbe_glas)

    # Sand innerhalb des Glases: oben der Rest, unten der Kegel.
    rand = kante * 0.035
    sand_oben = oben + rand
    zeichner.polygon(
        [(m - glas * 0.74, sand_oben), (m + glas * 0.74, sand_oben),
         (m + taille * 0.55, m - rand * 0.5),
         (m - taille * 0.55, m - rand * 0.5)], fill=farbe_sand)
    kegel = hoehe * 0.55
    zeichner.polygon(
        [(m - glas * 0.78, unten - rand), (m + glas * 0.78, unten - rand),
         (m, unten - kegel)], fill=farbe_sand)
    # Rieselnder Sandstrahl
    zeichner.rectangle(
        [m - kante * 0.011, m, m + kante * 0.011, unten - kegel * 0.9],
        fill=farbe_sand)

    # Deckel oben und unten (zuletzt, damit sie sauber abschliessen)
    for y in (oben - dicke * 0.5, unten - dicke * 0.5):
        zeichner.rounded_rectangle(
            [m - deckel, y, m + deckel, y + dicke],
            radius=dicke / 2, fill=farbe_glas)


def vorlage():
    """Das Symbol in Arbeitsgroesse, mit abgerundeten Ecken (RGBA)."""
    bild = verlauf(KANTE).convert("RGBA")
    zeichner = ImageDraw.Draw(bild)
    sanduhr(zeichner, KANTE, WEISS, SAND)

    maske = Image.new("L", (KANTE, KANTE), 0)
    ImageDraw.Draw(maske).rounded_rectangle(
        [0, 0, KANTE - 1, KANTE - 1], radius=round(KANTE * 0.22), fill=255)
    bild.putalpha(maske)
    return bild


def vollflaechig():
    """Variante ohne runde Ecken - fuer maskable-Icons (Android/PWA), die das
    System selbst zuschneidet. Motiv etwas kleiner, damit beim Zuschnitt
    nichts abgeschnitten wird."""
    bild = verlauf(KANTE).convert("RGBA")
    innen = Image.new("RGBA", (KANTE, KANTE), (0, 0, 0, 0))
    zeichner = ImageDraw.Draw(innen)
    sanduhr(zeichner, KANTE, WEISS, SAND)
    innen = innen.resize((round(KANTE * 0.66), round(KANTE * 0.66)),
                         Image.LANCZOS)
    versatz = round((KANTE - innen.width) / 2)
    bild.alpha_composite(innen, (versatz, versatz))
    return bild


def speichere(bild, pfad, groesse):
    ziel = os.path.join(BASIS, pfad)
    os.makedirs(os.path.dirname(ziel), exist_ok=True)
    bild.resize((groesse, groesse), Image.LANCZOS).save(ziel)
    print("  ", pfad, f"{groesse}x{groesse}")


def ohne_transparenz(bild):
    """Legt [bild] auf weissen Grund. iOS-Appsymbole duerfen keinen
    Alphakanal haben - Xcode weist solche Dateien zurueck."""
    grund = Image.new("RGB", bild.size, (255, 255, 255))
    grund.paste(bild, mask=bild.split()[3] if bild.mode == "RGBA" else None)
    return grund


def ios_symbole(motiv):
    """Erzeugt alle in AppIcon.appiconset/Contents.json genannten Groessen.

    Die Liste wird bewusst aus Contents.json gelesen statt fest verdrahtet:
    So bleiben Datei und Erwartung auch dann beieinander, wenn Flutter den
    Satz einmal aendert.
    """
    ordner = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    with open(os.path.join(BASIS, ordner, "Contents.json"),
              encoding="utf-8") as datei:
        eintraege = json.load(datei)["images"]

    geschrieben = set()
    for eintrag in eintraege:
        name = eintrag.get("filename")
        if not name or name in geschrieben:
            continue
        kante = float(eintrag["size"].split("x")[0])
        faktor = float(eintrag["scale"].rstrip("x"))
        speichere(motiv, f"{ordner}/{name}", round(kante * faktor))
        geschrieben.add(name)

    # Startbild: Motiv mittig auf weissem Grund, wie es Flutter anlegt.
    for name, kante in [("LaunchImage.png", 128),
                        ("LaunchImage@2x.png", 256),
                        ("LaunchImage@3x.png", 384)]:
        bild = Image.new("RGB", (kante, kante), (255, 255, 255))
        marke = motiv.resize((round(kante * 0.6), round(kante * 0.6)),
                             Image.LANCZOS)
        versatz = round((kante - marke.width) / 2)
        bild.paste(marke, (versatz, versatz))
        ziel = os.path.join(
            BASIS, "ios/Runner/Assets.xcassets/LaunchImage.imageset", name)
        bild.save(ziel)
        print("   ios/.../LaunchImage.imageset/" + name,
              f"{kante}x{kante}")


def main():
    rund = vorlage()
    flaeche = vollflaechig()

    print("Zeitexa-Symbole werden erzeugt:")
    speichere(rund, "tools/release/zeitexa_icon_1024.png", 1024)
    # Als App-Bild eingebunden (pubspec.yaml -> assets), damit der
    # Freischalt- und der Willkommensbildschirm das Produktzeichen zeigen
    # statt eines allgemeinen Material-Symbols.
    speichere(rund, "assets/zeitexa_logo.png", 512)
    speichere(rund, "web/icons/Icon-192.png", 192)
    speichere(rund, "web/icons/Icon-512.png", 512)
    speichere(flaeche, "web/icons/Icon-maskable-192.png", 192)
    speichere(flaeche, "web/icons/Icon-maskable-512.png", 512)
    speichere(rund, "web/favicon.png", 32)

    for ordner, groesse in [
        ("mipmap-mdpi", 48),
        ("mipmap-hdpi", 72),
        ("mipmap-xhdpi", 96),
        ("mipmap-xxhdpi", 144),
        ("mipmap-xxxhdpi", 192),
    ]:
        speichere(rund,
                  f"android/app/src/main/res/{ordner}/ic_launcher.png", groesse)

    # Windows-Symbole: die App selbst und das Entwickler-Werkzeug. Beide
    # bekommen dasselbe Motiv, damit auf keinen Fall Verwechslungsgefahr mit
    # der Firmenversion Zeitrax entsteht (die weiterhin das
    # Flutter-Standardsymbol traegt).
    for pfad in [
        "windows/runner/resources/app_icon.ico",
        "tools/lizenz_gui/windows/runner/resources/app_icon.ico",
    ]:
        rund.save(os.path.join(BASIS, pfad),
                  sizes=[(16, 16), (32, 32), (48, 48), (64, 64),
                         (128, 128), (256, 256)])
        print("  ", pfad, "(16-256)")

    # iOS: ohne Alphakanal, sonst weist Xcode die Symbole zurueck.
    ios_symbole(ohne_transparenz(rund))
    print("Fertig.")


if __name__ == "__main__":
    main()
