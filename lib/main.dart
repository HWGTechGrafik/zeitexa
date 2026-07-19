import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'export/export_service.dart';
import 'logic/auth.dart';
import 'logic/backup_service.dart';
import 'logic/biometrie_service.dart';
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
  return eingerichtet ? GateStatus.bereit : GateStatus.nichtEingerichtet;
});

/// Testmodus: legt beim ersten Start automatisch ein Test-Profil an.
Future<void> _testModusVorbereiten(Ref ref) async {
  final auth = ref.read(authProvider);
  final db = ref.read(dbProvider);
  if (await auth.istEingerichtet()) return;
  await (db.update(db.brandings)..where((t) => t.id.equals(1)))
      .write(const BrandingsCompanion(firmenname: Value('TESTVERSION')));
  await auth.ersteinrichtung(anzeigename: 'Test-Benutzer');
  // Im normalen Betrieb kommt das Entwickler-Passwort aus der Lizenzdatei -
  // fuer die interne Testversion wird es direkt gesetzt.
  await db.setSetting(
      SettingsKeys.brandingPasswordHash, AuthService.hash('test'));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ZeitexaApp()));
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

/// Entscheidet beim Start: Freischaltung (Name + Code/Datei) →
/// Ersteinrichtung (nur Name) → ggf. App-Sperre → Monatsansicht. Die
/// Lizenzprüfung greift immer zuerst.
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
