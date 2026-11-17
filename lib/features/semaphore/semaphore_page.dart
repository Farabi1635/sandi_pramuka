import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/ciphers/semaphore_cipher.dart';
import '../../shared/widgets/semaphore_figure.dart';
import 'semaphore_math.dart';

List<int> _positionsOf(String letter) {
  final parts = semaphoreCodes[letter]!.split('.');
  return [int.parse(parts[0]), int.parse(parts[1])];
}

class SemaphorePage extends StatelessWidget {
  const SemaphorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Semaphore'),
          leading: BackButton(onPressed: () => context.go('/exercises')),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Belajar'),
              Tab(text: 'Animasi kata'),
              Tab(text: 'Tebak'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_LearnTab(), _WordTab(), _GuessTab()],
        ),
      ),
    );
  }
}

/// Gambar orang yang lengannya bergerak halus ke pasangan posisi berikutnya.
class SemaphoreStage extends StatefulWidget {
  const SemaphoreStage({super.key, this.height = 240});

  final double height;

  @override
  State<SemaphoreStage> createState() => SemaphoreStageState();
}

class SemaphoreStageState extends State<SemaphoreStage>
    with SingleTickerProviderStateMixin {
  static const Duration moveDuration = Duration(milliseconds: 650);

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: moveDuration);
  ArmAngles _from = restPose;
  ArmAngles _to = restPose;

  ArmAngles get _current {
    final t = Curves.easeInOut.transform(_controller.value);
    return ArmAngles(
      lerpAngle(_from.a, _to.a, t),
      lerpAngle(_from.b, _to.b, t),
    );
  }

  /// Menggerakkan kedua lengan ke posisi [p] dan [q]. Selesai setelah
  /// gerakan berakhir.
  Future<void> moveTo(int p, int q) async {
    final now = _current;
    _from = now;
    _to = assignArms(now, p, q);
    _controller.forward(from: 0);
    await Future<void>.delayed(moveDuration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pose = _current;
        return SemaphoreFigure(
            left: pose.a, right: pose.b, height: widget.height);
      },
    );
  }
}

class _LearnTab extends StatefulWidget {
  const _LearnTab();

