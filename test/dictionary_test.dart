import 'package:flutter_test/flutter_test.dart';

import 'package:sandi_pramuka/features/dictionary/dictionary_lookup.dart';

Map<String, String> _byCipher(List<DictionaryHit> hits) => {
      for (final h in hits) h.cipherId: h.value,
    };

void main() {
  group('Kamus: simbol ke kode', () {
    test('huruf A di tiap sandi', () {
      final m = _byCipher(lookupSymbol('A'));
      expect(m['morse'], '.-');
      expect(m['angka'], '1');
      expect(m['kotak_koordinat'], '11');
      expect(m['braille'], '1');
      expect(m['an'], 'N');
      expect(m['az'], 'Z');
      expect(m['geser'], 'D');
      expect(m.containsKey('balik'), isFalse);
    });

    test('huruf kecil diperlakukan sama', () {
      expect(_byCipher(lookupSymbol('a'))['morse'], '.-');
    });

    test('angka hanya ada di sandi yang mendukungnya', () {
      final m = _byCipher(lookupSymbol('5'));
      expect(m['morse'], '.....');
      expect(m.containsKey('angka'), isFalse);
      expect(m.containsKey('an'), isFalse);
      expect(m.containsKey('geser'), isFalse);
    });

    test('lebih dari satu karakter tidak dicari sebagai simbol', () {
      expect(lookupSymbol('AB'), isEmpty);
      expect(lookupSymbol(''), isEmpty);
    });
  });

  group('Kamus: kode ke arti', () {
    test('kode Morse', () {
      expect(_byCipher(lookupCode('.-'))['morse'], 'A');
      expect(_byCipher(lookupCode('... --- ...'))['morse'], 'SOS');
    });

    test('dua angka bisa berarti dua hal berbeda', () {
      final m = _byCipher(lookupCode('25'));
      expect(m['angka'], 'Y');
      expect(m['kotak_koordinat'], 'K');
      expect(m.containsKey('braille'), isFalse);
    });

    test('nomor titik Braille', () {
      final m = _byCipher(lookupCode('145'));
      expect(m['braille'], 'D');
      expect(m.containsKey('angka'), isFalse);
    });

    test('kode tidak dikenal tidak menghasilkan apa pun', () {
      expect(lookupCode('abc'), isEmpty);
      expect(lookupCode('   '), isEmpty);
    });
  });
}
