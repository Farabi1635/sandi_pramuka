import 'cipher.dart';

/// Tabel Morse internasional (ITU). Tanda "/" tidak dimasukkan karena
/// dipakai sebagai pemisah kata pada hasil terjemahan.
const Map<String, String> morseTable = {
  'A': '.-',
  'B': '-...',
  'C': '-.-.',
  'D': '-..',
  'E': '.',
  'F': '..-.',
  'G': '--.',
  'H': '....',
  'I': '..',
  'J': '.---',
  'K': '-.-',
  'L': '.-..',
  'M': '--',
  'N': '-.',
  'O': '---',
  'P': '.--.',
  'Q': '--.-',
  'R': '.-.',
  'S': '...',
  'T': '-',
  'U': '..-',
  'V': '...-',
  'W': '.--',
  'X': '-..-',
  'Y': '-.--',
  'Z': '--..',
  '0': '-----',
  '1': '.----',
  '2': '..---',
  '3': '...--',
  '4': '....-',
  '5': '.....',
  '6': '-....',
  '7': '--...',
  '8': '---..',
  '9': '----.',
  '.': '.-.-.-',
  ',': '--..--',
  '?': '..--..',
  "'": '.----.',
  '!': '-.-.--',
  '(': '-.--.',
  ')': '-.--.-',
  '&': '.-...',
  ':': '---...',
  ';': '-.-.-.',
  '=': '-...-',
  '+': '.-.-.',
  '-': '-....-',
  '_': '..--.-',
  '"': '.-..-.',
  r'$': '...-..-',
  '@': '.--.-.',
};

final Map<String, String> _morseReverse = {
  for (final e in morseTable.entries) e.value: e.key,
};

class MorseCipher extends Cipher {
  const MorseCipher();

  @override
  String get id => 'morse';

  @override
  String get name => 'Sandi Morse';

  @override
  String get description =>
      'Huruf, angka, dan tanda baca diubah menjadi titik (.) dan garis (-). '
      'Huruf dipisah spasi, kata dipisah tanda garis miring (/).';

  @override
  String get decodeHint => 'Contoh: ... --- ... / .- -.- ..-';

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final unknown = <String>{};
    final words = <String>[];
    for (final word in input.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final letters = <String>[];
      for (final ch in word.split('')) {
        final code = morseTable[ch];
        if (code == null) {
          unknown.add(ch);
        } else {
          letters.add(code);
        }
      }
      words.add(letters.join(' '));
    }
    if (unknown.isNotEmpty) {
      return TranslationResult.failure(
          'Karakter tidak didukung: ${unknown.join(' ')}');
    }
    return TranslationResult.success(words.join(' / '));
  }

  @override
  TranslationResult decode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final normalized = input
        .trim()
        .replaceAll(RegExp('[·•]'), '.')
        .replaceAll(RegExp('[–−—]'), '-');
    if (RegExp(r'[^.\-/\s]').hasMatch(normalized)) {
      return const TranslationResult.failure(
          'Format Morse salah. Gunakan hanya titik (.), garis (-), '
          'spasi antarhuruf, dan garis miring (/) antarkata.');
    }

    final unknown = <String>[];
    final words = <String>[];
    for (final rawWord in normalized.split('/')) {
      final trimmed = rawWord.trim();
      if (trimmed.isEmpty) continue;
      final letters = StringBuffer();
      for (final code in trimmed.split(RegExp(r'\s+'))) {
        final ch = _morseReverse[code];
        if (ch == null) {
          unknown.add(code);
        } else {
          letters.write(ch);
        }
      }
      words.add(letters.toString());
    }
    if (unknown.isNotEmpty) {
      return TranslationResult.failure(
          'Kode Morse tidak dikenal: ${unknown.join(' ')}');
    }
    if (words.isEmpty) {
      return const TranslationResult.failure('Tidak ada kode Morse.');
    }
    return TranslationResult.success(words.join(' '));
  }
}
