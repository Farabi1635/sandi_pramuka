import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/achievements.dart';
import '../../core/utils/user_profile_provider.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/cipher_logo.dart';
import '../../shared/widgets/stat_tile.dart';
import 'daily_challenge_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final stats = ref.watch(achievementStatsProvider);
    final profile = ref.watch(userProfileProvider);
    final percent = (stats.lessonProgress * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          AppLogo(size: 32),
          SizedBox(width: 10),
          Text('Sandi Pramuka'),
        ]),
        actions: [
          IconButton(
            tooltip: 'Riwayat',
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
          ),
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
          if (profile.hasName || profile.level != null)
            Text(
              [
                if (profile.hasName) profile.name,
                if (profile.level != null) scoutLevelLabel(profile.level!),
              ].join(' - '),
              style: t.textTheme.titleSmall,
            ),
          const SizedBox(height: 4),
          const Text('Belajar Sandi, Pecahkan Rahasia, Kuasai Pramuka.'),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: Icon(Icons.cloud_off, size: 18),
              label: Text('Offline-first: materi tersedia tanpa internet'),
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
                  Text(
                    'Progres: ${stats.completedLessons} dari ${stats.totalLessons} materi ($percent%)',
                    style: const TextStyle(color: AppColors.cream),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: stats.lessonProgress,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                    color: AppColors.cream,
                    backgroundColor: AppColors.greenDark,
                  ),
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
                  value: '${stats.completedLessons}/${stats.totalLessons}',
                  label: 'Materi selesai'),
              StatTile(
                  icon: Icons.quiz,
                  value: '${stats.quizCount}',
                  label: 'Kuis dikerjakan'),
              StatTile(
                  icon: Icons.translate,
                  value: '${stats.translationCount}',
                  label: 'Terjemahan'),
              StatTile(
                  icon: Icons.emoji_events,
                  value: '${stats.bestScore}',
                  label: 'Nilai terbaik'),
            ],
          ),
          const SizedBox(height: 16),
          const DailyChallengeCard(),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
