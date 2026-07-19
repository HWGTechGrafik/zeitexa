; Inno-Setup-Skript fuer den Zeitexa-Windows-Installer (Zeitexa_Setup_v<Version>.exe).
; Wird normalerweise von erstelle_paket.ps1 aufgerufen, das Version, Quell- und
; Ausgabeordner per /D-Parameter uebergibt. Die #ifndef-Werte sind Fallbacks
; fuer einen manuellen Aufruf aus tools\release heraus.

#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif
#ifndef QuellOrdner
  #define QuellOrdner "..\..\build\windows\x64\runner\Release"
#endif
#ifndef AusgabeOrdner
  #define AusgabeOrdner "..\..\dist"
#endif

[Setup]
; AppId nie aendern - daran erkennt Windows bei Updates die vorhandene
; Installation. EIGENE GUID, verschieden von Zeitrax: sonst wuerde das
; Zeitexa-Setup die installierte Firmenversion als Update ueberschreiben.
AppId={{937F5A02-2E5E-4CEB-A3F0-2EDF09EBA3DA}}
AppName=Zeitexa
AppVersion={#MyAppVersion}
AppPublisher=Florian Moser
DefaultDirName={autopf}\Zeitexa
DefaultGroupName=Zeitexa
; Installation ohne Admin-Rechte (landet im Benutzerprofil).
PrivilegesRequired=lowest
OutputDir={#AusgabeOrdner}
OutputBaseFilename=Zeitexa_Setup_v{#MyAppVersion}
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\zeitexa.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=yes

[Languages]
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#QuellOrdner}\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\Zeitexa"; Filename: "{app}\zeitexa.exe"
Name: "{autodesktop}\Zeitexa"; Filename: "{app}\zeitexa.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\zeitexa.exe"; Description: "{cm:LaunchProgram,Zeitexa}"; Flags: nowait postinstall skipifsilent

; Hinweis: Die Datenbank (zeitexa.sqlite in Dokumente) wird beim
; Deinstallieren absichtlich NICHT geloescht.
