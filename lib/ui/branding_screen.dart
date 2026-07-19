import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../export/export_service.dart';
import '../logic/backup_stub.dart'
    if (dart.library.io) '../logic/backup_io.dart' as plattform;
import '../main.dart';

const _farben = <int, String>{
  0xFF1565C0: 'Blau',
  0xFF2E7D32: 'Grün',
  0xFFC62828: 'Rot',
  0xFFEF6C00: 'Orange',
  0xFF6A1B9A: 'Violett',
  0xFF00838F: 'Türkis',
  0xFF37474F: 'Grau',
  0xFF827717: 'Oliv',
};

/// Versteckter Entwickler-/Branding-Bereich: Firmendaten, Logo, Akzentfarbe.
class BrandingScreen extends ConsumerStatefulWidget {
  const BrandingScreen({super.key});

  @override
  ConsumerState<BrandingScreen> createState() => _BrandingScreenState();
}

class _BrandingScreenState extends ConsumerState<BrandingScreen> {
  final _firma = TextEditingController();
  final _adresse = TextEditingController();
  final _telefon = TextEditingController();
  final _email = TextEditingController();
  final _betreffVorlage = TextEditingController();
  Uint8List? _logo;
  int _farbe = 0xFF1565C0;
  bool _geladen = false;

  @override
  void initState() {
    super.initState();
    ref.read(dbProvider).branding().then((b) {
      if (!mounted) return;
      setState(() {
        _firma.text = b.firmenname;
        _adresse.text = b.adresse;
        _telefon.text = b.telefon;
        _email.text = b.email;
        _logo = b.logo;
        _farbe = b.akzentFarbe;
        _geladen = true;
      });
    });
    ref.read(dbProvider).getSetting(SettingsKeys.betreffVorlage).then((v) {
      if (mounted) setState(() => _betreffVorlage.text = v ?? kBetreffVorlageStandard);
    });
  }

  @override
  void dispose() {
    for (final c in [_firma, _adresse, _telefon, _email, _betreffVorlage]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _logoWaehlen() async {
    final ergebnis = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final bytes = ergebnis?.files.firstOrNull?.bytes;
    if (bytes != null) setState(() => _logo = bytes);
  }

  Future<void> _speichern() async {
    final db = ref.read(dbProvider);
    await (db.update(db.brandings)..where((t) => t.id.equals(1))).write(
      BrandingsCompanion(
        firmenname: Value(_firma.text.trim().isEmpty ? 'Zeitexa' : _firma.text.trim()),
        adresse: Value(_adresse.text.trim()),
        telefon: Value(_telefon.text.trim()),
        email: Value(_email.text.trim()),
        logo: Value(_logo),
        akzentFarbe: Value(_farbe),
      ),
    );
    await db.setSetting(
        SettingsKeys.betreffVorlage,
        _betreffVorlage.text.trim().isEmpty
            ? kBetreffVorlageStandard
            : _betreffVorlage.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Branding gespeichert.')));
      Navigator.pop(context);
    }
  }

  Future<void> _lizenzExportieren() async {
    try {
      final json = await ref.read(lizenzProvider).exportiereLizenzdatei();
      final dateiname =
          '${_firma.text.trim().isEmpty ? 'zeitexa' : _firma.text.trim()}.zeitexalizenz.json';
      // Der Desktop hat keinen System-Teilen-Dialog für Dateien – dort
      // stattdessen „Speichern unter" (wie bei der Datensicherung).
      final desktop = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS);
      if (desktop) {
        final pfad = await plattform.speichereDatei('Lizenzdatei speichern',
            dateiname, ['json'], Uint8List.fromList(utf8.encode(json)));
        if (pfad != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lizenzdatei gespeichert: $pfad')));
        }
        return;
      }
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(Uint8List.fromList(utf8.encode(json)),
              name: dateiname, mimeType: 'application/json'),
        ],
        subject: 'Zeitexa Lizenzdatei',
        text: 'Zeitexa-Lizenzdatei zum Importieren auf einem anderen Gerät.',
      ));
    } on StateError {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Keine Lizenz vorhanden – erst per Code freischalten.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_geladen) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Branding (Entwickler-Bereich)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
              'Diese Daten erscheinen in der App sowie auf allen PDF- und Excel-Exporten.'),
          const SizedBox(height: 16),
          TextField(
              controller: _firma,
              decoration: const InputDecoration(labelText: 'Firmenname')),
          TextField(
              controller: _adresse,
              decoration: const InputDecoration(labelText: 'Adresse')),
          TextField(
              controller: _telefon,
              decoration: const InputDecoration(labelText: 'Telefon')),
          TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-Mail (Anzeige)')),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_logo != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Image.memory(_logo!, height: 48),
                ),
              OutlinedButton.icon(
                icon: const Icon(Icons.image_outlined),
                label: Text(_logo == null ? 'Logo wählen' : 'Logo ändern'),
                onPressed: _logoWaehlen,
              ),
              if (_logo != null)
                TextButton(
                    onPressed: () => setState(() => _logo = null),
                    child: const Text('Entfernen')),
            ],
          ),
          const SizedBox(height: 16),
          Text('Akzentfarbe', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final e in _farben.entries)
                ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: Color(e.key)),
                  label: Text(e.value),
                  selected: _farbe == e.key,
                  onSelected: (_) => setState(() => _farbe = e.key),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          Text('Mail-Betreff beim Export',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _betreffVorlage,
            decoration: const InputDecoration(
              labelText: 'Betreff-Vorlage',
              helperText: 'Platzhalter: {Mitarbeiter} {Monat} {Jahr} '
                  '{Firma} {Zeitraum}',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _speichern, child: const Text('Speichern')),
          const SizedBox(height: 24),
          const Divider(),
          Text('Lizenz', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
              'Exportiert die signierte Lizenz dieses Geräts als Datei, '
              'z.B. zum Importieren auf einem anderen Gerät/einer anderen '
              'Plattform (siehe Sperrbildschirm → Lizenzdatei importieren).'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.ios_share),
            label: const Text('Lizenzdatei exportieren'),
            onPressed: _lizenzExportieren,
          ),
        ],
      ),
    );
  }
}
