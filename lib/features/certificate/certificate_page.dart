import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/achievements.dart';
import '../../core/utils/certificate.dart';
import '../../core/utils/settings_provider.dart';
import '../../core/utils/user_profile_provider.dart';
import '../../shared/widgets/app_logo.dart';

class CertificatePage extends ConsumerStatefulWidget {
  const CertificatePage({super.key});

  @override
  ConsumerState<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends ConsumerState<CertificatePage> {
  static const _dateKey = 'certificate_date';
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPrefsProvider);
    final eligible =
        certificateStatus(ref.read(achievementStatsProvider)).eligible;
    final saved = DateTime.tryParse(prefs.getString(_dateKey) ?? '');
    if (eligible && saved == null) {
      final now = DateTime.now();
      _date = DateTime(now.year, now.month, now.day);
      prefs.setString(_dateKey, _date!.toIso8601String().substring(0, 10));
    } else {
      _date = saved;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = certificateStatus(ref.watch(achievementStatsProvider));
    final profile = ref.watch(userProfileProvider);
    final s = status.stats;

    return Scaffold(
      appBar: AppBar(title: const Text('Sertifikat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (status.eligible)
            _buildCertificate(context, s, profile)
          else
            _buildRequirements(context, status),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCertificate(
      BuildContext context, AchievementStats s, UserProfile profile) {
    final t = Theme.of(context);
    const ink = AppColors.greenDark;
    final date = _date ?? DateTime.now();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cream,
            border: Border.all(color: AppColors.brown, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const AppLogo(size: 72),
              const SizedBox(height: 12),
              const Text(
                'SERTIFIKAT PENYELESAIAN',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5),
              ),
              const SizedBox(height: 4),
              const Text('Belajar Sandi Pramuka',
                  style: TextStyle(color: AppColors.brown)),
              const SizedBox(height: 20),
              const Text('Diberikan kepada', style: TextStyle(color: ink)),
              const SizedBox(height: 6),
              Text(
                profile.hasName ? profile.name : 'Sahabat Pramuka',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: ink, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              if (profile.level != null) ...[
                const SizedBox(height: 4),
                Text('Tingkatan ${scoutLevelLabel(profile.level!)}',
                    style: const TextStyle(color: ink)),
              ],
              const SizedBox(height: 16),
              Text(
                'yang telah menyelesaikan ${s.totalLessons} materi sandi dan '
                '${s.quizCount} kuis latihan dengan nilai rata-rata '
                '${s.averageScore}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ink),
              ),
              const SizedBox(height: 16),
              Text('Diterbitkan pada ${formatIndonesianDate(date)}',
                  style: const TextStyle(color: ink)),
              const Divider(height: 32, color: AppColors.brown),
              const Text(
                'Penghargaan internal aplikasi Sandi Pramuka. Ini bukan '
                'sertifikasi resmi Gerakan Pramuka.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ink, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        if (!profile.hasName) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Nama belum diatur'),
              subtitle:
                  const Text('Atur nama di Profil agar tercantum di sertifikat.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/profile'),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Simpan sertifikat dengan tangkapan layar (screenshot).',
          style: t.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRequirements(BuildContext context, CertificateStatus status) {
    final t = Theme.of(context);
    final s = status.stats;

    Widget row(bool ok, String title, String detail) => Card(
          elevation: 0,
          child: ListTile(
            leading: Icon(
              ok ? Icons.check_circle : Icons.radio_button_unchecked,
              color: ok ? Colors.green : t.colorScheme.outline,
            ),
            title: Text(title),
            subtitle: Text(detail),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Icon(Icons.workspace_premium,
              size: 72, color: t.colorScheme.primary),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('Sertifikat belum bisa diterbitkan',
              style: t.textTheme.titleLarge),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text('Penuhi dua syarat berikut.', textAlign: TextAlign.center),
        ),
        const SizedBox(height: 16),
        row(
          status.lessonsDone,
          'Selesaikan semua materi',
          '${s.completedLessons} dari ${s.totalLessons} materi selesai',
        ),
        row(
          status.quizzesDone,
          'Kerjakan minimal $certificateMinQuizzes kuis dengan rata-rata '
              '$certificateMinAverage',
          '${s.quizCount} kuis dikerjakan, rata-rata nilai ${s.averageScore}',
        ),
        const SizedBox(height: 8),
        Text(
          'Sertifikat ini penghargaan internal aplikasi, bukan sertifikasi '
          'resmi Gerakan Pramuka.',
          style: t.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/learn'),
                icon: const Icon(Icons.menu_book),
                label: const Text('Ke materi'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/exercises'),
                icon: const Icon(Icons.quiz),
                label: const Text('Ke kuis'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
