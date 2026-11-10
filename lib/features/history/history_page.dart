import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/quiz_history_provider.dart';
import '../../core/utils/translation_history_provider.dart';
import '../../services/translation_service.dart';
import '../../shared/widgets/cipher_logo.dart';

String formatDateTime(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus semua riwayat?'),
        content: const Text(
            'Riwayat penerjemahan dan nilai kuis di perangkat ini akan dihapus.'),
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
      await ref.read(translationHistoryProvider.notifier).clear();
      await ref.read(quizHistoryProvider.notifier).clear();
    }
  }

  Future<void> _copy(BuildContext context, String text) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(
      const SnackBar(content: Text('Hasil disalin ke papan klip.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(translationHistoryProvider);
    final quizzes = ref.watch(quizHistoryProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat'),
          actions: [
            IconButton(
              tooltip: 'Hapus semua riwayat',
              icon: const Icon(Icons.delete_outline),
              onPressed: (translations.isEmpty && quizzes.isEmpty)
                  ? null
                  : () => _confirmClear(context, ref),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Penerjemahan'), Tab(text: 'Kuis')],
          ),
        ),
        body: TabBarView(
          children: [
            translations.isEmpty
                ? const Center(child: Text('Belum ada riwayat penerjemahan.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: translations.length,
                    itemBuilder: (context, i) {
                      final r = translations[i];
                      return Card(
                        elevation: 0,
                        child: ListTile(
                          leading: CipherLogo(cipherId: r.cipherId, size: 40),
                          title: Text(r.output,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            '${cipherById(r.cipherId)?.name ?? r.cipherId} - '
                            '${r.mode == 'decode' ? 'Sandi ke Teks' : 'Teks ke Sandi'}\n'
                            'Asal: ${r.input}\n${formatDateTime(r.at)}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: 'Salin hasil',
                            icon: const Icon(Icons.copy),
                            onPressed: () => _copy(context, r.output),
                          ),
                        ),
                      );
                    },
                  ),
            quizzes.isEmpty
                ? const Center(child: Text('Belum ada kuis yang dikerjakan.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: quizzes.length,
                    itemBuilder: (context, i) {
                      final r = quizzes[i];
                      return Card(
                        elevation: 0,
                        child: ListTile(
                          leading: CipherLogo(cipherId: r.cipherId, size: 40),
                          title: Text(
                              '${cipherById(r.cipherId)?.name ?? r.cipherId} - Nilai ${r.score}'),
                          subtitle: Text(
                            '${r.level} - ${r.correct}/${r.total} benar - ${r.seconds} dtk\n'
                            '${formatDateTime(r.at)}',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
