# Erstellt das komplette Auslieferungspaket fuer Kunden im Ordner
# "Lieferung an Kunden" (im Projektstamm):
#
#   Lieferung an Kunden\
#   +-- Windows Setup\Zeitexa_Setup_v<Version>.exe   (Ein-Klick-Installer)
#   +-- Windows ZIP\Zeitexa_Windows_v<Version>.zip   (Start-Datei + App-Ordner)
#   +-- Android\Zeitexa_v<Version>.apk
#   +-- ANLEITUNG.docx
#
# Aufruf (aus dem Projektordner):
#   powershell -ExecutionPolicy Bypass -File tools\release\erstelle_paket.ps1
#   ... -SkipBuild    ueberspringt die Flutter-Builds und packt nur.

param(
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'

# Projektwurzel = zwei Ebenen ueber diesem Skript.
$projekt = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location $projekt

# Version aus pubspec.yaml lesen (z. B. "1.0.0+1" -> "1.0.0").
$versionZeile = (Get-Content "$projekt\pubspec.yaml" | Where-Object { $_ -match '^version:' } | Select-Object -First 1)
if (-not $versionZeile) { throw 'Keine version: in pubspec.yaml gefunden.' }
$version = ($versionZeile -replace '^version:\s*', '').Split('+')[0].Trim()
Write-Host "Zeitexa-Version: $version"

# Anzeigeversion (lib/version.dart, kAppVersion) muss zur pubspec-Version
# passen - sonst zeigt "Ueber Zeitexa" eine falsche Nummer. Vor dem Bauen
# abgleichen, damit beide beim Release nicht auseinanderdriften.
$versionDart = Get-Content "$projekt\lib\version.dart" -Raw
if ($versionDart -notmatch "kAppVersion\s*=\s*'([^']+)'") {
    throw 'kAppVersion in lib/version.dart nicht gefunden.'
}
$appVersion = $Matches[1]
if ($appVersion -ne $version) {
    throw "ABBRUCH: Version stimmt nicht ueberein - pubspec.yaml=$version, lib/version.dart (kAppVersion)=$appVersion. Bitte beide angleichen."
}

$flutter = 'C:\dev\flutter\bin\flutter.bat'
if (-not (Test-Path $flutter)) { $flutter = 'flutter' }

# Inno-Setup-Compiler suchen.
$isccKandidaten = @(
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
)
$iscc = $isccKandidaten | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) { throw 'Inno Setup (ISCC.exe) nicht gefunden - bitte installieren (winget install JRSoftware.InnoSetup).' }

if (-not $SkipBuild) {
    Write-Host 'Baue Windows-App (flutter build windows --release) ...'
    & $flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw 'Windows-Build fehlgeschlagen.' }

    Write-Host 'Baue Android-APK (flutter build apk --release) ...'
    & $flutter build apk --release
    if ($LASTEXITCODE -ne 0) { throw 'Android-Build fehlgeschlagen.' }
}

# Build-Artefakte pruefen.
$windowsRelease = "$projekt\build\windows\x64\runner\Release"
$apk = "$projekt\build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path "$windowsRelease\zeitexa.exe")) { throw "Windows-Build fehlt: $windowsRelease\zeitexa.exe" }
if (-not (Test-Path $apk)) { throw "Android-Build fehlt: $apk" }

# Sicherheitscheck VOR dem Packen: kein privater Schluessel in den Quellen.
$verdaechtig = Get-ChildItem $windowsRelease -Recurse -File | Where-Object { $_.Name -like 'privater_schluessel*' }
if ($verdaechtig) { throw "ABBRUCH: Private Schluesseldatei im Windows-Build gefunden: $($verdaechtig.FullName)" }

