// Zeitexa Lizenz-Generator (GUI).
//
// Entwickler-Werkzeug fuer Florians Rechner: Lizenznamen eingeben ->
// Freischaltcode anzeigen (kopierbar) und optional die signierte
// Lizenzdatei speichern. Nutzt dieselbe Erzeugungs-Logik wie das CLI
// (erzeugeLizenz aus package:lizenz_shared).
//
// Diese App wird NICHT an Kunden verteilt - sie braucht den privaten
// Schluessel (tools/lizenz_generator/schluessel/privater_schluessel.json).

import 'dart:convert';
import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lizenz_shared/lizenz_shared.dart';

void main() {
  runApp(const LizenzGuiApp());
}

class LizenzGuiApp extends StatelessWidget {
  const LizenzGuiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zeitexa Lizenz-Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const LizenzSeite(),
    );
  }
}

class LizenzSeite extends StatefulWidget {
  const LizenzSeite({super.key});

  @override
  State<LizenzSeite> createState() => _LizenzSeiteState();
}

class _LizenzSeiteState extends State<LizenzSeite> {
  final _firmaController = TextEditingController();
  final _passwortController = TextEditingController();

  /// Pfad zum gefundenen bzw. gewaehlten privaten Schluessel (null = keiner).
  String? _schluesselPfad;

  /// Zuletzt erzeugte Lizenz (null = noch keine erzeugt).
  ErzeugteLizenz? _erzeugt;

  /// Lizenzname, zu dem [_erzeugt] gehoert (fuer Anzeige/Dateiname).
  String _erzeugtFuerFirma = '';

  String? _fehler;
  bool _laeuft = false;

  @override
  void initState() {
    super.initState();
    _schluesselPfad = _sucheSchluessel();
    _firmaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firmaController.dispose();
    _passwortController.dispose();
    super.dispose();
  }

  // ---------- Schluessel-Suche ----------

  String get _exeVerzeichnis => File(Platform.resolvedExecutable).parent.path;

  String get _configDatei => '$_exeVerzeichnis\\lizenz_gui.config.json';

  /// Sucht den privaten Schluessel an bekannten Orten (in dieser Reihenfolge):
  /// 1. schluessel\ neben der EXE
  /// 2. gemerkter Pfad aus der Config-Datei neben der EXE
  /// 3. Entwicklungspfade relativ zu EXE bzw. Arbeitsverzeichnis
  String? _sucheSchluessel() {
    final kandidaten = <String>[
      '$_exeVerzeichnis\\schluessel\\privater_schluessel.json',
      _gemerkterPfad() ?? '',
      // EXE liegt unter tools/lizenz_gui/build/windows/x64/runner/Release
      '$_exeVerzeichnis\\..\\..\\..\\..\\..\\..\\lizenz_generator\\schluessel\\privater_schluessel.json',
      // "flutter run" aus tools/lizenz_gui heraus
      '${Directory.current.path}\\..\\lizenz_generator\\schluessel\\privater_schluessel.json',
    ];
    for (final pfad in kandidaten) {
      if (pfad.isNotEmpty && File(pfad).existsSync()) {
        return File(pfad).absolute.path;
      }
    }
    return null;
  }

  String? _gemerkterPfad() {
    try {
      final config = jsonDecode(File(_configDatei).readAsStringSync());
      if (config is Map && config['schluesselPfad'] is String) {
        return config['schluesselPfad'] as String;
      }
    } catch (_) {
      // Keine/kaputte Config ist kein Fehler - dann wird eben gesucht.
    }
    return null;
  }

