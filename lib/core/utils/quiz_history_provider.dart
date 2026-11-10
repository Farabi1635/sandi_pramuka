import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_provider.dart';

class QuizResult {
  const QuizResult({
    required this.cipherId,
    required this.level,
    required this.correct,
    required this.total,
    required this.seconds,
    required this.at,
  });

  final String cipherId;
  final String level;
  final int correct;
  final int total;
  final int seconds;
  final int at;

  int get score => total == 0 ? 0 : (correct * 100 / total).round();

  Map<String, Object> toJson() => {
        'cipherId': cipherId,
        'level': level,
        'correct': correct,
        'total': total,
        'seconds': seconds,
        'at': at,
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        cipherId: json['cipherId'] as String,
        level: json['level'] as String,
        correct: json['correct'] as int,
        total: json['total'] as int,
        seconds: json['seconds'] as int,
        at: json['at'] as int,
      );
}

/// Riwayat nilai kuis (disimpan lokal, terbaru di depan, maksimal 50).
class QuizHistoryNotifier extends Notifier<List<QuizResult>> {
  static const _key = 'quiz_results';

  @override
  List<QuizResult> build() {
    final raw = ref.read(sharedPrefsProvider).getStringList(_key) ??
        const <String>[];
    final out = <QuizResult>[];
    for (final s in raw) {
      try {
        out.add(QuizResult.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // Lewati data rusak.
      }
    }
    return out;
  }

  Future<void> _save(List<QuizResult> list) async {
    state = list;
    await ref
        .read(sharedPrefsProvider)
        .setStringList(_key, [for (final r in list) jsonEncode(r.toJson())]);
  }

  Future<void> add(QuizResult r) async {
    final next = [r, ...state];
    if (next.length > 50) next.removeRange(50, next.length);
    await _save(next);
  }

  Future<void> clear() => _save(const []);
}

final quizHistoryProvider =
    NotifierProvider<QuizHistoryNotifier, List<QuizResult>>(
        QuizHistoryNotifier.new);
