import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/settings_provider.dart';
import '../../services/ciphers/cipher.dart';
import '../../services/translation_service.dart';
import '../exercises/quiz_engine.dart';

/// Tantangan harian dari bank soal lokal (tanpa internet).
/// Soal sama sepanjang hari, berganti tiap hari.
class DailyChallengeCard extends ConsumerStatefulWidget {
  const DailyChallengeCard({super.key});

  @override
  ConsumerState<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends ConsumerState<DailyChallengeCard> {
  static const _prefsKey = 'daily_done';

  final TextEditingController _controller = TextEditingController();
  late final Cipher _cipher;
  late final CipherOptions _options;
  late final String _word;
  late final String _code;
  late final String _dayKey;
  bool _done = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dayKey = '${now.year}-${now.month}-${now.day}';
    final rnd = Random(now.year * 10000 + now.month * 100 + now.day);
    _cipher = translatableCiphers[rnd.nextInt(translatableCiphers.length)];
    _options = CipherOptions(
      variantId: _cipher.variants.isEmpty ? null : _cipher.variants.first.id,
      shift: 3,
    );
    final words = [
      ...quizWordBank[QuizLevel.pemula]!,
      ...quizWordBank[QuizLevel.menengah]!,
    ];
    _word = words[rnd.nextInt(words.length)];
    _code = _cipher.encode(_word, _options).output;
    _done = ref.read(sharedPrefsProvider).getString(_prefsKey) == _dayKey;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _cipherLabel {
    final extra = _cipher.usesShift
        ? ' (geser ${_options.shift})'
        : _cipher.variants.length > 1
            ? ' (${_cipher.variants.first.label})'
            : '';
    return '${_cipher.name}$extra';
  }

  Future<void> _check() async {
    final guess =
        _controller.text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    if (guess.isEmpty) {
      setState(() => _feedback = 'Ketik jawabanmu dulu.');
      return;
    }
    if (guess == _word) {
      setState(() {
        _done = true;
        _feedback = null;
      });
      await ref.read(sharedPrefsProvider).setString(_prefsKey, _dayKey);
    } else {
      setState(() => _feedback = 'Belum tepat, coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      elevation: 0,
      color: t.colorScheme.secondary.withAlpha(30),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag),
                const SizedBox(width: 8),
                Text('Tantangan hari ini', style: t.textTheme.titleMedium),
                const Spacer(),
                if (_done) const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            Text('Terjemahkan sandi $_cipherLabel:'),
            const SizedBox(height: 6),
            SelectableText(
              _code,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_done)
              Text('Selesai! Jawabannya: $_word',
                  style: t.textTheme.titleSmall)
            else ...[
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Jawabanmu',
                ),
                onSubmitted: (_) => _check(),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _check,
                child: const Text('Periksa'),
              ),
              if (_feedback != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_feedback!),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
