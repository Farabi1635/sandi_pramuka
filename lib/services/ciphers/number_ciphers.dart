import 'cipher.dart';

const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// Sandi Angka: A=1 ... Z=26.
/// Format: huruf dipisah "-", kata dipisah "/".
class AngkaCipher extends Cipher {
  const AngkaCipher();

  @override
  String get id => 'angka';
  @override
  String get name => 'Sandi Angka';
  @override
  String get description =>
      'Setiap huruf diganti nomor urutnya di abjad (A=1, B=2, ... Z=26). '
      'Huruf dipisah tanda "-", kata dipisah tanda "/".';
  @override
  String get decodeHint => 'Contoh: 1-11-21 / 16-18-1-13-21-11-1';

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final unknown = <String>{};
    final words = <String>[];
    for (final word in input.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final nums = <String>[];
      for (final ch in word.split('')) {
        final i = _alphabet.indexOf(ch);
        if (i < 0) {
          unknown.add(ch);
        } else {
          nums.add('${i + 1}');
        }
      }
      words.add(nums.join('-'));
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
      final tokens = rawWord
          .split(RegExp(r'[-\s]+'))
          .where((t) => t.isNotEmpty)
          .toList();
      if (tokens.isEmpty) continue;
      final letters = StringBuffer();
      for (final t in tokens) {
        final n = int.tryParse(t);
        if (n == null || n < 1 || n > 26) {
          invalid.add(t);
        } else {
          letters.write(_alphabet[n - 1]);
        }
      }
      words.add(letters.toString());
    }
    if (invalid.isNotEmpty) {
      return TranslationResult.failure(
          'Angka tidak valid: ${invalid.join(' ')} (harus 1 sampai 26).');
    }
    if (words.isEmpty) {
      return const TranslationResult.failure('Tidak ada angka untuk dibaca.');
    }
    return TranslationResult.success(words.join(' '));
  }
}

/// Sandi Kotak Koordinat (kotak Polybius 5x5, I=J).
/// Tiap huruf menjadi dua angka: baris lalu kolom.
class KotakKoordinatCipher extends Cipher {
  const KotakKoordinatCipher();

  static const String _grid = 'ABCDEFGHIKLMNOPQRSTUVWXYZ';

  @override
  String get id => 'kotak_koordinat';
  @override
  String get name => 'Sandi Kotak Koordinat';
  @override
  String get description =>
      'Huruf disusun dalam kotak 5x5. Setiap huruf ditulis sebagai angka '
      'baris lalu kolom (A=11, B=12, ... Z=55). Huruf I dan J berbagi satu kotak.';
  @override
  String get decodeHint => 'Contoh: 25 11 32 45';

  @override
  List<CipherVariant> get variants => const [
        CipherVariant('polybius', 'Kotak 5x5 (I = J), baris-kolom',
            note: 'Salah satu variasi yang umum dipakai. Regu lain bisa '
                'memakai susunan berbeda, sesuaikan dengan kesepakatan.'),
      ];

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final unknown = <String>{};
    final words = <String>[];
    var hasJ = false;
    for (final word in input.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final codes = <String>[];
      for (var ch in word.split('')) {
        if (ch == 'J') {
          hasJ = true;
          ch = 'I';
        }
        final pos = _grid.indexOf(ch);
        if (pos < 0) {
          unknown.add(ch);
        } else {
          codes.add('${pos ~/ 5 + 1}${pos % 5 + 1}');
        }
      }
      words.add(codes.join(' '));
    }
    if (unknown.isNotEmpty) {
      return TranslationResult.failure(
          'Hanya huruf A-Z yang didukung. Karakter tidak valid: '
          '${unknown.join(' ')}');
    }
    return TranslationResult.success(
      words.join(' / '),
      note: hasJ ? 'Huruf J dikodekan sebagai I.' : null,
    );
  }

  @override
  TranslationResult decode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final invalid = <String>[];
    final words = <String>[];
    var hasI = false;
    for (final rawWord in input.split('/')) {
      final tokens =
          rawWord.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
      if (tokens.isEmpty) continue;
      final letters = StringBuffer();
      for (final t in tokens) {
        if (!RegExp(r'^[1-5]{2}$').hasMatch(t)) {
          invalid.add(t);
          continue;
        }
        final row = int.parse(t[0]);
        final col = int.parse(t[1]);
        final ch = _grid[(row - 1) * 5 + (col - 1)];
        if (ch == 'I') hasI = true;
        letters.write(ch);
      }
      words.add(letters.toString());
    }
    if (invalid.isNotEmpty) {
      return TranslationResult.failure(
          'Kode tidak valid: ${invalid.join(' ')}. '
          'Setiap kode terdiri dari dua angka 1-5, contoh 25.');
    }
    if (words.isEmpty) {
      return const TranslationResult.failure('Tidak ada kode untuk dibaca.');
    }
    return TranslationResult.success(
      words.join(' '),
      note: hasI ? 'Huruf I bisa juga berarti J, sesuaikan dengan kata.' : null,
    );
  }
}
