import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/cipher_catalog_seed.dart';
import '../../core/constants/cipher_lessons.dart';
import '../../core/utils/progress_provider.dart';
import '../../shared/widgets/cipher_logo.dart';

String difficultyLabel(Difficulty d) => switch (d) {
      Difficulty.mudah => 'Mudah',
      Difficulty.sedang => 'Sedang',
      Difficulty.sulit => 'Sulit',
    };

class LearningPage extends ConsumerStatefulWidget {
  const LearningPage({super.key});

  @override
  ConsumerState<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends ConsumerState<LearningPage> {
  String _query = '';
  bool _onlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    final completed = ref.watch(completedProvider);
    final favorites = ref.watch(favoritesProvider);
    final t = Theme.of(context);

    final q = _query.trim().toLowerCase();
    final cats = <CipherCategoryInfo>[];
    for (final cat in cipherCategories) {
      final matches = cat.ciphers.where((c) {
        final okQuery = q.isEmpty || c.name.toLowerCase().contains(q);
        final okFav = !_onlyFavorites || favorites.contains(c.id);
        return okQuery && okFav;
      }).toList();
      if (matches.isNotEmpty) {
        cats.add(CipherCategoryInfo(cat.id, cat.name, matches));
      }
    }

    final doneCount = completed.where(hasLesson).length;
    final total = lessons.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Sandi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              hintText: 'Cari sandi...',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progres belajar: $doneCount dari $total materi',
                          style: t.textTheme.bodySmall),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: total == 0 ? 0 : doneCount / total,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Favorit'),
                  avatar: const Icon(Icons.star, size: 18),
                  selected: _onlyFavorites,
                  onSelected: (v) => setState(() => _onlyFavorites = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: cats.isEmpty
                ? Center(
                    child: Text(_onlyFavorites
                        ? 'Belum ada sandi favorit.'
                        : 'Sandi tidak ditemukan.'),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final cat in cats) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 4),
                          child: Row(children: [
                            CategoryLogo(categoryId: cat.id, size: 30),
                            const SizedBox(width: 10),
                            Text(cat.name, style: t.textTheme.titleMedium),
                          ]),
                        ),
                        for (final c in cat.ciphers)
                          Card(
                            elevation: 0,
                            child: ListTile(
                              leading: CipherLogo(cipherId: c.id, size: 44),
                              title: Text(c.name),
                              subtitle: Text(
                                '${difficultyLabel(c.difficulty)} - '
                                '${hasLesson(c.id) ? 'Materi tersedia' : 'Segera hadir'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (favorites.contains(c.id))
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 20),
                                  if (completed.contains(c.id))
                                    Icon(Icons.check_circle,
                                        color: t.colorScheme.primary,
                                        size: 20),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () => context.go('/learn/cipher/${c.id}'),
                            ),
                          ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
