import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/quiz_history_provider.dart';
import '../../services/ciphers/cipher.dart';
import '../../services/translation_service.dart';
import '../../shared/widgets/cipher_logo.dart';
import 'quiz_engine.dart';

class ExercisesPage extends ConsumerStatefulWidget {
  const ExercisesPage({super.key});

  @override
  ConsumerState<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends ConsumerState<ExercisesPage> {
  Cipher _cipher = translatableCiphers.first;
  QuizLevel _level = QuizLevel.pemula;
  int _count = 5;

  String _date(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day}/${d.month}/${d.year}';
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus riwayat nilai?'),
        content: const Text('Seluruh riwayat kuis di perangkat ini akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(quizHistoryProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final history = ref.watch(quizHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Latihan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: ListTile(
              leading: const CipherLogo(cipherId: 'morse', size: 44),
              title: const Text('Morse Audio'),
              subtitle: const Text(
                  'Dengarkan Morse, lampu berkedip, dan latihan mendengar.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/exercises/morse'),
            ),
          ),
          const SizedBox(height: 20),
          Text('Kuis sandi', style: t.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Soal dibuat otomatis dari aturan sandi, jadi jawabannya selalu benar.',
            style: t.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          DropdownMenu<String>(
            key: ValueKey('quiz-${_cipher.id}'),
            label: const Text('Jenis sandi'),
            initialSelection: _cipher.id,
            expandedInsets: EdgeInsets.zero,
            requestFocusOnTap: false,
            dropdownMenuEntries: [
              for (final c in translatableCiphers)
                DropdownMenuEntry<String>(value: c.id, label: c.name),
            ],
            onSelected: (id) {
              final c = id == null ? null : cipherById(id);
              if (c != null) setState(() => _cipher = c);
            },
          ),
          const SizedBox(height: 12),
          Text('Level', style: t.textTheme.labelLarge),
          const SizedBox(height: 6),
          SegmentedButton<QuizLevel>(
            segments: [
              for (final l in QuizLevel.values)
                ButtonSegment(value: l, label: Text(levelLabel(l))),
            ],
            selected: {_level},
            onSelectionChanged: (s) => setState(() => _level = s.first),
          ),
          const SizedBox(height: 12),
          Text('Jumlah soal', style: t.textTheme.labelLarge),
          const SizedBox(height: 6),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 5, label: Text('5')),
              ButtonSegment(value: 10, label: Text('10')),
            ],
            selected: {_count},
            onSelectionChanged: (s) => setState(() => _count = s.first),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go(
              '/exercises/quiz?cipher=${_cipher.id}&level=${_level.name}&count=$_count',
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Mulai kuis'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text('Riwayat nilai', style: t.textTheme.titleMedium),
              ),
              if (history.isNotEmpty)
                TextButton(
                  onPressed: _confirmClear,
                  child: const Text('Hapus'),
                ),
            ],
          ),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Belum ada kuis yang dikerjakan.'),
            )
          else
            for (final r in history.take(10))
              Card(
                elevation: 0,
                child: ListTile(
                  leading: CipherLogo(cipherId: r.cipherId, size: 36),
                  title: Text(
                      '${cipherById(r.cipherId)?.name ?? r.cipherId} - Nilai ${r.score}'),
                  subtitle: Text(
                      '${r.level} - ${r.correct}/${r.total} benar - ${r.seconds} dtk - ${_date(r.at)}'),
                ),
              ),
        ],
      ),
    );
  }
}
