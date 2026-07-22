import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'export/export_service.dart';
import 'logic/auth.dart';
import 'logic/backup_service.dart';
import 'logic/biometrie_service.dart';
import 'logic/fehlerprotokoll.dart';
import 'logic/lizenz_service.dart';
import 'ui/lizenz_screen.dart';
import 'ui/monats_screen.dart';
import 'ui/setup_screen.dart';
import 'ui/sperr_screen.dart';

final dbProvider = Provider<ZeitexaDb>((ref) => ZeitexaDb());
final authProvider =
    Provider<AuthService>((ref) => AuthService(ref.watch(dbProvider)));
final exportProvider =
    Provider<ExportService>((ref) => ExportService(ref.watch(dbProvider)));
final lizenzProvider =
    Provider<LizenzService>((ref) => LizenzService(ref.watch(dbProvider)));
final backupProvider =
    Provider<BackupService>((ref) => BackupService(ref.watch(dbProvider)));
final biometrieProvider = Provider<BiometrieService>(
    (ref) => BiometrieService(ref.watch(dbProvider)));

/// Das eine Profil dieser Installation. Zeitexa kennt keine Anmeldung –
/// nach `ref.invalidate` (z.B. nach Namensänderung in der Verwaltung) wird
/// es neu geladen.
final einzelUserProvider =
    FutureProvider<User?>((ref) => ref.watch(authProvider).einzelUser());

/// Hat der Nutzer seine Zeit- und Urlaubswerte einmal bestätigt? Solange
/// nicht, steht in der Monatsansicht die Hinweiskarte, weil der Erststart
/// mit Vorgabewerten arbeitet.
final einstellungenGeprueftProvider = FutureProvider<bool>((ref) =>
    ref.watch(dbProvider).getBoolSetting(SettingsKeys.einstellungenGeprueft));

/// Ist die optionale App-Sperre eingeschaltet? Standard: nein.
final appSperreProvider =
    FutureProvider<bool>((ref) => ref.watch(authProvider).appSperreAktiv());

/// Wurde in dieser Sitzung bereits entsperrt?
class Entsperrt extends Notifier<bool> {
  @override
  bool build() => false;

  void freigeben() => state = true;
}

final entsperrtProvider =
    NotifierProvider<Entsperrt, bool>(Entsperrt.new);

/// Branding als Stream, damit Farbe/Name sofort überall greifen.
final brandingProvider =
    StreamProvider<Branding>((ref) => ref.watch(dbProvider).watchBranding());

/// Datenströme der Monatsansicht als Provider – damit sie NICHT bei jedem
/// `build()` neu erzeugt werden (das führte zu Hängern/weißem Bildschirm beim
/// schnellen Hin- und Herschalten). Siehe lib/ui/monats_screen.dart.
final monatEintraegeProvider = StreamProvider.family<List<TimeEntry>,
    ({int userId, int jahr, int monat})>(
  (ref, p) => ref.watch(dbProvider).watchMonth(p.userId, p.jahr, p.monat),
);

final alleEintraegeProvider = StreamProvider.family<List<TimeEntry>, int>(
  (ref, userId) => ref.watch(dbProvider).watchAllEntries(userId),
);

final ortNamenProvider = StreamProvider<Map<int, String>>((ref) {
  final db = ref.watch(dbProvider);
  return db.select(db.places).watch().map(
      (orte) => {for (final o in orte) o.id: o.name});
});

/// Stempel-Blöcke je Tageskopf für den angezeigten Monat (nur Tage mit ≥2
/// Blöcken) – für die block-genaue Berechnung UND die Anzeige „· N Blöcke".
final monatBloeckeProvider = StreamProvider.family<Map<int, List<Zeitblock>>,
    ({int userId, int jahr, int monat})>(
  (ref, p) =>
      ref.watch(dbProvider).watchBloeckeFuerMonat(p.userId, p.jahr, p.monat),
);

/// Alle Stempel-Blöcke des Benutzers – für Konten (rechnet über alle Tage).
final alleBloeckeProvider =
    StreamProvider.family<Map<int, List<Zeitblock>>, int>(
  (ref, userId) => ref.watch(dbProvider).watchAlleBloecke(userId),
);

