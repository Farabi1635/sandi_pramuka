import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/progress_provider.dart';
import '../../core/utils/quiz_history_provider.dart';
import '../../core/utils/settings_provider.dart';
import '../../core/utils/translation_history_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _confirmClearData(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus data lokal?'),
        content: const Text(
            'Progres belajar, favorit, riwayat terjemahan, nilai kuis, dan '
            'tantangan harian di perangkat ini akan dihapus. Pengaturan tema '
            'tidak ikut dihapus. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final prefs = ref.read(sharedPrefsProvider);
    for (final key in const [
      'completed_ciphers',
      'favorite_ciphers',
      'quiz_results',
      'translation_history',
      'daily_done',
    ]) {
      await prefs.remove(key);
    }
    ref
      ..invalidate(completedProvider)
      ..invalidate(favoritesProvider)
      ..invalidate(quizHistoryProvider)
      ..invalidate(translationHistoryProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data lokal sudah dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final scale = ref.watch(textScaleProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tema', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Terang')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Gelap')),
              ButtonSegment(value: ThemeMode.system, label: Text('Sistem')),
            ],
            selected: {mode},
            onSelectionChanged: (s) =>
                ref.read(themeModeProvider.notifier).set(s.first),
          ),
          const SizedBox(height: 24),
          Text('Ukuran teks (${scale.toStringAsFixed(1)}x)',
              style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: scale,
            min: 0.8,
            max: 1.4,
            divisions: 6,
            onChanged: (v) => ref
                .read(textScaleProvider.notifier)
                .set(double.parse(v.toStringAsFixed(1))),
          ),
          const SizedBox(height: 16),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Hapus data lokal'),
            subtitle: const Text('Progres, favorit, riwayat, dan nilai kuis'),
            onTap: () => _confirmClearData(context, ref),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Tentang aplikasi'),
            subtitle: Text(
              'Sandi Pramuka v0.1.0\n'
              'Aplikasi belajar sandi. Pencapaian di dalam aplikasi bukan '
              'sertifikasi resmi Gerakan Pramuka.',
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}
