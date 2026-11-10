import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/cipher_catalog_seed.dart';
import '../../core/constants/cipher_lessons.dart';
import '../../core/utils/progress_provider.dart';
import '../../services/translation_service.dart';
import '../../shared/widgets/braille_cell.dart';
import '../../shared/widgets/cipher_logo.dart';
import '../../shared/widgets/coming_soon_view.dart';
import 'learning_page.dart';

class CipherDetailPage extends ConsumerWidget {
  const CipherDetailPage({super.key, required this.cipherId});
  final String cipherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cipher = findCipher(cipherId);
    final cat = findCategoryOf(cipherId);
    final lesson = lessons[cipherId];
    final done = ref.watch(completedProvider).contains(cipherId);
    final fav = ref.watch(favoritesProvider).contains(cipherId);
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(cipher?.name ?? 'Sandi'),
        leading: BackButton(onPressed: () => context.go('/learn')),
        actions: [
          if (cipher != null)
            IconButton(
              tooltip: fav ? 'Hapus dari favorit' : 'Tambah ke favorit',
              icon: Icon(fav ? Icons.star : Icons.star_border,
                  color: fav ? Colors.amber : null),
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).toggle(cipherId),
            ),
        ],
      ),
      body: cipher == null
          ? const Center(child: Text('Sandi tidak ditemukan.'))
          : lesson == null
              ? ComingSoonView(
                  leading: CipherLogo(cipherId: cipher.id, size: 96),
                  icon: Icons.menu_book,
                  title: cipher.name,
                  message: 'Kategori: ${cat?.name ?? '-'}.\n'
                      'Materi sandi ini belum tersedia. Sandi bergambar '
                      'ditambahkan setelah aturan dan tabel simbolnya diverifikasi.',
                  stage: 'Segera hadir',
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        CipherLogo(cipherId: cipher.id, size: 72),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cipher.name,
                                  style: t.textTheme.headlineSmall),
                              Text(cat?.name ?? '',
                                  style: t.textTheme.bodySmall),
                              const SizedBox(height: 6),
                              Chip(
                                label: Text(difficultyLabel(cipher.difficulty)),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _Section(title: 'Pengertian', children: [
                      Text(lesson.definition),
                    ]),
                    _Section(title: 'Fungsi', children: [
                      Text(lesson.purpose),
                    ]),
                    if (lesson.history != null)
                      _Section(title: 'Sejarah / Referensi', children: [
                        Text(lesson.history!),
                      ]),
                    _Section(title: 'Cara membaca', children: [
                      for (var i = 0; i < lesson.steps.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 11,
                                child: Text('${i + 1}',
                                    style: const TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(lesson.steps[i])),
                            ],
                          ),
                        ),
                    ]),
                    if (cipherId == 'kotak_koordinat')
                      const _Section(title: 'Tabel simbol', children: [
                        _KotakTable(),
                      ])
                    else if (symbolEntries(cipherId).isNotEmpty)
                      _Section(title: 'Tabel simbol', children: [
                        if (lesson.tableCaption != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(lesson.tableCaption!,
                                style: t.textTheme.bodySmall),
                          ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final e in symbolEntries(cipherId))
                              cipherId == 'braille'
                                  ? BrailleCell(letter: e.key, dots: e.value)
                                  : _SymbolTile(top: e.key, bottom: e.value),
                          ],
                        ),
                      ]),
                    _Section(title: 'Contoh penerjemahan', children: [
                      for (final ex in lesson.examples)
                        _ExampleCard(cipherId: cipherId, example: ex),
                    ]),
                    _Section(title: 'Kesalahan umum', children: [
                      for (final m in lesson.mistakes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(m)),
                            ],
                          ),
                        ),
                    ]),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.go('/translator?cipher=$cipherId'),
                      icon: const Icon(Icons.translate),
                      label: const Text('Coba di Penerjemah'),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () =>
                          ref.read(completedProvider.notifier).toggle(cipherId),
                      icon: Icon(done ? Icons.check_circle : Icons.check),
                      label: Text(done
                          ? 'Selesai (ketuk untuk batalkan)'
                          : 'Tandai selesai'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SymbolTile extends StatelessWidget {
  const _SymbolTile({required this.top, required this.bottom});
  final String top;
  final String bottom;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.colorScheme.primary.withAlpha(22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(top,
              style: t.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(bottom,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.cipherId, required this.example});
  final String cipherId;
  final LessonExample example;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final engine = cipherById(cipherId);
    final res = engine?.encode(example.plain, example.options);
    final code = (res != null && res.ok) ? res.output : '-';
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (example.label != null)
              Text(example.label!, style: t.textTheme.labelMedium),
            Text('Teks: ${example.plain}'),
            const SizedBox(height: 4),
            Text('Sandi: $code',
                style: const TextStyle(
                    fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _KotakTable extends StatelessWidget {
  const _KotakTable();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    Widget cell(String s, {bool header = false}) => Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Text(
              s,
              style: header
                  ? t.textTheme.labelLarge
                  : t.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );

    return Table(
      border: TableBorder.all(color: t.colorScheme.outlineVariant),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            cell('', header: true),
            for (var c = 1; c <= 5; c++) cell('$c', header: true),
          ],
        ),
        for (var r = 0; r < 5; r++)
          TableRow(
            children: [
              cell('${r + 1}', header: true),
              for (var c = 0; c < 5; c++) cell(kotakGrid[r * 5 + c]),
            ],
          ),
      ],
    );
  }
}
