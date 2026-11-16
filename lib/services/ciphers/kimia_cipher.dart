import 'cipher.dart';

/// Tabel Sandi Kimia dari gambar bahan materi. Setiap rumus sebenarnya
/// adalah kode Morse yang disamarkan: O dan A mewakili titik, sedangkan
/// H, S, dan N mewakili garis. Angka di belakang lambang = jumlah ulangan.
/// Ä, Ö, Ch, dan tanda "|" belum dimasukkan.
const Map<String, String> kimiaCodes = {
  'A': 'OH',
  'B': 'HO3',
  'C': 'SOHA',
  'D': 'SO2',
  'E': 'O',
  'F': 'O2SA',
  'G': 'H2O',
  'H': 'O4',
  'I': 'O2',
  'J': 'OH3',
  'K': 'NOH',
  'L': 'ASO2',
  'M': 'H2',
  'N': 'HO',
  'O': 'S3',
  'P': 'OS2A',
  'Q': 'H2OS',
  'R': 'OHA',
  'S': 'O3',
  'T': 'H',
  'U': 'O2H',
  'V': 'O3H',
  'W': 'OH2',
  'X': 'SO2H',
  'Y': 'SOH2',
  'Z': 'H2O2',
  '0': 'N5',
  '1': 'ON4',
  '2': 'O2N3',
  '3': 'O3N2',
  '4': 'O4N',
  '5': 'O5',
  '6': 'NO4',
  '7': 'N2O3',
  '8': 'N3O2',
  '9': 'N4O',
  '.': 'OHOHOH',
  ',': 'H2O2N2',
  '?': 'O2N2A2',
  ':': 'H3O3',
  '"': 'OHO2HO',
  "'": 'OH4O',
  '=': 'HO3H',
};

final Map<String, String> _charsByFormula = {
  for (final e in kimiaCodes.entries) e.value: e.key,
};

class KimiaCipher extends Cipher {
  const KimiaCipher();

  @override
  String get id => 'kimia';

  @override
  String get name => 'Sandi Kimia';

  @override
  String get description =>
      'Huruf, angka, dan beberapa tanda baca diganti rumus yang tersusun dari '
      'lambang H, O, N, S, A, misalnya A = OH dan G = H2O. Angka di belakang '
      'lambang berarti diulang. Rumus dipisah spasi, kata dipisah "/".';

  @override
  String get decodeHint => 'Contoh: O3 S3 O3';

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final unknown = <String>{};
    final words = <String>[];
    for (final word in input.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final formulas = <String>[];
      for (final ch in word.split('')) {
        final f = kimiaCodes[ch];
        if (f == null) {
          unknown.add(ch);
        } else {
          formulas.add(f);
        }
      }
      words.add(formulas.join(' '));
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

    // Angka 0 dianggap huruf O: rumus tidak pernah memakai angka 0.
    final normalized = input.toUpperCase().replaceAll('0', 'O');
    final invalid = <String>[];
    final words = <String>[];
    for (final rawWord in normalized.split('/')) {
      final tokens =
          rawWord.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
      if (tokens.isEmpty) continue;
      final chars = StringBuffer();
      for (final token in tokens) {
        final ch = _charsByFormula[token];
        if (ch == null) {
          invalid.add(token);
        } else {
          chars.write(ch);
        }
      }
      words.add(chars.toString());
    }
    if (invalid.isNotEmpty) {
      return TranslationResult.failure(
          'Rumus tidak dikenal: ${invalid.join(' ')}. Pisahkan tiap rumus '
          'dengan spasi, contoh OH H2O.');
    }
    if (words.isEmpty) {
      return const TranslationResult.failure('Tidak ada rumus untuk dibaca.');
    }
    return TranslationResult.success(words.join(' '));
  }
}
