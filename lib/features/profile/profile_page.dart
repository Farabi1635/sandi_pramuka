import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/achievements.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/stat_tile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final stats = ref.watch(achievementStatsProvider);
    final badges = computeBadges(stats);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: AppLogo(size: 88)),
          const SizedBox(height: 12),
          const Center(child: Text('Mode Tamu')),
          const SizedBox(height: 4),
          const Center(
            child: Text('Login dan sinkronisasi tersedia di Tahap 6.',
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
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
                  icon: Icons.analytics,
                  value: '${stats.averageScore}',
                  label: 'Rata-rata nilai'),
              StatTile(
                  icon: Icons.emoji_events,
                  value: '${stats.bestScore}',
                  label: 'Nilai terbaik'),
            ],
          ),
          const SizedBox(height: 20),
          Text('Pencapaian', style: t.textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final b in badges)
            Card(
              elevation: 0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: b.earned
                      ? t.colorScheme.primary
                      : t.colorScheme.outlineVariant,
                  child: Icon(
                    b.icon,
                    color: b.earned
                        ? t.colorScheme.onPrimary
                        : t.colorScheme.outline,
                  ),
                ),
                title: Text(b.title),
                subtitle: Text(b.description),
                trailing: Icon(
                  b.earned ? Icons.check_circle : Icons.lock_outline,
                  color: b.earned ? Colors.green : t.colorScheme.outline,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat'),
              subtitle: const Text('Penerjemahan dan nilai kuis'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/history'),
            ),
          ),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings'),
            ),
          ),
        ],
      ),
    );
  }
}
