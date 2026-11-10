import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/dashboard_page.dart';
import '../../features/dictionary/dictionary_page.dart';
import '../../features/exercises/exercises_page.dart';
import '../../features/history/history_page.dart';
import '../../features/exercises/quiz_engine.dart';
import '../../features/exercises/quiz_page.dart';
import '../../features/morse/morse_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/learning/cipher_detail_page.dart';
import '../../features/learning/learning_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/translator/translator_page.dart';
import '../../shared/widgets/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const DashboardPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/learn',
            builder: (_, __) => const LearningPage(),
            routes: [
              GoRoute(
                path: 'cipher/:id',
                builder: (_, state) =>
                    CipherDetailPage(cipherId: state.pathParameters['id']!),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/translator',
            builder: (_, state) => TranslatorPage(
              initialCipherId: state.uri.queryParameters['cipher'],
            ),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/exercises',
            builder: (_, __) => const ExercisesPage(),
            routes: [
              GoRoute(
                path: 'quiz',
                builder: (_, state) {
                  final q = state.uri.queryParameters;
                  return QuizPage(
                    cipherId: q['cipher'] ?? 'morse',
                    level: QuizLevel.values.firstWhere(
                      (l) => l.name == q['level'],
                      orElse: () => QuizLevel.pemula,
                    ),
                    count: (int.tryParse(q['count'] ?? '') ?? 5).clamp(3, 10),
                  );
                },
              ),
              GoRoute(
                path: 'morse',
                builder: (_, __) => const MorsePage(),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfilePage(),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/dictionary',
      builder: (_, __) => const DictionaryPage(),
    ),
    GoRoute(
      path: '/history',
      builder: (_, __) => const HistoryPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
    body: Center(
      child: FilledButton(
        onPressed: () => context.go('/home'),
        child: const Text('Kembali ke Beranda'),
      ),
    ),
  ),
);
