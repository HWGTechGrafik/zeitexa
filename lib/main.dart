import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'export/export_service.dart';
import 'logic/auth.dart';
import 'logic/backup_service.dart';
import 'logic/benutzer_transfer.dart';
import 'logic/biometrie_service.dart';
import 'logic/lizenz_service.dart';
import 'ui/lizenz_screen.dart';
import 'ui/login_screen.dart';
import 'ui/monats_screen.dart';
import 'ui/setup_screen.dart';

final dbProvider = Provider<ZeitexaDb>((ref) => ZeitexaDb());
final authProvider =
    Provider<AuthService>((ref) => AuthService(ref.watch(dbProvider)));
final exportProvider =
    Provider<ExportService>((ref) => ExportService(ref.watch(dbProvider)));
final lizenzProvider =
    Provider<LizenzService>((ref) => LizenzService(ref.watch(dbProvider)));
final backupProvider =
    Provider<BackupService>((ref) => BackupService(ref.watch(dbProvider)));
final benutzerTransferProvider = Provider<BenutzerTransfer>(
    (ref) => BenutzerTransfer(ref.watch(dbProvider)));
final biometrieProvider = Provider<BiometrieService>(
    (ref) => BiometrieService(ref.watch(dbProvider)));

/// Der aktuell angemeldete Benutzer (null = Login-Screen).
class AngemeldeterUser extends Notifier<User?> {
  @override
  User? build() => null;

  void anmelden(User user) => state = user;
  void abmelden() => state = null;
}

final angemeldeterUserProvider =
    NotifierProvider<AngemeldeterUser, User?>(AngemeldeterUser.new);

/// Branding als Stream, damit Farbe/Name sofort überall greifen.
final brandingProvider =
    StreamProvider<Branding>((ref) => ref.watch(dbProvider).watchBranding());

/// Interner Testmodus - NUR fuer Builds mit
/// `--dart-define=ZEITEXA_TESTMODUS=true`: ueberspringt Freischaltung,
/// Ersteinrichtung und Login (Test-Benutzer "tester", alle Passwoerter
/// "test") und zeigt ein rotes TESTVERSION-Band. Solche Builds duerfen
/// NIEMALS ausgeliefert werden - tools/release/erstelle_paket.ps1
/// prueft die Binaries darauf und bricht sonst ab.
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

/// Testmodus: legt beim ersten Start automatisch eine Test-Einrichtung an
/// (Firma "TESTVERSION", Benutzer "tester", alle Passwoerter "test").
/// Bei einer bereits eingerichteten Datenbank wird nur der Test-Benutzer
/// sichergestellt.
Future<void> _testModusVorbereiten(Ref ref) async {
  final auth = ref.read(authProvider);
  final db = ref.read(dbProvider);
  if (!await auth.istEingerichtet()) {
    await (db.update(db.brandings)..where((t) => t.id.equals(1))).write(
        const BrandingsCompanion(firmenname: Value('TESTVERSION')));
    await auth.ersteinrichtung(
      adminPasswort: 'test',
      username: 'tester',
      anzeigename: 'Test-Benutzer',
      benutzerPasswort: 'test',
    );
    // Im normalen Betrieb kommt das Entwickler-Passwort aus der
    // Lizenzdatei - fuer die interne Testversion wird es direkt gesetzt.
    await db.setSetting(
        SettingsKeys.brandingPasswordHash, AuthService.hash('test'));
    return;
  }
  if (await db.userByName('tester') == null) {
    await auth.benutzerAnlegen(
        username: 'tester', anzeigename: 'Test-Benutzer', passwort: 'test');
    await (db.update(db.users)..where((t) => t.username.equals('tester')))
        .write(const UsersCompanion(isAdmin: Value(true)));
  }
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

/// Entscheidet beim Start: Lizenz-Freischaltung (Firmenname + Code) →
/// Ersteinrichtung → Login → Monatsansicht. Die Lizenzprüfung greift
/// unabhängig vom Login-Status, damit die App auch für einen bereits
/// angemeldeten Chef gesperrt bleibt.
class StartGate extends ConsumerWidget {
  const StartGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(gateStatusProvider);
    return gate.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Datenbank-Fehler: $error',
                textAlign: TextAlign.center),
          ),
        ),
      ),
      data: (status) {
        switch (status) {
          case GateStatus.nichtEingerichtet:
            return const SetupScreen();
          case GateStatus.keineLizenz:
            return const LizenzScreen();
          case GateStatus.bereit:
            final user = ref.watch(angemeldeterUserProvider);
            if (user != null) return MonatsScreen(user: user);
            if (kTestModus) return const _TestModusAnmeldung();
            return const LoginScreen();
        }
      },
    );
  }
}

/// Testmodus: meldet den Test-Benutzer automatisch an (kein Login-Screen).
class _TestModusAnmeldung extends ConsumerStatefulWidget {
  const _TestModusAnmeldung();

  @override
  ConsumerState<_TestModusAnmeldung> createState() =>
      _TestModusAnmeldungState();
}

class _TestModusAnmeldungState extends ConsumerState<_TestModusAnmeldung> {
  @override
  void initState() {
    super.initState();
    ref.read(dbProvider).userByName('tester').then((user) {
      if (mounted && user != null) {
        ref.read(angemeldeterUserProvider.notifier).anmelden(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
