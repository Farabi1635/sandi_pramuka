import 'package:flutter_test/flutter_test.dart';

import 'package:sandi_pramuka/services/ciphers/cipher.dart';
import 'package:sandi_pramuka/services/ciphers/kimia_cipher.dart';
import 'package:sandi_pramuka/services/ciphers/morse_cipher.dart';
import 'package:sandi_pramuka/services/ciphers/rumput_cipher.dart';
import 'package:sandi_pramuka/services/ciphers/sungai_cipher.dart';

const _o = CipherOptions();

void main() {
  group('Kimia', () {
    const c = KimiaCipher();

    // Tiap rumus adalah Morse yang disamarkan: O dan A = titik,
    // H, S, dan N = garis. Pemeriksaan ini menangkap salah salin tabel.
    test('setiap rumus cocok dengan pola Morse huruf atau angkanya', () {
      for (final e in kimiaCodes.entries) {
        final seq = StringBuffer();
        for (final m in RegExp(r'([A-Z])(\d*)').allMatches(e.value)) {
          final el = m.group(1)!;
          final n = m.group(2)!.isEmpty ? 1 : int.parse(m.group(2)!);
          expect('OAHSN'.contains(el), isTrue, reason: '${e.key} ${e.value}');
          seq.write((el == 'O' || el == 'A' ? '.' : '-') * n);
        }
        expect(seq.toString(), morseTable[e.key], reason: e.key);
      }
    });

    test('rumus unik', () {
      expect(kimiaCodes.values.toSet().length, kimiaCodes.length);
    });

    test('encode', () {
      expect(c.encode('A', _o).output, 'OH');
      expect(c.encode('G', _o).output, 'H2O');
      expect(c.encode('SOS', _o).output, 'O3 S3 O3');
      expect(c.encode('A B', _o).output, 'OH / HO3');
      expect(c.encode('2024', _o).output, 'O2N3 N5 O2N3 O4N');
    });

    test('decode, angka 0 dibaca huruf O', () {
      expect(c.decode('O3 S3 O3', _o).output, 'SOS');
      expect(c.decode('H20', _o).output, 'G');
      expect(c.decode('OH / HO3', _o).output, 'A B');
      expect(c.decode('oh ho3', _o).output, 'AB');
    });

    test('bolak-balik', () {
      final enc = c.encode('PRAMUKA GARUDA 17', _o).output;
      expect(c.decode(enc, _o).output, 'PRAMUKA GARUDA 17');
    });

    test('validasi', () {
      expect(c.encode('', _o).ok, isFalse);
      expect(c.encode('#', _o).ok, isFalse);
      expect(c.decode('XYZ', _o).ok, isFalse);
      expect(c.decode('OH H2', _o).output, 'AM');
    });
  });

  group('Rumput', () {
    const c = RumputCipher();

    test('pola 26 huruf sama dengan Morse dan unik', () {
      expect(rumputCodes.length, 26);
      expect(rumputCodes.values.toSet().length, 26);
      for (final e in rumputCodes.entries) {
        final back = e.value.replaceAll('k', '.').replaceAll('B', '-');
        expect(back, morseTable[e.key], reason: e.key);
      }
    });

    test('encode dan decode', () {
      expect(c.encode('A', _o).output, 'kB');
      expect(c.encode('SOS', _o).output, 'kkk BBB kkk');
      expect(c.encode('A B', _o).output, 'kB / Bkkk');
      expect(c.decode('kB', _o).output, 'A');
      expect(c.decode('kb', _o).output, 'A');
      expect(c.decode('KB', _o).output, 'A');
      expect(c.decode('kkk BBB kkk', _o).output, 'SOS');
    });

    test('bolak-balik', () {
      final enc = c.encode('SIAGA PRAMUKA', _o).output;
      expect(c.decode(enc, _o).output, 'SIAGA PRAMUKA');
    });

    test('validasi', () {
      expect(c.encode('', _o).ok, isFalse);
      expect(c.encode('A1', _o).ok, isFalse);
      expect(c.decode('x', _o).ok, isFalse);
      expect(c.decode('kkkkkkk', _o).ok, isFalse);
    });
  });

  group('Sungai', () {
    const c = SungaiCipher();

    test('26 huruf berpasangan timbal balik', () {
      expect(sungaiPairs.length, 26);
      for (final e in sungaiPairs.entries) {
        expect(sungaiPairs[e.value], e.key, reason: e.key);
        expect(e.value == e.key, isFalse, reason: e.key);
      }
    });

    test('susunan kotak memuat 26 huruf tanpa ulang', () {
      final all = sungaiTop + sungaiBottom + sungaiLeft + sungaiRight;
      expect(all.length, 26);
      expect(all.split('').toSet().length, 26);
      expect(sungaiTop.startsWith('SUNGAI'), isTrue);
    });

    // Dua contoh di bawah diambil dari gambar bahan materi.
    test('contoh dari bahan materi', () {
      expect(c.encode('STELLAMARISJAYA', _o).output, 'TSYBBOIOUMTVOEO');
      expect(c.encode('LYUSOQPPRQPVOHOL', _o).output, 'BERTANGGUNGJAWAB');
      expect(c.decode('BERTANGGUNGJAWAB', _o).output, 'LYUSOQPPRQPVOHOL');
    });

    test('pasangan beberapa huruf', () {
      expect(c.encode('S', _o).output, 'T');
      expect(c.encode('E', _o).output, 'Y');
      expect(c.encode('A', _o).output, 'O');
      expect(c.encode('J', _o).output, 'V');
    });

    test('kata dipisah spasi dan bolak-balik', () {
      final enc = c.encode('SIAGA PRAMUKA', _o).output;
      expect(enc.contains(' '), isTrue);
      expect(c.decode(enc, _o).output, 'SIAGA PRAMUKA');
    });

    test('validasi', () {
      expect(c.encode('', _o).ok, isFalse);
      expect(c.encode('A1', _o).ok, isFalse);
    });
  });
}
