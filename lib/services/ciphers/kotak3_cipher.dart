import 'cipher.dart';

/// Sinar garis yang membatasi sebuah ruang pada gambar kunci Kotak 3.
/// U atas, D bawah, L kiri, R kanan, UL kiri atas, UR kanan atas,
/// DL kiri bawah, DR kanan bawah.
///
/// Bentuk 1 = kotak penuh (ruang tengah A dan B). Bentuk 2-13 = dua sinar
/// dari satu sudut persegi tengah. Bentuk 14-17 = ujung belah ketupat
/// (F atas, R bawah, X kiri, L kanan).
const Map<int, List<String>> kotak3ShapeRays = {
  1: [],
  2: ['U', 'L'],
  3: ['U', 'R'],
  4: ['D', 'L'],
  5: ['D', 'R'],
  6: ['U', 'UR'],
  7: ['U', 'UL'],
  8: ['UR', 'R'],
  9: ['UL', 'L'],
  10: ['D', 'DL'],
  11: ['D', 'DR'],
  12: ['R', 'DR'],
  13: ['L', 'DL'],
  14: ['DL', 'DR'],
  15: ['UL', 'UR'],
  16: ['UR', 'DR'],
  17: ['UL', 'DL'],
};

/// Nomor bentuk tiap huruf.
const Map<String, int> kotak3Shape = {
  'A': 1,
  'B': 1,
  'C': 2,
  'D': 6,
  'E': 8,
  'F': 14,
  'G': 9,
  'H': 7,
  'I': 3,
  'J': 12,
  'K': 11,
  'L': 17,
  'M': 6,
  'N': 8,
  'O': 5,
  'P': 10,
  'Q': 13,
  'R': 15,
  'S': 12,
  'T': 11,
  'U': 4,
  'V': 9,
  'W': 7,
  'X': 16,
  'Y': 10,
  'Z': 13,
};

/// Huruf yang diberi titik pada gambar kunci. Titik membedakan dua ruang
/// yang bentuk garisnya sama.
const Set<String> kotak3Dotted = {'B', 'D', 'H', 'J', 'N', 'P', 'T', 'V', 'Z'};

/// Kode huruf: K + nomor bentuk, titik di belakang jika bertitik.
final Map<String, String> kotak3Codes = {
  for (final e in kotak3Shape.entries)
    e.key: 'K${e.value}${kotak3Dotted.contains(e.key) ? '.' : ''}',
};

final Map<String, String> _lettersByCode = {
  for (final e in kotak3Codes.entries) e.value: e.key,
};

class Kotak3Cipher extends Cipher {
  const Kotak3Cipher();

  @override
  String get id => 'kotak3';

  @override
  String get name => 'Sandi Kotak 3';

  @override
  String get description =>
      'Gambar tanda pagar (#) yang ditumpuk belah ketupat membentuk 26 ruang. '
      'Tiap huruf diganti garis yang membatasi ruangnya, dan huruf bertitik '
      'membedakan dua ruang yang bentuknya sama. Ditulis sebagai K1-K17 '
      '(nomor bentuk) dengan titik di belakang bila ada, misalnya B = K1. '
      'Kode dipisah spasi, kata dipisah "/".';

  @override
  String get decodeHint => 'Contoh: K1 K1. K2';

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final unknown = <String>{};
    final words = <String>[];
    for (final word in input.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final tokens = <String>[];
      for (final ch in word.split('')) {
        final code = kotak3Codes[ch];
        if (code == null) {
          unknown.add(ch);
        } else {
          tokens.add(code);
        }
      }
      words.add(tokens.join(' '));
    }
    if (unknown.isNotEmpty) {
      return TranslationResult.failure(
          'Hanya huruf A-Z yang didukung. Karakter tidak valid: '
          '${unknown.join(' ')}');
    }
    return TranslationResult.success(words.join(' / '));
  }

  @override
  TranslationResult decode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final invalid = <String>[];
    final words = <String>[];
    for (final rawWord in input.toUpperCase().split('/')) {
      final tokens =
          rawWord.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
      if (tokens.isEmpty) continue;
      final letters = StringBuffer();
      for (final token in tokens) {
        final letter = _lettersByCode[token];
        if (letter == null) {
          invalid.add(token);
        } else {
          letters.write(letter);
        }
      }
      words.add(letters.toString());
    }
    if (invalid.isNotEmpty) {
      return TranslationResult.failure(
          'Kode tidak valid: ${invalid.join(' ')}. Tulis K dan nomor bentuk '
          '1-17, titik di belakang bila bertitik, contoh K6.');
    }
    if (words.isEmpty) {
      return const TranslationResult.failure('Tidak ada kode untuk dibaca.');
    }
    return TranslationResult.success(words.join(' '));
  }
}
