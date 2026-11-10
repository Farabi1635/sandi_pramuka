import 'package:flutter_test/flutter_test.dart';

import 'package:sandi_pramuka/core/constants/cipher_catalog_seed.dart';
import 'package:sandi_pramuka/core/constants/cipher_lessons.dart';
import 'package:sandi_pramuka/services/ciphers/cipher.dart';
import 'package:sandi_pramuka/services/translation_service.dart';

void main() {
  test('setiap materi punya sandi di katalog dan mesin penerjemah', () {
    for (final id in lessons.keys) {
      expect(findCipher(id), isNotNull, reason: 'katalog: $id');
      expect(cipherById(id), isNotNull, reason: 'mesin: $id');
    }
  });

  test('contoh materi bisa diterjemahkan bolak-balik', () {
    for (final entry in lessons.entries) {
      final engine = cipherById(entry.key)!;
      for (final ex in entry.value.examples) {
        final enc = engine.encode(ex.plain, ex.options);
        expect(enc.ok, isTrue, reason: '${entry.key} encode ${ex.plain}');
        final dec = engine.decode(enc.output, ex.options);
        expect(dec.output, ex.plain.toUpperCase(),
            reason: '${entry.key} decode ${enc.output}');
      }
    }
  });

  test('tabel simbol tersedia untuk sandi bertabel', () {
    for (final id in ['morse', 'an', 'az', 'geser', 'angka']) {
      expect(symbolEntries(id), isNotEmpty, reason: id);
    }
  });

  test('susunan kotak sesuai mesin Kotak Koordinat', () {
    final engine = cipherById('kotak_koordinat')!;
    for (var i = 0; i < kotakGrid.length; i++) {
      final expected = '${i ~/ 5 + 1}${i % 5 + 1}';
      expect(engine.encode(kotakGrid[i], const CipherOptions()).output,
          expected);
    }
  });
}
