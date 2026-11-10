import 'cipher.dart';

/// Pola titik Braille huruf Latin A-Z (sel 6 titik).
/// Penomoran: kolom kiri 1-2-3 (atas ke bawah), kolom kanan 4-5-6.
const Map<String, String> brailleDots = {
  'A': '1',
  'B': '12',
  'C': '14',
  'D': '145',
  'E': '15',
  'F': '124',
  'G': '1245',
  'H': '125',
  'I': '24',
  'J': '245',
  'K': '13',
  'L': '123',
  'M': '134',
  'N': '1345',
  'O': '135',
  'P': '1234',
  'Q': '12345',
  'R': '1235',
  'S': '234',
  'T': '2345',
  'U': '136',
  'V': '1236',
  'W': '2456',
  'X': '1346',
  'Y': '13456',
  'Z': '1356',
};

final Map<String, String> _lettersByDots = {
  for (final e in brailleDots.entries) e.value: e.key,
};

/// Mengubah nomor titik (misal "145") menjadi karakter Braille Unicode.
String dotsToUnicode(String dots) {
  var mask = 0;
  for (final ch in dots.split('')) {
    mask |= 1 << (int.parse(ch) - 1);
  }
  return String.fromCharCode(0x2800 + mask);
}

/// Membaca satu token: nomor titik ("145") atau karakter Braille Unicode.
/// Mengembalikan daftar sel (nomor titik terurut) atau null jika tidak valid.
List<String>? _parseToken(String token) {
  final units = token.codeUnits;
  final hasBrailleChar = units.any((u) => u > 0x2800 && u <= 0x28FF);
  if (hasBrailleChar) {
    final cells = <String>[];
    for (final u in units) {
      if (u <= 0x2800 || u > 0x28FF) return null;
      final mask = u - 0x2800;
      if (mask > 0x3F) return null;
      final sb = StringBuffer();
      for (var i = 0; i < 6; i++) {
        if ((mask & (1 << i)) != 0) sb.write(i + 1);
      }
      cells.add(sb.toString());
    }
    return cells;
  }
  if (!RegExp(r'^[1-6]+$').hasMatch(token)) return null;
  final digits = token.split('')..sort();
  for (var i = 1; i < digits.length; i++) {
    if (digits[i] == digits[i - 1]) return null;
  }
  return [digits.join()];
}

class BrailleCipher extends Cipher {
  const BrailleCipher();

  @override
  String get id => 'braille';

  @override
  String get name => 'Sandi Braille';

  @override
  String get description =>
      'Setiap huruf ditulis sebagai kombinasi titik pada sel 6 titik. Di sini '
      'huruf dituliskan dengan nomor titiknya (kolom kiri 1-2-3, kolom kanan '
      '4-5-6), huruf dipisah spasi dan kata dipisah "/". Hanya huruf A-Z; '
      'angka dan tanda baca belum didukung.';

  @override
  String get decodeHint => 'Contoh: 234 24 1 1245 1 atau tulisan Braille';

  @override
  List<CipherVariant> get variants => const [
        CipherVariant('huruf', 'Huruf A-Z (nomor titik)',
            note: 'Pola huruf Braille Latin. Angka dan tanda baca memakai '
                'aturan tambahan dan belum didukung.'),
      ];

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final unknown = <String>{};
    final words = <String>[];
    final glyphWords = <String>[];
    for (final word in input.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final codes = <String>[];
      final glyphs = StringBuffer();
      for (final ch in word.split('')) {
        final dots = brailleDots[ch];
        if (dots == null) {
          unknown.add(ch);
        } else {
          codes.add(dots);
          glyphs.write(dotsToUnicode(dots));
        }
      }
      words.add(codes.join(' '));
      glyphWords.add(glyphs.toString());
    }
    if (unknown.isNotEmpty) {
      return TranslationResult.failure(
          'Hanya huruf A-Z yang didukung. Karakter tidak valid: '
          '${unknown.join(' ')}');
    }
    return TranslationResult.success(
      words.join(' / '),
      note: 'Tulisan Braille: ${glyphWords.join(' ')} '
          '(jika tampil sebagai kotak, pakai nomor titik di atas).',
    );
  }

  @override
  TranslationResult decode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final invalid = <String>[];
    final words = <String>[];
    // Sel kosong Braille dianggap pemisah kata.
    final normalized = input.replaceAll('\u2800', ' / ');
    for (final rawWord in normalized.split('/')) {
      final tokens =
          rawWord.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
      if (tokens.isEmpty) continue;
      final letters = StringBuffer();
      for (final token in tokens) {
        final cells = _parseToken(token);
        if (cells == null) {
          invalid.add(token);
          continue;
        }
        for (final cell in cells) {
          final letter = _lettersByDots[cell];
          if (letter == null) {
            invalid.add(token);
          } else {
            letters.write(letter);
          }
        }
      }
      words.add(letters.toString());
    }
    if (invalid.isNotEmpty) {
      return TranslationResult.failure(
          'Pola Braille tidak dikenal: ${invalid.join(' ')}. '
          'Tulis nomor titik 1-6 untuk tiap huruf, contoh 145.');
    }
    if (words.isEmpty) {
      return const TranslationResult.failure('Tidak ada pola Braille.');
    }
    return TranslationResult.success(words.join(' '));
  }
}
