import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/cipher_catalog_seed.dart';
import '../../shared/widgets/cipher_logo.dart';
import '../../shared/widgets/coming_soon_view.dart';

class CipherDetailPage extends StatelessWidget {
  const CipherDetailPage({super.key, required this.cipherId});
  final String cipherId;

  @override
  Widget build(BuildContext context) {
    final cipher = findCipher(cipherId);
    final cat = findCategoryOf(cipherId);
    return Scaffold(
      appBar: AppBar(
        title: Text(cipher?.name ?? 'Sandi'),
        leading: BackButton(onPressed: () => context.go('/learn')),
      ),
      body: cipher == null
          ? const Center(child: Text('Sandi tidak ditemukan.'))
          : ComingSoonView(
              leading: CipherLogo(cipherId: cipher.id, size: 96),
              icon: Icons.menu_book,
              title: cipher.name,
              message:
                  'Kategori: ${cat?.name ?? '-'}.\nPengertian, tabel simbol, contoh, dan latihan ditambahkan di Tahap 2.',
              stage: 'Tahap 2 - Materi Sandi',
            ),
    );
  }
}
