import 'package:flutter_test/flutter_test.dart';

import 'package:sandi_pramuka/services/ciphers/cipher.dart';
import 'package:sandi_pramuka/services/ciphers/kotak3_cipher.dart';

const _o = CipherOptions();

String _key(List<String> rays) => (List.of(rays)..sort()).join('+');

void main() {
  group('Struktur gambar kunci', () {
    // Tiap sudut persegi tengah punya enam sinar. Ruang = sektor di antara dua
    // sinar berurutan. Urutan huruf dibaca dari gambar kunci, terpisah dari
    // tabel nomor bentuk, jadi pemeriksaan ini menangkap salah salin.
    const corners = <String, (List<String>, List<String?>)>{
      'kiri atas': (['U', 'UR', 'R', 'D', 'DL', 'L'], ['D', 'E', null, 'Y', 'Z', 'C']),
      'kanan atas': (['U', 'R', 'DR', 'D', 'L', 'UL'], ['I', 'J', 'K', null, 'G', 'H']),
      'kiri bawah': (['U', 'R', 'DR', 'D', 'L', 'UL'], [null, 'S', 'T', 'U', 'V', 'W']),
      'kanan bawah': (['U', 'UR', 'R', 'D', 'DL', 'L'], ['M', 'N', 'O', 'P', 'Q', null]),
    };

    test('bentuk tiap huruf sudut sama dengan sinar sektornya', () {
      for (final entry in corners.entries) {
        final rays = entry.value.$1;
        final letters = entry.value.$2;
        for (var i = 0; i < 6; i++) {
          final letter = letters[i];
          if (letter == null) continue;
          final expected = _key([rays[i], rays[(i + 1) % 6]]);
          final actual = _key(kotak3ShapeRays[kotak3Shape[letter]!]!);
          expect(actual, expected, reason: '$letter di sudut ${entry.key}');
        }
      }
    });

    test('ruang tengah dan ujung belah ketupat', () {
      expect(kotak3Shape['A'], 1);
      expect(kotak3Shape['B'], 1);
      expect(_key(kotak3ShapeRays[kotak3Shape['F']!]!), 'DL+DR');
      expect(_key(kotak3ShapeRays[kotak3Shape['R']!]!), 'UL+UR');
      expect(_key(kotak3ShapeRays[kotak3Shape['X']!]!), 'DR+UR');
      expect(_key(kotak3ShapeRays[kotak3Shape['L']!]!), 'DL+UL');
    });

    test('delapan pasang sebentuk, tepat satu huruf bertitik per pasangan', () {
      final byShape = <int, List<String>>{};
      for (final e in kotak3Shape.entries) {
        byShape.putIfAbsent(e.value, () => []).add(e.key);
      }
      var pairs = 0;
      for (final letters in byShape.values) {
        if (letters.length == 1) {
          expect(kotak3Dotted.contains(letters.first), isFalse,
              reason: letters.first);
        } else {
          expect(letters.length, 2);
          pairs++;
          final dotted = letters.where(kotak3Dotted.contains).length;
          expect(dotted, 1, reason: letters.join());
        }
      }
      // 8 pasang sudut ditambah pasangan A dan B (ruang tengah).
      expect(pairs, 9);
    });

    test('huruf bertitik sama dengan gambar kunci', () {
      expect(kotak3Dotted, {'B', 'D', 'H', 'J', 'N', 'P', 'T', 'V', 'Z'});
    });

    test('26 huruf, 17 bentuk, kode unik', () {
      expect(kotak3Shape.length, 26);
      expect(kotak3Shape.values.toSet().length, 17);
      expect(kotak3ShapeRays.length, 17);
      expect(kotak3Codes.values.toSet().length, 26);
    });
  });

  group('Kotak3Cipher', () {
    const c = Kotak3Cipher();

    test('encode', () {
      expect(c.encode('A', _o).output, 'K1');
      expect(c.encode('B', _o).output, 'K1.');
      expect(c.encode('E', _o).output, 'K8');
      expect(c.encode('N', _o).output, 'K8.');
      expect(c.encode('F', _o).output, 'K14');
      expect(c.encode('A B', _o).output, 'K1 / K1.');
    });

    test('decode dan bolak-balik', () {
      expect(c.decode('K1 K1.', _o).output, 'AB');
      expect(c.decode('k8 k8.', _o).output, 'EN');
      final enc = c.encode('SIAGA PRAMUKA GARUDA', _o).output;
      expect(c.decode(enc, _o).output, 'SIAGA PRAMUKA GARUDA');
    });

    test('validasi', () {
      expect(c.encode('', _o).ok, isFalse);
      expect(c.encode('A1', _o).ok, isFalse);
      expect(c.decode('K18', _o).ok, isFalse);
      expect(c.decode('K2.', _o).ok, isFalse); // bentuk K2 (C) tidak bertitik
      expect(c.decode('X1', _o).ok, isFalse);
      expect(c.decode('1', _o).ok, isFalse);
    });
  });
}
