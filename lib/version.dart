/// Anzeigeversion der App. Fest im Code, damit „Über Zeitexa" die Version
/// auf JEDER Plattform sofort und offline zeigt – auf Web las
/// package_info_plus die Version sonst über eine Netz-Abfrage (version.json),
/// die in der iOS-PWA (offline/kalt) fehlschlug und „unbekannt" ergab.
///
/// WICHTIG: Bei jedem Release zusammen mit `version:` in pubspec.yaml erhöhen.
/// tools/release/erstelle_paket.ps1 bricht ab, wenn beide nicht übereinstimmen.
const String kAppVersion = '1.4.1';