# Sicherheitscheck: interne Testversion (ZEITEXA_TESTMODUS) darf NIE
# ausgeliefert werden. Im normalen Release-Build ist der Marker-String
# wegtree-geshaked; findet er sich doch, wurde mit Testmodus gebaut.
function Test-EnthaeltTestmodus([byte[]]$bytes) {
    return [Text.Encoding]::ASCII.GetString($bytes).Contains('TESTVERSION')
}
Write-Host 'Pruefe Builds auf internen Testmodus ...'
$appSo = [IO.File]::ReadAllBytes("$windowsRelease\data\app.so")
if (Test-EnthaeltTestmodus $appSo) {
    throw 'ABBRUCH: Der Windows-Build enthaelt den internen Testmodus (TESTVERSION) - bitte normal neu bauen (ohne --dart-define=ZEITEXA_TESTMODUS).'
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$apkZip = [IO.Compression.ZipFile]::OpenRead($apk)
try {
    foreach ($eintrag in ($apkZip.Entries | Where-Object { $_.FullName -like 'lib/*/libapp.so' })) {
        $strom = $eintrag.Open()
        $speicher = New-Object IO.MemoryStream
        $strom.CopyTo($speicher); $strom.Dispose()
        if (Test-EnthaeltTestmodus $speicher.ToArray()) {
            throw 'ABBRUCH: Die Android-APK enthaelt den internen Testmodus (TESTVERSION) - bitte normal neu bauen.'
        }
        $speicher.Dispose()
    }
} finally { $apkZip.Dispose() }

# Lieferordner frisch aufbauen.
$lieferung = "$projekt\Lieferung an Kunden"
if (Test-Path $lieferung) { Remove-Item $lieferung -Recurse -Force }
New-Item -ItemType Directory -Force "$lieferung\Windows Setup" | Out-Null
New-Item -ItemType Directory -Force "$lieferung\Windows ZIP" | Out-Null
New-Item -ItemType Directory -Force "$lieferung\Android" | Out-Null

# ---- 1. Windows-Installer (Setup.exe) ----
Write-Host 'Erzeuge Windows-Installer (Inno Setup) ...'
& $iscc /Qp `
    "/DMyAppVersion=$version" `
    "/DQuellOrdner=$windowsRelease" `
    "/DAusgabeOrdner=$lieferung\Windows Setup" `
    "$PSScriptRoot\zeitexa_setup.iss"
if ($LASTEXITCODE -ne 0) { throw 'Inno-Setup-Kompilierung fehlgeschlagen.' }

# ---- 2. Windows-ZIP mit Start-Datei ----
Write-Host 'Erzeuge Windows-ZIP mit Start-Datei ...'
$zipStaging = "$projekt\dist\zip_staging"
if (Test-Path $zipStaging) { Remove-Item $zipStaging -Recurse -Force }
New-Item -ItemType Directory -Force "$zipStaging\App" | Out-Null
Copy-Item "$windowsRelease\*" "$zipStaging\App" -Recurse

Set-Content -Path "$zipStaging\Zeitexa starten.bat" -Encoding Ascii -Value @'
@echo off
start "" "%~dp0App\zeitexa.exe"
'@

Set-Content -Path "$zipStaging\LIESMICH.txt" -Encoding Ascii -Value @'
Zeitexa - Stundenerfassung
==========================

1. Diesen ZIP-Ordner zuerst KOMPLETT entpacken
   (Rechtsklick auf die ZIP-Datei -> "Alle extrahieren").
2. Im entpackten Ordner "Zeitexa starten" doppelklicken.

Beim allerersten Start fragt Zeitexa nach Ihrem Namen und dem
Freischaltcode bzw. der Lizenzdatei (bekommen Sie vom Entwickler).
Danach ist nur noch Ihr Anzeigename einzutragen - Arbeitszeiten und
Urlaubswerte stellen Sie anschliessend selbst in der Verwaltung ein.

Wichtig: Nicht direkt aus dem ZIP-Fenster heraus starten.
Der Ordner "App" enthaelt die Programmdateien - dort nichts loeschen.

Weitere Infos (Datensicherung, App-Sperre usw.):
siehe ANLEITUNG.docx im Lieferpaket.
'@

$zip = "$lieferung\Windows ZIP\Zeitexa_Windows_v$version.zip"
Compress-Archive -Path "$zipStaging\*" -DestinationPath $zip
Remove-Item $zipStaging -Recurse -Force

# ---- 3. Android + Anleitung ----
Write-Host 'Kopiere Android-APK und Anleitung ...'
Copy-Item $apk "$lieferung\Android\Zeitexa_v$version.apk"
Copy-Item "$projekt\ANLEITUNG.docx" "$lieferung\ANLEITUNG.docx"

# Sicherheitscheck NACH dem Packen ueber den ganzen Lieferordner.
$verdaechtig = Get-ChildItem $lieferung -Recurse -File | Where-Object { $_.Name -like 'privater_schluessel*' }
if ($verdaechtig) {
    Remove-Item $lieferung -Recurse -Force
    throw "ABBRUCH: Private Schluesseldatei im Lieferpaket gefunden: $($verdaechtig.FullName)"
}

Write-Host ''
Write-Host "Fertig: $lieferung" -ForegroundColor Green
Get-ChildItem $lieferung -Recurse -File | ForEach-Object {
    $mb = [math]::Round($_.Length / 1MB, 1)
    Write-Host ("  " + $_.FullName.Substring($lieferung.Length + 1) + "  ($mb MB)")
}
