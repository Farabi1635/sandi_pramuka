import 'cipher.dart';
import 'morse_cipher.dart';

/// Pola Sandi Rumput tiap huruf. Puncak kecil = k, puncak tinggi = B.
/// Dari gambar bahan materi, pola 26 huruf sama dengan kode Morse:
/// puncak kecil seperti titik, puncak tinggi seperti garis.
final Map<String, String> rumputCodes = {
  for (var i = 0; i < 26; i++)
    String.fromCharCode(65 + i): morseTable[String.fromCharCode(65 + i)]!
        .split('')
        .map((c) => c == '.' ? 'k' : 'B')
        .join(),
};

final Map<String, String> _lettersByCode = {
  for (final e in rumputCodes.entries) e.value: e.key,
};

class RumputCipher extends Cipher {
  const RumputCipher();

  @override
  String get id => 'rumput';

  @override
  String get name => 'Sandi Rumput';

  @override
  String get description =>
      'Huruf digambar sebagai garis bergelombang seperti rumput dengan dua '
      'jenis puncak: kecil (ditulis k) dan tinggi (ditulis B). Misalnya '
      'A = kB. Huruf dipisah spasi, kata dipisah "/". Hanya huruf A-Z.';

  @override
  String get decodeHint => 'Contoh: kkk kk kB BBk kB';

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final unknown = <String>{};
    final words = <String>[];
    for (final word in input.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final codes = <String>[];
      for (final ch in word.split('')) {
        final code = rumputCodes[ch];
        if (code == null) {
          unknown.add(ch);
        } else {
          codes.add(code);
        }
      }
      words.add(codes.join(' '));
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
    for (final rawWord in input.split('/')) {
      final tokens =
          rawWord.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
      if (tokens.isEmpty) continue;
      final letters = StringBuffer();
      for (final token in tokens) {
        String? letter;
        if (RegExp(r'^[kKbB]+$').hasMatch(token)) {
          final code = token
              .split('')
              .map((c) => c.toLowerCase() == 'k' ? 'k' : 'B')
              .join();
          letter = _lettersByCode[code];
        }
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
          'Pola rumput tidak dikenal: ${invalid.join(' ')}. Tulis k untuk '
          'puncak kecil dan B untuk puncak tinggi, contoh kB.');
    }
    if (words.isEmpty) {
      return const TranslationResult.failure('Tidak ada pola untuk dibaca.');
    }
    return TranslationResult.success(words.join(' '));
  }
}
