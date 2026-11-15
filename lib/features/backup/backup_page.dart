import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/backup_codec.dart';
import '../../core/utils/certificate.dart';
import '../../core/utils/progress_provider.dart';
import '../../core/utils/quiz_history_provider.dart';
import '../../core/utils/settings_provider.dart';
import '../../core/utils/translation_history_provider.dart';
import '../../core/utils/user_profile_provider.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  final TextEditingController _input = TextEditingController();

  String? _code;
  BackupSummary? _codeSummary;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _create() {
    final code = createBackupCode(ref.read(sharedPrefsProvider));
    setState(() {
      _code = code;
      _codeSummary = parseBackupCode(code).data?.summary;
    });
  }

  Future<void> _copy(String text) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Kode cadangan disalin.')),
    );
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    setState(() {
      _input.text = data?.text ?? '';
      _error = null;
    });
  }

  Future<void> _restore() async {
    final parsed = parseBackupCode(_input.text);
    final data = parsed.data;
    if (data == null) {
      setState(() => _error = parsed.error);
      return;
    }
    setState(() => _error = null);

    final s = data.summary;
    final when = data.createdAt;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pulihkan data?'),
        content: Text(
          'Cadangan'
          '${when == null ? '' : ' tanggal ${formatIndonesianDate(when)}'}'
          ' berisi:\n\n'
          '- Materi selesai: ${s.lessons}\n'
          '- Favorit: ${s.favorites}\n'
          '- Nilai kuis: ${s.quizzes}\n'
          '- Riwayat terjemahan: ${s.translations}\n'
          '- Nama: ${s.name.isEmpty ? '(kosong)' : s.name}\n\n'
          'Data belajar di HP ini akan DIGANTI dengan isi cadangan. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Pulihkan'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await applyBackup(ref.read(sharedPrefsProvider), data);
    ref
      ..invalidate(completedProvider)
      ..invalidate(favoritesProvider)
      ..invalidate(quizHistoryProvider)
      ..invalidate(translationHistoryProvider)
      ..invalidate(userProfileProvider);

    if (!mounted) return;
    _input.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil dipulihkan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final code = _code;
    final summary = _codeSummary;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadangkan dan Pulihkan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Pindahkan progres, favorit, nilai kuis, riwayat, dan profil ke HP '
            'lain tanpa internet atau akun.',
            style: t.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          Text('1. Cadangkan', style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _create,
            icon: const Icon(Icons.backup),
            label: const Text('Buat kode cadangan'),
          ),
          if (code != null) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: t.colorScheme.primary.withAlpha(25),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (summary != null)
                      Text(
                        'Berisi: ${summary.lessons} materi selesai, '
                        '${summary.favorites} favorit, ${summary.quizzes} nilai '
                        'kuis, ${summary.translations} riwayat terjemahan.',
                        style: t.textTheme.bodySmall,
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 96,
                      child: SingleChildScrollView(
                        child: SelectableText(
                          code,
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () => _copy(code),
                      icon: const Icon(Icons.copy),
                      label: const Text('Salin kode'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kirim kode ini ke dirimu sendiri (misalnya lewat '
                      'WhatsApp). Kode bukan enkripsi: nama dan riwayatmu '
                      'bisa dibaca siapa pun yang memegangnya, jadi jangan '
                      'dibagikan sembarangan.',
                      style: t.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          Text('2. Pulihkan', style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _input,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Kode cadangan',
              hintText: 'SPB1-...',
              suffixIcon: IconButton(
                tooltip: 'Tempel',
                icon: const Icon(Icons.paste),
                onPressed: _paste,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _restore,
            icon: const Icon(Icons.restore),
            label: const Text('Pulihkan data'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: t.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!,
                    style: TextStyle(color: t.colorScheme.onErrorContainer)),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
