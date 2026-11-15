import 'cipher.dart';

const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// Waktu untuk huruf ke-[index] (A = 0): mulai 03.00, tiap huruf +5 menit.
String jamTimeOf(int index) {
  final total = 180 + 5 * index;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(total ~/ 60)}.${two(total % 60)}';
}

class JamCipher extends Cipher {
  const JamCipher();

  @override
  String get id => 'jam';

  @override
  String get name => 'Sandi Jam';

  @override
  String get description =>
      'Setiap huruf diganti sebuah waktu. A = 03.00, lalu tiap huruf '
      'berikutnya bertambah 5 menit (B = 03.05, ... M = 04.00, ... Z = 05.05). '
      'Huruf dipisah spasi, kata dipisah "/".';

  @override
  String get decodeHint => 'Contoh: 04.30 03.40 03.00 03.30 03.00';

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final unknown = <String>{};
    final words = <String>[];
    for (final word in input.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final times = <String>[];
      for (final ch in word.split('')) {
        final i = _alphabet.indexOf(ch);
        if (i < 0) {
          unknown.add(ch);
        } else {
          times.add(jamTimeOf(i));
        }
      }
      words.add(times.join(' '));
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
        final m = RegExp(r'^(\d{1,2})[.:](\d{2})$').firstMatch(token);
        var letter = '';
        if (m != null) {
          final minutes =
              int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!) - 180;
          if (minutes >= 0 && minutes % 5 == 0 && minutes ~/ 5 < 26) {
            letter = _alphabet[minutes ~/ 5];
          }
        }
        if (letter.isEmpty) {
          invalid.add(token);
        } else {
          letters.write(letter);
        }
      }
      words.add(letters.toString());
    }
    if (invalid.isNotEmpty) {
      return TranslationResult.failure(
          'Waktu tidak valid: ${invalid.join(' ')}. Gunakan 03.00 sampai '
          '05.05 dengan selisih 5 menit.');
    }
    if (words.isEmpty) {
      return const TranslationResult.failure('Tidak ada waktu untuk dibaca.');
    }
    return TranslationResult.success(words.join(' '));
  }
}
