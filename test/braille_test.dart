import 'package:flutter_test/flutter_test.dart';

import 'package:sandi_pramuka/services/ciphers/braille_cipher.dart';
import 'package:sandi_pramuka/services/ciphers/cipher.dart';

const _o = CipherOptions();

Set<String> _set(String dots) => dots.split('').toSet();

void main() {
  group('Pola Braille', () {
    test('26 huruf dengan pola unik', () {
      expect(brailleDots.length, 26);
      expect(brailleDots.values.toSet().length, 26);
    });

    test('K-T = A-J ditambah titik 3', () {
      const a = 'ABCDEFGHIJ';
      const k = 'KLMNOPQRST';
      for (var i = 0; i < 10; i++) {
        expect(_set(brailleDots[k[i]]!),
            {..._set(brailleDots[a[i]]!), '3'},
            reason: k[i]);
      }
    });

    test('U V X Y Z = A-E ditambah titik 3 dan 6, W = J + 6', () {
      const base = 'ABCDE';
      const target = 'UVXYZ';
      for (var i = 0; i < 5; i++) {
        expect(_set(brailleDots[target[i]]!),
            {..._set(brailleDots[base[i]]!), '3', '6'},
            reason: target[i]);
      }
      expect(_set(brailleDots['W']!), {..._set(brailleDots['J']!), '6'});
    });

    test('karakter Unicode sesuai standar', () {
      expect(dotsToUnicode('1'), '\u2801');
      expect(dotsToUnicode('145'), '\u2819');
      expect(dotsToUnicode('245'), '\u281A');
      expect(dotsToUnicode('1356'), '\u2835');
    });
  });

  group('BrailleCipher', () {
    const c = BrailleCipher();

    test('encode', () {
      expect(c.encode('ABC', _o).output, '1 12 14');
      expect(c.encode('A B', _o).output, '1 / 12');
    });

    test('decode nomor titik', () {
      expect(c.decode('1 12 14', _o).output, 'ABC');
      expect(c.decode('234 24 1 1245 1', _o).output, 'SIAGA');
      expect(c.decode('1 / 12', _o).output, 'A B');
    });

    test('urutan angka titik tidak berpengaruh', () {
      expect(c.decode('541', _o).output, 'D');
    });

    test('decode karakter Braille Unicode', () {
      expect(c.decode('\u2801\u2803\u2809', _o).output, 'ABC');
    });

    test('bolak-balik', () {
      final enc = c.encode('PRAMUKA GARUDA', _o).output;
      expect(c.decode(enc, _o).output, 'PRAMUKA GARUDA');
    });

    test('validasi', () {
      expect(c.encode('', _o).ok, isFalse);
      expect(c.encode('A1', _o).ok, isFalse);
      expect(c.decode('7', _o).ok, isFalse);
      expect(c.decode('112', _o).ok, isFalse);
      expect(c.decode('123456', _o).ok, isFalse);
    });
  });
}
