import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/achievements.dart';
import '../../core/utils/certificate.dart';
import '../../core/utils/user_profile_provider.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/stat_tile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
    final current = ref.read(userProfileProvider);
    final controller = TextEditingController(text: current.name);
    ScoutLevel? level = current.level;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Ubah profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  maxLength: UserProfileNotifier.maxNameLength,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                const SizedBox(height: 8),
                const Text('Tingkatan Pramuka'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final l in ScoutLevel.values)
                      ChoiceChip(
                        label: Text(scoutLevelLabel(l)),
                        selected: level == l,
                        onSelected: (_) =>
                            setLocal(() => level = level == l ? null : l),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      await ref
          .read(userProfileProvider.notifier)
          .save(name: controller.text, level: level);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final stats = ref.watch(achievementStatsProvider);
    final profile = ref.watch(userProfileProvider);
    final badges = computeBadges(stats);
    final certificateReady = certificateStatus(stats).eligible;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            tooltip: 'Ubah profil',
            icon: const Icon(Icons.edit),
            onPressed: () => _editProfile(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: AppLogo(size: 88)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              profile.hasName ? profile.name : 'Sahabat Pramuka',
              style: t.textTheme.titleLarge,
            ),
          ),
          if (profile.level != null)
            Center(
              child: Chip(
                label: Text('Tingkatan ${scoutLevelLabel(profile.level!)}'),
                visualDensity: VisualDensity.compact,
              ),
            ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Mode Tamu. Semua data tersimpan di HP ini.',
              textAlign: TextAlign.center,
            ),
          ),
          if (!profile.hasName && profile.level == null)
            Center(
              child: TextButton.icon(
                onPressed: () => _editProfile(context, ref),
                icon: const Icon(Icons.edit),
                label: const Text('Atur nama dan tingkatan'),
              ),
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
              leading: const Icon(Icons.workspace_premium),
              title: const Text('Sertifikat'),
              subtitle: Text(certificateReady
                  ? 'Sudah memenuhi syarat, ketuk untuk melihat'
                  : 'Belum memenuhi syarat'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/certificate'),
            ),
          ),
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
