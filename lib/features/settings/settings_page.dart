import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

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
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Tentang aplikasi'),
            subtitle: Text('Sandi Pramuka v0.1.0'),
          ),
        ],
      ),
    );
  }
}
