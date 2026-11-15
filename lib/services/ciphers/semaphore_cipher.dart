import 'cipher.dart';

/// Rumus Semaphore dari bahan materi: posisi lengan dinomori 1-8 dan tiap
/// huruf adalah pasangan dua posisi.
///   1 = bawah, 2 = kiri bawah, 3 = kiri, 4 = kiri atas,
///   5 = atas, 6 = kanan atas, 7 = kanan, 8 = kanan bawah
/// (dilihat dari depan, seperti pada gambar). Pasangan ditulis dari nomor
/// kecil ke besar karena kedua lengan bisa bertukar.
const Map<String, String> semaphoreCodes = {
  'A': '1.2',
  'B': '1.3',
  'C': '1.4',
  'D': '1.5',
  'E': '1.6',
  'F': '1.7',
  'G': '1.8',
  'H': '2.3',
  'I': '2.4',
  'J': '5.7',
  'K': '2.5',
  'L': '2.6',
  'M': '2.7',
  'N': '2.8',
  'O': '3.4',
  'P': '3.5',
  'Q': '3.6',
  'R': '3.7',
  'S': '3.8',
  'T': '4.5',
  'U': '4.6',
  'V': '5.8',
  'W': '6.7',
  'X': '6.8',
  'Y': '4.7',
  'Z': '7.8',
};

final Map<String, String> _lettersByCode = {
  for (final e in semaphoreCodes.entries) e.value: e.key,
};

/// Mengubah "2.1" menjadi bentuk baku "1.2". Null jika bukan pasangan valid.
String? normalizeSemaphoreCode(String token) {
  final m = RegExp(r'^([1-8])\.([1-8])$').firstMatch(token);
  if (m == null) return null;
  final a = int.parse(m.group(1)!);
  final b = int.parse(m.group(2)!);
  if (a == b) return null;
  return a < b ? '$a.$b' : '$b.$a';
}

class SemaphoreCipher extends Cipher {
  const SemaphoreCipher();

  @override
  String get id => 'semaphore';

  @override
  String get name => 'Sandi Semaphore';

  @override
  String get description =>
      'Huruf disampaikan lewat posisi dua lengan. Ada 8 posisi bernomor 1-8 '
      '(1 bawah, 2 kiri bawah, 3 kiri, 4 kiri atas, 5 atas, 6 kanan atas, '
      '7 kanan, 8 kanan bawah). Tiap huruf adalah pasangan dua nomor, misalnya '
      'A = 1.2. Huruf dipisah spasi, kata dipisah "/".';

  @override
  String get decodeHint => 'Contoh: 3.8 2.4 1.2 1.8 1.2';

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final unknown = <String>{};
    final words = <String>[];
    for (final word in input.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final codes = <String>[];
      for (final ch in word.split('')) {
        final code = semaphoreCodes[ch];
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
        final code = normalizeSemaphoreCode(token);
        final letter = code == null ? null : _lettersByCode[code];
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
          'Kode Semaphore tidak valid: ${invalid.join(' ')}. Tulis dua nomor '
          'posisi 1-8 yang berbeda, contoh 1.2.');
    }
    if (words.isEmpty) {
      return const TranslationResult.failure('Tidak ada kode Semaphore.');
    }
    return TranslationResult.success(words.join(' '));
  }
}
