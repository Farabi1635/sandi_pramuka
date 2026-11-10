import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/cipher_lessons.dart';
import 'progress_provider.dart';
import 'quiz_history_provider.dart';
import 'translation_history_provider.dart';

class AchievementStats {
  const AchievementStats({
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.translationCount = 0,
    this.quizCount = 0,
    this.bestScore = 0,
    this.bestMorseScore = 0,
    this.averageScore = 0,
  });

  final int completedLessons;
  final int totalLessons;
  final int translationCount;
  final int quizCount;
  final int bestScore;
  final int bestMorseScore;
  final int averageScore;

  double get lessonProgress =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
}

class AppBadge {
  const AppBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earned,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool earned;
}

List<AppBadge> computeBadges(AchievementStats s) => [
      AppBadge(
        id: 'pemula_sandi',
        title: 'Pemula Sandi',
        description: 'Selesaikan 1 materi sandi.',
        icon: Icons.eco,
        earned: s.completedLessons >= 1,
      ),
      AppBadge(
        id: 'rajin_belajar',
        title: 'Rajin Belajar',
        description: 'Selesaikan semua materi yang tersedia.',
        icon: Icons.menu_book,
        earned: s.totalLessons > 0 && s.completedLessons >= s.totalLessons,
      ),
      AppBadge(
        id: 'ahli_morse',
        title: 'Ahli Morse',
        description: 'Raih nilai 80 atau lebih pada kuis Morse.',
        icon: Icons.cell_tower,
        earned: s.bestMorseScore >= 80,
      ),
      AppBadge(
        id: 'pemecah_kode',
        title: 'Pemecah Kode',
        description: 'Lakukan 10 penerjemahan.',
        icon: Icons.vpn_key,
        earned: s.translationCount >= 10,
      ),
      AppBadge(
        id: 'juara_kuis',
        title: 'Juara Kuis',
        description: 'Raih nilai 100 pada sebuah kuis.',
        icon: Icons.emoji_events,
        earned: s.bestScore >= 100,
      ),
    ];

final achievementStatsProvider = Provider<AchievementStats>((ref) {
  final completed = ref.watch(completedProvider);
  final quizzes = ref.watch(quizHistoryProvider);
  final translations = ref.watch(translationHistoryProvider);

  var best = 0;
  var bestMorse = 0;
  var sum = 0;
  for (final q in quizzes) {
    sum += q.score;
    if (q.score > best) best = q.score;
    if (q.cipherId == 'morse' && q.score > bestMorse) bestMorse = q.score;
  }
  return AchievementStats(
    completedLessons: completed.where(hasLesson).length,
    totalLessons: lessons.length,
    translationCount: translations.length,
    quizCount: quizzes.length,
    bestScore: best,
    bestMorseScore: bestMorse,
    averageScore: quizzes.isEmpty ? 0 : (sum / quizzes.length).round(),
  );
});
