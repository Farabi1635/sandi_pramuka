import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/audio_service.dart';
import '../../services/ciphers/cipher.dart';
import '../../services/ciphers/morse_cipher.dart';
import '../exercises/quiz_engine.dart';

class MorsePage extends StatefulWidget {
  const MorsePage({super.key});

  @override
  State<MorsePage> createState() => _MorsePageState();
}

class _MorsePageState extends State<MorsePage> {
  static const MorseCipher _cipher = MorseCipher();

  final AudioPlayer _player = AudioPlayer();
  final TextEditingController _text = TextEditingController(text: 'SIAGA');
  final TextEditingController _answer = TextEditingController();
  final Stopwatch _watch = Stopwatch();
  final Random _random = Random();

  Timer? _ticker;
  List<MorseSegment> _segments = const [];
  int _total = 0;
  double _wpm = 12;
  double _freq = 600;
  bool _playing = false;
  bool _paused = false;
  bool _lampOn = false;
  String? _target;
  String? _feedback;

  @override
  void dispose() {
    _ticker?.cancel();
    _player.dispose();
    _text.dispose();
    _answer.dispose();
    super.dispose();
  }

  Future<void> _start(String morse) async {
    final segments = buildMorseTimeline(morse, wpm: _wpm.round());
    if (segments.isEmpty) return;
    await _stop();
    final bytes = buildWav(segments, frequency: _freq.round());
    _segments = segments;
    _total = totalDurationMs(segments);
    if (!mounted) return;
    setState(() {
      _playing = true;
      _paused = false;
    });
    await _player.play(BytesSource(bytes));
    if (!mounted || !_playing) return;
    _watch
      ..reset()
      ..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 20), _tick);
  }

  void _tick(Timer timer) {
    final ms = _watch.elapsedMilliseconds;
    if (ms >= _total + 100) {
      unawaited(_stop());
      return;
    }
    final on = isOnAt(_segments, ms);
    if (on != _lampOn && mounted) setState(() => _lampOn = on);
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    _ticker = null;
    _watch
      ..stop()
      ..reset();
    await _player.stop();
    if (mounted) {
      setState(() {
        _playing = false;
        _paused = false;
        _lampOn = false;
      });
    }
  }

  Future<void> _pause() async {
    await _player.pause();
    _watch.stop();
    if (mounted) setState(() => _paused = true);
  }

  Future<void> _resume() async {
    await _player.resume();
    _watch.start();
    if (mounted) setState(() => _paused = false);
  }

  void _onMainButton(TranslationResult res) {
    if (!_playing) {
      if (res.ok) unawaited(_start(res.output));
    } else if (_paused) {
      unawaited(_resume());
    } else {
      unawaited(_pause());
    }
  }

  void _playRandomWord() {
    final word = practiceWords[_random.nextInt(practiceWords.length)];
    final res = _cipher.encode(word, const CipherOptions());
    setState(() {
      _target = word;
      _feedback = null;
      _answer.clear();
    });
    if (res.ok) unawaited(_start(res.output));
  }

  void _checkAnswer() {
    final target = _target;
    if (target == null) return;
    final guess = _answer.text.trim().toUpperCase();
    setState(() {
      _feedback = guess.isEmpty
          ? 'Ketik jawabanmu dulu.'
          : guess == target
              ? 'Benar! Katanya: $target'
              : 'Belum tepat, coba dengarkan lagi.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final res = _cipher.encode(_text.text, const CipherOptions());
    final dotMs = (1200 / _wpm).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Morse Audio'),
        leading: BackButton(onPressed: () => context.go('/exercises')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _text,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Teks yang akan dibunyikan',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: res.ok
                ? t.colorScheme.primary.withAlpha(25)
                : t.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SelectableText(
                res.ok ? res.output : (res.error ?? ''),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  color: res.ok ? null : t.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _lampOn ? Colors.amber : t.colorScheme.surfaceContainerHighest,
                boxShadow: _lampOn
                    ? [BoxShadow(color: Colors.amber.withAlpha(150), blurRadius: 24)]
                    : null,
              ),
              child: Icon(
                Icons.lightbulb,
                size: 48,
                color: _lampOn ? Colors.white : t.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _onMainButton(res),
                  icon: Icon(!_playing
                      ? Icons.play_arrow
                      : _paused
                          ? Icons.play_arrow
                          : Icons.pause),
                  label: Text(!_playing
                      ? 'Putar'
                      : _paused
                          ? 'Lanjut'
                          : 'Jeda'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _playing ? () => unawaited(_stop()) : null,
                icon: const Icon(Icons.stop),
                label: const Text('Berhenti'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Kecepatan: ${_wpm.round()} WPM', style: t.textTheme.titleSmall),
          Text(
            'Titik $dotMs ms, garis ${dotMs * 3} ms, jeda huruf ${dotMs * 3} ms, jeda kata ${dotMs * 7} ms',
            style: t.textTheme.bodySmall,
          ),
          Slider(
            value: _wpm,
            min: 5,
            max: 25,
            divisions: 20,
            label: '${_wpm.round()}',
            onChanged: _playing ? null : (v) => setState(() => _wpm = v),
          ),
          Text('Nada: ${_freq.round()} Hz', style: t.textTheme.titleSmall),
          Slider(
            value: _freq,
            min: 400,
            max: 1000,
            divisions: 12,
            label: '${_freq.round()}',
            onChanged: _playing ? null : (v) => setState(() => _freq = v),
          ),
          const Divider(height: 32),
          Text('Latihan mendengar', style: t.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Dengarkan kata acak, lalu ketik jawabanmu.',
            style: t.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _playRandomWord,
            icon: const Icon(Icons.shuffle),
            label: const Text('Putar kata acak'),
          ),
          if (_target != null) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _answer,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Jawabanmu',
              ),
              onSubmitted: (_) => _checkAnswer(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _checkAnswer,
                    child: const Text('Periksa'),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => setState(
                      () => _feedback = 'Jawabannya: ${_target ?? ''}'),
                  child: const Text('Lihat jawaban'),
                ),
              ],
            ),
            if (_feedback != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_feedback!, style: t.textTheme.titleSmall),
              ),
          ],
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => context.go('/learn/cipher/morse'),
            icon: const Icon(Icons.menu_book),
            label: const Text('Lihat tabel Morse'),
          ),
        ],
      ),
    );
  }
}
