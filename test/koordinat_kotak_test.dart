import 'package:flutter_test/flutter_test.dart';

import 'package:sandi_pramuka/services/ciphers/cipher.dart';
import 'package:sandi_pramuka/services/ciphers/koordinat_cipher.dart';
import 'package:sandi_pramuka/services/ciphers/kotak_cipher.dart';

const _o = CipherOptions();
const _gudep = CipherOptions(variantId: koordinatGudepSedia);

void main() {
  group('Koordinat', () {
    const c = KoordinatCipher();

    // Kode-kode ini ada pada contoh soal di bahan materi
    // (PRAMUKA ITU ASIK -> MI RI MP RT MH MT MP | AU HI MH | MP AI ...).
    test('cocok dengan contoh bahan materi', () {
      expect(c.encode('PRAMUKA', _o).output, 'MI RI MP RT MH MT MP');
      expect(c.encode('ITU', _o).output, 'AU HI MH');
      expect(c.encode('AS', _o).output, 'MP AI');
      expect(c.encode('R', _o).output, 'RI');
    });

    test('kata kunci terdiri dari lima huruf berbeda', () {
      for (final keys in koordinatKeys.values) {
        for (final k in keys) {
          expect(k.length, 5);
          expect(k.split('').toSet().length, 5, reason: k);
        }
      }
    });

    test('25 huruf punya kode unik di tiap varian', () {
      for (final v in koordinatKeys.keys) {
        final codes = [
          for (final ch in koordinatGrid.split('')) koordinatCode(ch, v)!,
        ];
        expect(codes.length, 25);
        expect(codes.toSet().length, 25, reason: v);
      }
    });

    test('varian GUDEP SEDIA', () {
      expect(c.encode('P', _gudep).output, 'GI');
      expect(c.encode('A', _gudep).output, 'GS');
      expect(c.encode('Y', _gudep).output, 'PA');
      expect(c.decode('GI', _gudep).output, 'P');
    });

    test('bolak-balik', () {
      for (final opts in [_o, _gudep]) {
        final enc = c.encode('SIAGA PRAMUKA', opts).output;
        expect(c.decode(enc, opts).output, 'SIAGA PRAMUKA');
      }
    });

    test('huruf Z dan karakter lain ditolak', () {
      final z = c.encode('Z', _o);
      expect(z.ok, isFalse);
      expect(z.error, contains('Z'));
      expect(c.encode('', _o).ok, isFalse);
      expect(c.encode('A1', _o).ok, isFalse);
      expect(c.decode('XX', _o).ok, isFalse);
      expect(c.decode('M', _o).ok, isFalse);
    });

    test('huruf kolom dan baris tidak boleh tertukar', () {
      // "IM" = kolom I (tidak ada), bukan baris I kolom M.
      expect(c.decode('IM', _o).ok, isFalse);
      expect(c.decode('MI', _o).output, 'P');
    });
  });

  group('Bentuk ruang Kotak', () {
    // Dicocokkan dengan gambar simbol pada bahan materi.
    test('sisi garis tiap ruang', () {
      expect(kotakCellSides(1), {'bottom', 'right'}); // A, B
      expect(kotakCellSides(2), {'bottom', 'left', 'right'}); // C, D
      expect(kotakCellSides(3), {'bottom', 'left'}); // E, F
      expect(kotakCellSides(4), {'top', 'bottom', 'right'}); // G/H, J/K
      expect(kotakCellSides(5), {'top', 'bottom', 'left', 'right'}); // I/J, M/N
      expect(kotakCellSides(6), {'top', 'bottom', 'left'}); // K/L, P/Q
      expect(kotakCellSides(7), {'top', 'right'}); // M, N
      expect(kotakCellSides(8), {'top', 'left', 'right'}); // O, P
      expect(kotakCellSides(9), {'top', 'left'}); // Q, R
    });

    test('kesembilan ruang punya bentuk berbeda', () {
      final shapes = {
        for (var n = 1; n <= 9; n++) (kotakCellSides(n).toList()..sort()).join(),
      };
      expect(shapes.length, 9);
    });
  });

  group('Kotak 1', () {
    const c = Kotak1Cipher();

    test('26 huruf, kode unik', () {
      expect(kotak1Codes.length, 26);
      expect(kotak1Codes.values.toSet().length, 26);
    });

    test('pasangan huruf dan titik', () {
      expect(c.encode('A', _o).output, 'K1');
      expect(c.encode('B', _o).output, 'K1.');
      expect(c.encode('G', _o).output, 'K4');
      expect(c.encode('H', _o).output, 'K4.');
      expect(c.encode('Q', _o).output, 'K9');
      expect(c.encode('R', _o).output, 'K9.');
    });

    test('tanda silang: atas UV, kiri ST, kanan WX, bawah YZ', () {
      expect(c.encode('U', _o).output, 'X1');
      expect(c.encode('V', _o).output, 'X1.');
      expect(c.encode('S', _o).output, 'X2');
      expect(c.encode('T', _o).output, 'X2.');
      expect(c.encode('W', _o).output, 'X3');
      expect(c.encode('X', _o).output, 'X3.');
      expect(c.encode('Y', _o).output, 'X4');
      expect(c.encode('Z', _o).output, 'X4.');
    });

    test('bolak-balik', () {
      final enc = c.encode('SIAGA PRAMUKA', _o).output;
      expect(c.decode(enc, _o).output, 'SIAGA PRAMUKA');
      expect(c.decode('k1 k1.', _o).output, 'AB');
    });

    test('validasi', () {
      expect(c.encode('', _o).ok, isFalse);
      expect(c.encode('A1', _o).ok, isFalse);
      expect(c.decode('K10', _o).ok, isFalse);
      expect(c.decode('X5', _o).ok, isFalse);
      expect(c.decode('K1..', _o).ok, isFalse);
      expect(c.decode('1', _o).ok, isFalse);
    });
  });

  group('Kotak 2', () {
    const c = Kotak2Cipher();

    test('26 huruf, kode unik', () {
      expect(kotak2Codes.length, 26);
      expect(kotak2Codes.values.toSet().length, 26);
    });

    test('jumlah titik menunjukkan urutan huruf dalam ruang', () {
      expect(c.encode('A', _o).output, 'K1');
      expect(c.encode('B', _o).output, 'K1.');
      expect(c.encode('C', _o).output, 'K1..');
      expect(c.encode('M', _o).output, 'K5');
      expect(c.encode('O', _o).output, 'K5..');
      expect(c.encode('Y', _o).output, 'K9');
      expect(c.encode('Z', _o).output, 'K9.');
    });

    test('bolak-balik', () {
      final enc = c.encode('PRAMUKA GARUDA', _o).output;
      expect(c.decode(enc, _o).output, 'PRAMUKA GARUDA');
    });

    test('validasi', () {
      expect(c.decode('K9..', _o).ok, isFalse); // ruang YZ hanya dua huruf
      expect(c.decode('X1', _o).ok, isFalse); // Kotak 2 tidak punya silang
      expect(c.decode('K1...', _o).ok, isFalse);
    });
  });
}
