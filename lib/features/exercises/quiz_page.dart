import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/quiz_history_provider.dart';
import '../../services/ciphers/cipher.dart';
import '../../services/translation_service.dart';
import 'quiz_engine.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({
    super.key,
    required this.cipherId,
    required this.level,
    required this.count,
  });

  final String cipherId;
  final QuizLevel level;
  final int count;

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  late Cipher _cipher;
  late CipherOptions _options;
  late List<QuizQuestion> _questions;
  final List<int> _answers = [];
  Timer? _timer;
  int _index = 0;
  int? _selected;
  int _correct = 0;
  int _seconds = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _cipher = cipherById(widget.cipherId) ?? translatableCiphers.first;
    _options = CipherOptions(
      variantId: _cipher.variants.isEmpty ? null : _cipher.variants.first.id,
      shift: 3,
    );
    _setup();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_finished && mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setup() {
    _questions = generateQuiz(
      cipher: _cipher,
      options: _options,
      level: widget.level,
      count: widget.count,
    );
    _answers.clear();
    _index = 0;
    _selected = null;
    _correct = 0;
    _seconds = 0;
    _finished = false;
  }

  String get _header {
    final extra = _cipher.usesShift
        ? ' (geser ${_options.shift})'
        : _cipher.variants.length > 1
            ? ' (${_cipher.variants.first.label})'
            : '';
    return '${_cipher.name}$extra';
  }

  String _time(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  void _choose(int i) {
    if (_selected != null) return;
    setState(() {
      _selected = i;
      _answers.add(i);
      if (i == _questions[_index].correctIndex) _correct++;
    });
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      setState(() => _finished = true);
      ref.read(quizHistoryProvider.notifier).add(
            QuizResult(
              cipherId: _cipher.id,
              level: levelLabel(widget.level),
              correct: _correct,
              total: _questions.length,
              seconds: _seconds,
              at: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    } else {
      setState(() {
        _index++;
        _selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_finished ? 'Hasil Kuis' : 'Kuis ${levelLabel(widget.level)}'),
        leading: BackButton(onPressed: () => context.go('/exercises')),
      ),
      body: _finished ? _buildResult(context) : _buildQuestion(context),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final t = Theme.of(context);
    final q = _questions[_index];
    final answered = _selected != null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_header, style: t.textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Soal ${_index + 1}/${_questions.length}',
                style: t.textTheme.titleSmall),
            const Spacer(),
            const Icon(Icons.timer_outlined, size: 18),
            const SizedBox(width: 4),
            Text(_time(_seconds)),
            const SizedBox(width: 16),
            const Icon(Icons.check_circle_outline, size: 18),
            const SizedBox(width: 4),
            Text('$_correct'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_index + (answered ? 1 : 0)) / _questions.length,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 20),
        Text(q.prompt, style: t.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: t.colorScheme.primary.withAlpha(25),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              q.shown,
              style: t.textTheme.titleLarge?.copyWith(
                fontFamily: q.kind == QuizKind.codeToText ? 'monospace' : null,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                minimumSize: const Size.fromHeight(52),
                backgroundColor: !answered
                    ? null
                    : i == q.correctIndex
                        ? Colors.green.withAlpha(60)
                        : i == _selected
                            ? Colors.red.withAlpha(60)
                            : null,
              ),
              onPressed: answered ? null : () => _choose(i),
              child: Text(
                q.options[i],
                style: TextStyle(
                  fontFamily: q.kind == QuizKind.textToCode ? 'monospace' : null,
                  color: t.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        if (answered) ...[
          const SizedBox(height: 4),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected == q.correctIndex ? 'Benar!' : 'Belum tepat.',
                    style: t.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text('Pembahasan: ${q.explanation}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _next,
            child: Text(
                _index + 1 >= _questions.length ? 'Lihat hasil' : 'Lanjut'),
          ),
        ],
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final t = Theme.of(context);
    final total = _questions.length;
    final score = total == 0 ? 0 : (_correct * 100 / total).round();
    final message = score >= 80
        ? 'Hebat, pertahankan!'
        : score >= 50
            ? 'Bagus, terus berlatih.'
            : 'Ayo ulangi dan pelajari materinya lagi.';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_header, style: t.textTheme.bodySmall),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: t.colorScheme.primary.withAlpha(25),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('$score', style: t.textTheme.displayMedium),
                Text('Nilai akhir', style: t.textTheme.bodySmall),
                const SizedBox(height: 8),
                Text('$_correct dari $total benar - waktu ${_time(_seconds)}'),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Pembahasan', style: t.textTheme.titleMedium),
        const SizedBox(height: 4),
        for (var i = 0; i < total; i++)
          Card(
            elevation: 0,
            child: ListTile(
              leading: Icon(
                _answers[i] == _questions[i].correctIndex
                    ? Icons.check_circle
                    : Icons.cancel,
                color: _answers[i] == _questions[i].correctIndex
                    ? Colors.green
                    : Colors.red,
              ),
              title: Text(_questions[i].explanation),
              subtitle: _answers[i] == _questions[i].correctIndex
                  ? null
                  : Text('Jawabanmu: ${_questions[i].options[_answers[i]]}'),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => setState(_setup),
          icon: const Icon(Icons.replay),
          label: const Text('Ulangi kuis'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => context.go('/exercises'),
          child: const Text('Selesai'),
        ),
      ],
    );
  }
}
