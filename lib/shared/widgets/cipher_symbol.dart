import 'package:flutter/material.dart';

import 'braille_cell.dart';
import 'kotak_cell.dart';
import 'rumput_cell.dart';
import 'semaphore_cell.dart';

/// Kotak kecil untuk pasangan simbol: atas = huruf, bawah = kode.
class SymbolTile extends StatelessWidget {
  const SymbolTile({super.key, required this.top, required this.bottom});

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

/// Memilih tampilan simbol yang sesuai untuk tiap sandi.
Widget cipherSymbolWidget(String cipherId, MapEntry<String, String> e) {
  switch (cipherId) {
    case 'braille':
      return BrailleCell(letter: e.key, dots: e.value);
    case 'semaphore':
      return SemaphoreCell(letter: e.key, code: e.value);
    case 'rumput':
      return RumputCell(letter: e.key, code: e.value);
    case 'kotak1':
    case 'kotak2':
      return KotakCell(letter: e.key, code: e.value);
    default:
      return SymbolTile(top: e.key, bottom: e.value);
  }
}
