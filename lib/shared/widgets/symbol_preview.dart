import 'package:flutter/material.dart';

import '../../core/constants/cipher_lessons.dart';
import 'cipher_symbol.dart';

/// Sandi yang punya gambar simbol per huruf.
const Set<String> visualCipherIds = {
  'braille',
  'semaphore',
  'rumput',
  'kotak1',
  'kotak2',
  'kotak3',
};

/// Menampilkan gambar simbol untuk setiap huruf pada [plainText],
/// dikelompokkan per kata.
class SymbolPreview extends StatelessWidget {
  const SymbolPreview({
    super.key,
    required this.cipherId,
    required this.plainText,
  });

  final String cipherId;
  final String plainText;

  static const int _maxLetters = 60;

  @override
  Widget build(BuildContext context) {
    if (!visualCipherIds.contains(cipherId)) return const SizedBox.shrink();
    final table = {for (final e in symbolEntries(cipherId)) e.key: e.value};

    final children = <Widget>[];
    var count = 0;
    var cut = false;
    for (final word in plainText.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final cells = <Widget>[];
      for (final ch in word.split('')) {
        final code = table[ch];
        if (code == null) continue;
        if (count >= _maxLetters) {
          cut = true;
          break;
        }
        cells.add(cipherSymbolWidget(cipherId, MapEntry(ch, code)));
        count++;
      }
      if (cells.isNotEmpty) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Wrap(spacing: 6, runSpacing: 6, children: cells),
        ));
      }
      if (cut) break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...children,
        if (cut)
          Text(
            'Hanya $_maxLetters huruf pertama yang digambar.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