/// Interner Testmodus - NUR fuer Builds mit
/// `--dart-define=ZEITEXA_TESTMODUS=true`: ueberspringt Freischaltung und
/// Ersteinrichtung (Test-Profil "Test-Benutzer") und zeigt ein rotes
/// TESTVERSION-Band. Solche Builds duerfen NIEMALS ausgeliefert werden -
/// tools/release/erstelle_paket.ps1 prueft die Binaries darauf und bricht
/// sonst ab.
const bool kTestModus = bool.fromEnvironment('ZEITEXA_TESTMODUS');

/// Reihenfolge, in der StartGate entscheidet, was angezeigt wird.
enum GateStatus { keineLizenz, nichtEingerichtet, bereit }

/// Wird nach Lizenzfreischaltung bzw. Ersteinrichtung per
/// `ref.invalidate(gateStatusProvider)` neu ausgewertet.
final gateStatusProvider = FutureProvider<GateStatus>((ref) async {
  if (kTestModus) {
    await _testModusVorbereiten(ref);
    return GateStatus.bereit;
  }
  final freigeschaltet = await ref.watch(lizenzProvider).istFreigeschaltet();
  if (!freigeschaltet) return GateStatus.keineLizenz;
  final eingerichtet = await ref.watch(authProvider).istEingerichtet();
  if (!eingerichtet) return GateStatus.nichtEingerichtet;
  // Anzeigename = Lizenzname. Nötig für Installationen aus der Zeit, als
  // der Name bei der Ersteinrichtung noch frei wählbar war.
  await ref.watch(lizenzProvider).synchronisiereAnzeigename();
  return GateStatus.bereit;
});

/// Testmodus: legt beim ersten Start automatisch ein Test-Profil an.
/// Der Anzeigename entspricht wie im Normalbetrieb dem Lizenz- bzw.
/// hier dem Platzhalter-Namen.
Future<void> _testModusVorbereiten(Ref ref) async {
  final auth = ref.read(authProvider);
  final db = ref.read(dbProvider);
  if (await auth.istEingerichtet()) return;
  await (db.update(db.brandings)..where((t) => t.id.equals(1)))
      .write(const BrandingsCompanion(firmenname: Value('TESTVERSION')));
  await auth.ersteinrichtung(anzeigename: 'TESTVERSION');
}

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    installiereFehlerprotokoll();
    runApp(const ProviderScope(child: ZeitexaApp()));
  }, (fehler, stack) {
    // Fehler aus asynchronen Zonen ebenfalls still protokollieren.
    debugPrint('Unbehandelter Fehler: $fehler');
  });
}

class ZeitexaApp extends ConsumerWidget {
  const ZeitexaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingProvider).value;
    final akzent = Color(branding?.akzentFarbe ?? 0xFF1565C0);
    return MaterialApp(
      title: 'Zeitexa',
      debugShowCheckedModeBanner: false,
      // Deutsche Oberflächentexte in Kalender, Zeit- und Datumswählern.
      locale: const Locale('de'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('de'), Locale('en')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: akzent),
        useMaterial3: true,
      ),
      home: kTestModus
          ? const Banner(
              message: 'TESTVERSION',
              location: BannerLocation.topEnd,
              color: Colors.red,
              child: StartGate(),
            )
          : const StartGate(),
    );
  }
}

/// Entscheidet beim Start: Freischaltung (Code + Name bzw. Lizenzdatei) →
/// Willkommensbildschirm (Profil wird mit dem Lizenznamen angelegt) →
/// ggf. App-Sperre → Monatsansicht. Die Lizenzprüfung greift immer zuerst.
class StartGate extends ConsumerWidget {
  const StartGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(gateStatusProvider);
    return gate.when(
      loading: () => const _Warten(),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child:
                Text('Datenbank-Fehler: $error', textAlign: TextAlign.center),
          ),
        ),
      ),
      data: (status) => switch (status) {
        GateStatus.nichtEingerichtet => const SetupScreen(),
        GateStatus.keineLizenz => const LizenzScreen(),
        GateStatus.bereit => const _Bereit(),
      },
    );
  }
}

/// Freigeschaltet und eingerichtet: Profil laden, ggf. entsperren lassen.
class _Bereit extends ConsumerWidget {
  const _Bereit();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(einzelUserProvider).value;
    if (user == null) return const _Warten();
    final gesperrt = ref.watch(appSperreProvider).value ?? false;
    final entsperrt = ref.watch(entsperrtProvider);
    if (gesperrt && !entsperrt) return SperrScreen(user: user);
    return MonatsScreen(user: user);
  }
}

class _Warten extends StatelessWidget {
  const _Warten();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