  void _merkePfad(String pfad) {
    try {
      File(_configDatei).writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert({'schluesselPfad': pfad}));
    } catch (_) {
      // Nicht kritisch: dann muss der Pfad beim naechsten Start neu gewaehlt werden.
    }
  }

  Future<void> _schluesselWaehlen() async {
    final ergebnis = await FilePicker.platform.pickFiles(
      dialogTitle: 'Privaten Schluessel auswaehlen (privater_schluessel.json)',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final pfad = ergebnis?.files.single.path;
    if (pfad == null) return;
    _merkePfad(pfad);
    setState(() {
      _schluesselPfad = pfad;
      _fehler = null;
    });
  }

  // ---------- Lizenz erzeugen / kopieren / speichern ----------

  Future<void> _erzeugen() async {
    final firma = _firmaController.text.trim();
    if (firma.isEmpty) {
      setState(() => _fehler = 'Bitte zuerst einen Namen eingeben.');
      return;
    }
    final passwort = _passwortController.text;
    if (passwort.isNotEmpty && passwort.length < 12) {
      setState(() => _fehler =
          'Das Entwickler-Passwort muss mindestens 12 Zeichen haben.');
      return;
    }
    final schluesselPfad = _schluesselPfad;
    if (schluesselPfad == null) {
      setState(() => _fehler =
          'Kein privater Schluessel gefunden - bitte unten auswaehlen.');
      return;
    }
    setState(() {
      _laeuft = true;
      _fehler = null;
    });
    try {
      final json = jsonDecode(await File(schluesselPfad).readAsString());
      final seed = base64.decode((json as Map)['privateKeyBase64'] as String);
      final erzeugt = await erzeugeLizenz(
        seed,
        firma,
        entwicklerPasswortHash: passwort.isEmpty
            ? null
            : BCrypt.hashpw(passwort, BCrypt.gensalt()),
      );
      setState(() {
        _erzeugt = erzeugt;
        _erzeugtFuerFirma = firma;
      });
    } catch (e) {
      setState(() {
        _erzeugt = null;
        _fehler = 'Lizenz konnte nicht erzeugt werden: $e';
      });
    } finally {
      setState(() => _laeuft = false);
    }
  }

  Future<void> _kopieren() async {
    final erzeugt = _erzeugt;
    if (erzeugt == null) return;
    await Clipboard.setData(ClipboardData(text: erzeugt.freischaltcode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Freischaltcode kopiert.')),
    );
  }

  Future<void> _dateiSpeichern() async {
    final erzeugt = _erzeugt;
    if (erzeugt == null) return;
    final zielPfad = await FilePicker.platform.saveFile(
      dialogTitle: 'Lizenzdatei speichern',
      fileName: erzeugt.dateiName,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (zielPfad == null) return;
    await File(zielPfad).writeAsString(erzeugt.dateiJson);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lizenzdatei gespeichert: $zielPfad')),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalisiert = normalisiereFirmenname(_firmaController.text);
    final erzeugt = _erzeugt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zeitexa Lizenz-Generator'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _firmaController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Name des Lizenznehmers',
                hintText: 'z. B. Max Muster',
                border: const OutlineInputBorder(),
                helperText: normalisiert.isEmpty
                    ? 'Der Name muss exakt so in der App eingerichtet sein '
                        '(Gross-/Kleinschreibung und Umlaute egal).'
                    : 'Wird gebunden an: "$normalisiert"',
              ),
              onSubmitted: (_) => _erzeugen(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwortController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Entwickler-Passwort (optional, mind. 12 Zeichen)',
                border: OutlineInputBorder(),
                helperText:
                    'Wird als Hash in die LIZENZDATEI eingebettet - die App '
                    'uebernimmt es beim Import als Entwickler-Passwort. '
                    'Der Freischaltcode bleibt davon unberuehrt.',
                helperMaxLines: 3,
              ),
              onSubmitted: (_) => _erzeugen(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _laeuft ? null : _erzeugen,
              icon: const Icon(Icons.vpn_key),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_laeuft ? 'Erzeuge ...' : 'Code erzeugen',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            if (_fehler != null) ...[
              const SizedBox(height: 16),
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_fehler!,
                      style:
                          TextStyle(color: theme.colorScheme.onErrorContainer)),
                ),
              ),
            ],
            if (erzeugt != null) ...[
              const SizedBox(height: 24),
              Text('Freischaltcode fuer "$_erzeugtFuerFirma":',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    erzeugt.freischaltcode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _kopieren,
                      icon: const Icon(Icons.copy),
                      label: const Text('Code kopieren'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _dateiSpeichern,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Lizenzdatei speichern ...'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _schluesselPfad != null ? Icons.lock : Icons.lock_open,
                  size: 18,
                  color: _schluesselPfad != null
                      ? Colors.green
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _schluesselPfad != null
                        ? 'Privater Schluessel: $_schluesselPfad'
                        : 'Kein privater Schluessel gefunden.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: _schluesselWaehlen,
                  child: const Text('Aendern ...'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