  @override
  State<_LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<_LearnTab> {
  final GlobalKey<SemaphoreStageState> _stage = GlobalKey();
  String? _selected;

  void _select(String letter) {
    setState(() => _selected = letter);
    final p = _positionsOf(letter);
    _stage.currentState?.moveTo(p[0], p[1]);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final letter = _selected;
    String info = 'Pilih huruf di bawah untuk melihat posisi lengannya.';
    if (letter != null) {
      final p = _positionsOf(letter);
      info = '$letter = ${semaphoreCodes[letter]}\n'
          'Posisi ${p[0]} (${semaphorePositionNames[p[0] - 1]}) dan '
          '${p[1]} (${semaphorePositionNames[p[1] - 1]}).';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: SemaphoreStage(key: _stage)),
        const SizedBox(height: 12),
        Text(info, textAlign: TextAlign.center, style: t.textTheme.titleSmall),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            for (final l in semaphoreCodes.keys)
              ChoiceChip(
                label: Text(l),
                selected: _selected == l,
                onSelected: (_) => _select(l),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Gambar dilihat dari depan: nomor 2, 3, dan 4 ada di sisi kiri gambar.',
          style: t.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _WordTab extends StatefulWidget {
  const _WordTab();

  @override
  State<_WordTab> createState() => _WordTabState();
}

class _WordTabState extends State<_WordTab> {
  final GlobalKey<SemaphoreStageState> _stage = GlobalKey();
  final TextEditingController _controller =
      TextEditingController(text: 'SIAGA');

  int _runId = 0;
  bool _playing = false;
  int _index = -1;
  List<String> _chars = const [];
  String? _message;
  int _speed = 1; // 0 lambat, 1 sedang, 2 cepat

  static const List<int> _holdMs = [1100, 700, 400];

  @override
  void dispose() {
    _runId++;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    final chars = _controller.text
        .toUpperCase()
        .split('')
        .where((c) => c == ' ' || semaphoreCodes.containsKey(c))
        .toList();
    if (chars.where((c) => c != ' ').isEmpty) {
      setState(() => _message = 'Ketik minimal satu huruf A-Z.');
      return;
    }

    final run = ++_runId;
    setState(() {
      _message = null;
      _playing = true;
      _chars = chars;
      _index = -1;
    });

    for (var i = 0; i < chars.length; i++) {
      if (!mounted || run != _runId) return;
      setState(() => _index = i);
      final ch = chars[i];
      if (ch == ' ') {
        await _stage.currentState?.moveTo(1, 1);
        await Future<void>.delayed(const Duration(milliseconds: 300));
      } else {
        final p = _positionsOf(ch);
        await _stage.currentState?.moveTo(p[0], p[1]);
        await Future<void>.delayed(Duration(milliseconds: _holdMs[_speed]));
      }
    }

    if (!mounted || run != _runId) return;
    await _stage.currentState?.moveTo(1, 1);
    if (!mounted || run != _runId) return;
    setState(() {
      _playing = false;
      _index = -1;
    });
  }

  void _stop() {
    _runId++;
    setState(() {
      _playing = false;
      _index = -1;
    });
    _stage.currentState?.moveTo(1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: SemaphoreStage(key: _stage)),
        const SizedBox(height: 12),
        if (_chars.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children: [
              for (var i = 0; i < _chars.length; i++)
                Container(
                  width: _chars[i] == ' ' ? 14 : 28,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: i == _index
                        ? t.colorScheme.primary
                        : t.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _chars[i] == ' ' ? '' : _chars[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: i == _index
                          ? t.colorScheme.onPrimary
                          : t.colorScheme.onSurface,
                    ),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          enabled: !_playing,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Kata yang akan dibawakan',
            hintText: 'Contoh: SIAGA PRAMUKA',
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Lambat')),
            ButtonSegment(value: 1, label: Text('Sedang')),
            ButtonSegment(value: 2, label: Text('Cepat')),
          ],
          selected: {_speed},
          onSelectionChanged: (s) => setState(() => _speed = s.first),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _playing ? _stop : _play,
          icon: Icon(_playing ? Icons.stop : Icons.play_arrow),
          label: Text(_playing ? 'Berhenti' : 'Putar animasi'),
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_message!, style: t.textTheme.bodyMedium),
          ),
        const SizedBox(height: 8),
        Text(
          'Spasi ditampilkan sebagai jeda dengan kedua lengan di bawah.',
          style: t.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _GuessTab extends StatefulWidget {
  const _GuessTab();

  @override
  State<_GuessTab> createState() => _GuessTabState();
}

class _GuessTabState extends State<_GuessTab> {
  final GlobalKey<SemaphoreStageState> _stage = GlobalKey();
  final Random _random = Random();

  String _target = 'A';
  List<String> _options = const [];
  String? _picked;
  int _correct = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _next();
    });
  }

  void _next() {
    final letters = semaphoreCodes.keys.toList();
    final target = letters[_random.nextInt(letters.length)];
    final others = letters.where((l) => l != target).toList()
      ..shuffle(_random);
    final options = [target, ...others.take(3)]..shuffle(_random);
    setState(() {
      _target = target;
      _options = options;
      _picked = null;
    });
    final p = _positionsOf(target);
    _stage.currentState?.moveTo(p[0], p[1]);
  }

  void _answer(String letter) {
    if (_picked != null) return;
    setState(() {
      _picked = letter;
      _total++;
      if (letter == _target) _correct++;
    });
  }

  void _reset() {
    setState(() {
      _correct = 0;
      _total = 0;
    });
    _next();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final answered = _picked != null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text('Benar $_correct dari $_total',
                style: t.textTheme.titleSmall),
            const Spacer(),
            TextButton(onPressed: _reset, child: const Text('Ulangi')),
          ],
        ),
        Center(child: SemaphoreStage(key: _stage)),
        const SizedBox(height: 8),
        Text('Huruf apa ini?',
            textAlign: TextAlign.center, style: t.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final o in _options)
              SizedBox(
                width: 72,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: !answered
                        ? null
                        : o == _target
                            ? Colors.green.withAlpha(60)
                            : o == _picked
                                ? Colors.red.withAlpha(60)
                                : null,
                  ),
                  onPressed: answered ? null : () => _answer(o),
                  child: Text(o,
                      style: TextStyle(
                          fontSize: 20, color: t.colorScheme.onSurface)),
                ),
              ),
          ],
        ),
        if (answered) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _picked == _target
                    ? 'Benar! $_target = ${semaphoreCodes[_target]}'
                    : 'Belum tepat. Ini huruf $_target = ${semaphoreCodes[_target]}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _next, child: const Text('Soal berikutnya')),
        ],
      ],
    );
  }
}
