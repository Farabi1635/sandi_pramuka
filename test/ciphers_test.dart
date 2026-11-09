import 'package:flutter_test/flutter_test.dart';

import 'package:sandi_pramuka/services/ciphers/cipher.dart';
import 'package:sandi_pramuka/services/ciphers/letter_ciphers.dart';
import 'package:sandi_pramuka/services/ciphers/morse_cipher.dart';
import 'package:sandi_pramuka/services/ciphers/number_ciphers.dart';
import 'package:sandi_pramuka/services/translation_service.dart';

const _o = CipherOptions();

void main() {
  group('Morse', () {
    const c = MorseCipher();
    test('encode SOS', () {
      expect(c.encode('SOS', _o).output, '... --- ...');
    });
    test('encode beberapa kata', () {
      expect(c.encode('aku pramuka', _o).output,
          '.- -.- ..- / .--. .-. .- -- ..- -.- .-');
    });
    test('decode', () {
      expect(c.decode('... --- ...', _o).output, 'SOS');
      expect(c.decode('.- / -...', _o).output, 'A B');
    });
    test('angka dan bolak-balik', () {
      final enc = c.encode('PRAMUKA 2026', _o).output;
      expect(c.decode(enc, _o).output, 'PRAMUKA 2026');
    });
    test('validasi', () {
      expect(c.encode('', _o).ok, isFalse);
      expect(c.encode('#', _o).ok, isFalse);
      expect(c.decode('abc', _o).ok, isFalse);
      expect(c.decode('.-.-.-.-.-', _o).ok, isFalse);
    });
  });

  group('Sandi huruf', () {
    test('AN', () {
      const c = AnCipher();
      expect(c.encode('HELLO', _o).output, 'URYYB');
      expect(c.decode('URYYB', _o).output, 'HELLO');
    });
    test('AZ', () {
      const c = AzCipher();
      expect(c.encode('ABC', _o).output, 'ZYX');
      expect(c.decode('ZYX', _o).output, 'ABC');
    });
    test('Geser', () {
      const c = GeserCipher();
      expect(c.encode('ABC', _o).output, 'DEF');
      expect(c.encode('XYZ', _o).output, 'ABC');
      expect(c.decode('DEF', _o).output, 'ABC');
      expect(c.encode('Halo, Dunia!', const CipherOptions(shift: 1)).output,
          'Ibmp, Evojb!');
      expect(c.encode('A', const CipherOptions(shift: 0)).ok, isFalse);
    });
    test('Balik', () {
      const c = BalikCipher();
      expect(
          c.encode('ABC DEF',
              const CipherOptions(variantId: BalikCipher.variantText)).output,
          'FED CBA');
      expect(
          c.encode('ABC DEF',
              const CipherOptions(variantId: BalikCipher.variantWord)).output,
          'CBA FED');
    });
  });

  group('Sandi angka dan kotak', () {
    test('Angka', () {
      const c = AngkaCipher();
      expect(c.encode('ABC', _o).output, '1-2-3');
      expect(c.encode('A B', _o).output, '1 / 2');
      expect(c.decode('1-2-3 / 26', _o).output, 'ABC Z');
      expect(c.decode('27', _o).ok, isFalse);
      expect(c.encode('A1', _o).ok, isFalse);
    });
    test('Kotak Koordinat', () {
      const c = KotakKoordinatCipher();
      expect(c.encode('KAMU', _o).output, '25 11 32 45');
      expect(c.decode('25 11 32 45', _o).output, 'KAMU');
      expect(c.encode('J', _o).output, '24');
      expect(c.decode('66', _o).ok, isFalse);
    });
  });

  test('registry punya id unik', () {
    final ids = translatableCiphers.map((e) => e.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(cipherById('morse'), isNotNull);
    expect(cipherById('tidak-ada'), isNull);
  });
}
