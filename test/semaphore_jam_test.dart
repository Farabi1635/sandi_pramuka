import 'package:flutter_test/flutter_test.dart';

import 'package:sandi_pramuka/services/ciphers/cipher.dart';
import 'package:sandi_pramuka/services/ciphers/jam_cipher.dart';
import 'package:sandi_pramuka/services/ciphers/semaphore_cipher.dart';

const _o = CipherOptions();

/// Sudut antar dua lengan (derajat) untuk pasangan posisi 1-8.
/// Posisi dinomori melingkar, tiap nomor berjarak 45 derajat.
int _angle(String code) {
  final parts = code.split('.').map(int.parse).toList();
  var d = (parts[0] - parts[1]).abs() * 45;
  if (d > 180) d = 360 - d;
  return d;
}

void main() {
  group('Semaphore', () {
    const c = SemaphoreCipher();

    test('26 huruf, pasangan unik dan valid', () {
      expect(semaphoreCodes.length, 26);
      expect(semaphoreCodes.values.toSet().length, 26);
      for (final code in semaphoreCodes.values) {
        expect(normalizeSemaphoreCode(code), code);
      }
    });

    // Pengelompokan sudut berasal dari sumber terpisah (soal CEMC,
    // University of Waterloo), bukan dari tabel rumus di atas.
    test('sudut antar lengan sesuai sumber independen', () {
      const acute = 'AGHOTWZ';
      const right = 'BFIJNPUX';
      const obtuse = 'CEKMQSVY';
      const straight = 'DLR';
      for (final letter in semaphoreCodes.keys) {
        final angle = _angle(semaphoreCodes[letter]!);
        final expected = acute.contains(letter)
            ? 45
            : right.contains(letter)
                ? 90
                : obtuse.contains(letter)
                    ? 135
                    : straight.contains(letter)
                        ? 180
                        : -1;
        expect(angle, expected, reason: letter);
      }
    });

    test('encode', () {
      expect(c.encode('ABC', _o).output, '1.2 1.3 1.4');
      expect(c.encode('SIAGA', _o).output, '3.8 2.4 1.2 1.8 1.2');
      expect(c.encode('A B', _o).output, '1.2 / 1.3');
    });

    test('decode, urutan nomor tidak berpengaruh', () {
      expect(c.decode('3.8 2.4 1.2 1.8 1.2', _o).output, 'SIAGA');
      expect(c.decode('2.1 3.1', _o).output, 'AB');
      expect(c.decode('1.2 / 1.3', _o).output, 'A B');
    });

    test('bolak-balik', () {
      final enc = c.encode('PRAMUKA GARUDA', _o).output;
      expect(c.decode(enc, _o).output, 'PRAMUKA GARUDA');
    });

    test('validasi', () {
      expect(c.encode('', _o).ok, isFalse);
      expect(c.encode('A1', _o).ok, isFalse);
      expect(c.decode('1.1', _o).ok, isFalse);
      expect(c.decode('9.2', _o).ok, isFalse);
      expect(c.decode('12', _o).ok, isFalse);
      expect(c.decode('1.2.3', _o).ok, isFalse);
    });
  });

  group('Jam', () {
    const c = JamCipher();

    test('waktu tiap huruf', () {
      expect(jamTimeOf(0), '03.00');
      expect(jamTimeOf(1), '03.05');
      expect(jamTimeOf(11), '03.55');
      expect(jamTimeOf(12), '04.00');
      expect(jamTimeOf(25), '05.05');
    });

    test('encode dan decode', () {
      expect(c.encode('ABC', _o).output, '03.00 03.05 03.10');
      expect(c.encode('A M', _o).output, '03.00 / 04.00');
      expect(c.decode('03.00 03.05 03.10', _o).output, 'ABC');
      expect(c.decode('04.30 03.40 03.00 03.30 03.00', _o).output, 'SIAGA');
    });

    test('tanda titik dua juga diterima', () {
      expect(c.decode('3:00 04:00', _o).output, 'AM');
    });

    test('bolak-balik', () {
      final enc = c.encode('SALAM PRAMUKA', _o).output;
      expect(c.decode(enc, _o).output, 'SALAM PRAMUKA');
    });

    test('validasi', () {
      expect(c.encode('', _o).ok, isFalse);
      expect(c.encode('A1', _o).ok, isFalse);
      expect(c.decode('02.55', _o).ok, isFalse);
      expect(c.decode('05.10', _o).ok, isFalse);
      expect(c.decode('03.03', _o).ok, isFalse);
      expect(c.decode('03.60', _o).ok, isFalse);
      expect(c.decode('abc', _o).ok, isFalse);
    });
  });
}
