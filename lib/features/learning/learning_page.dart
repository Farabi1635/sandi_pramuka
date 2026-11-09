import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/cipher_catalog_seed.dart';
import '../../shared/widgets/cipher_logo.dart';

String difficultyLabel(Difficulty d) => switch (d) {
      Difficulty.mudah => 'Mudah',
      Difficulty.sedang => 'Sedang',
      Difficulty.sulit => 'Sulit',
    };

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final cats = <CipherCategoryInfo>[];
    for (final cat in cipherCategories) {
      final matches = cat.ciphers
          .where((c) => q.isEmpty || c.name.toLowerCase().contains(q))
          .toList();
      if (matches.isNotEmpty) {
        cats.add(CipherCategoryInfo(cat.id, cat.name, matches));
      }
    }

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
          Expanded(
            child: cats.isEmpty
                ? const Center(child: Text('Sandi tidak ditemukan.'))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final cat in cats) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 4),
                          child: Row(children: [
                            CategoryLogo(categoryId: cat.id, size: 30),
                            const SizedBox(width: 10),
                            Text(cat.name,
                                style: Theme.of(context).textTheme.titleMedium),
                          ]),
                        ),
                        for (final c in cat.ciphers)
                          Card(
                            elevation: 0,
                            child: ListTile(
                              leading: CipherLogo(cipherId: c.id, size: 44),
                              title: Text(c.name),
                              subtitle: Text(difficultyLabel(c.difficulty)),
                              trailing: const Icon(Icons.chevron_right),
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
