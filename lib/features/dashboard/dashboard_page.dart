import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/cipher_catalog_seed.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/cipher_logo.dart';
import '../../shared/widgets/stat_tile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          AppLogo(size: 32),
          SizedBox(width: 10),
          Text('Sandi Pramuka'),
        ]),
        actions: [
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Salam Pramuka!', style: t.textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Belajar Sandi, Pecahkan Rahasia, Kuasai Pramuka.'),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: Icon(Icons.cloud_off, size: 18),
              label: Text('Mode offline (sinkronisasi: Tahap 6)'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: AppColors.green,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mulai belajar',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Jelajahi katalog sandi Pramuka.',
                      style: TextStyle(color: AppColors.cream)),
                  const SizedBox(height: 14),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.cream,
                      foregroundColor: AppColors.greenDark,
                    ),
                    onPressed: () => context.go('/learn'),
                    child: const Text('Buka Katalog'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatTile(
                  icon: Icons.menu_book,
                  value: '$totalCipherCount',
                  label: 'Jenis sandi'),
              StatTile(
                  icon: Icons.category,
                  value: '${cipherCategories.length}',
                  label: 'Kategori'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Sandi populer', style: t.textTheme.titleMedium),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final entry in const {
                'morse': 'Morse',
                'semaphore': 'Semaphore',
                'kotak1': 'Kotak',
                'braille': 'Braille',
              }.entries)
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.go('/learn/cipher/${entry.key}'),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(children: [
                      CipherLogo(cipherId: entry.key, size: 56),
                      const SizedBox(height: 6),
                      Text(entry.value, style: t.textTheme.bodySmall),
                    ]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Akses cepat', style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/translator'),
                  icon: const Icon(Icons.translate),
                  label: const Text('Penerjemah'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/exercises'),
                  icon: const Icon(Icons.extension),
                  label: const Text('Latihan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
