import 'cipher.dart';

/// Ruang tanda pagar (#) bernomor 1-9, dibaca baris demi baris.
const List<String> kotak1Cells = [
  'AB', 'CD', 'EF', //
  'GH', 'IJ', 'KL', //
  'MN', 'OP', 'QR',
];

/// Ruang tanda silang (X): X1 atas, X2 kiri, X3 kanan, X4 bawah.
const List<String> kotak1Wedges = ['UV', 'ST', 'WX', 'YZ'];

const List<String> kotak2Cells = [
  'ABC', 'DEF', 'GHI', //
  'JKL', 'MNO', 'PQR', //
  'STU', 'VWX', 'YZ',
];

/// Sisi garis tanda pagar yang mengelilingi ruang [cell] (1-9):
/// garis atas ada jika bukan baris pertama, garis kiri jika bukan kolom
/// pertama, dan seterusnya. Dipakai untuk menggambar simbol.
Set<String> kotakCellSides(int cell) {
  final r = (cell - 1) ~/ 3;
  final c = (cell - 1) % 3;
  return {
    if (r > 0) 'top',
    if (r < 2) 'bottom',
    if (c > 0) 'left',
    if (c < 2) 'right',
  };
}

Map<String, String> _kotak1Codes() {
  final m = <String, String>{};
  for (var i = 0; i < kotak1Cells.length; i++) {
    m[kotak1Cells[i][0]] = 'K${i + 1}';
    m[kotak1Cells[i][1]] = 'K${i + 1}.';
  }
  for (var i = 0; i < kotak1Wedges.length; i++) {
    m[kotak1Wedges[i][0]] = 'X${i + 1}';
    m[kotak1Wedges[i][1]] = 'X${i + 1}.';
  }
  return m;
}

Map<String, String> _kotak2Codes() {
  final m = <String, String>{};
  for (var i = 0; i < kotak2Cells.length; i++) {
    for (var j = 0; j < kotak2Cells[i].length; j++) {
      m[kotak2Cells[i][j]] = 'K${i + 1}${'.' * j}';
    }
  }
  return m;
}

/// Kode huruf: K = ruang tanda pagar, X = ruang tanda silang; titik di
/// belakang = jumlah titik di dalam simbol.
final Map<String, String> kotak1Codes = _kotak1Codes();
final Map<String, String> kotak2Codes = _kotak2Codes();

final Map<String, String> _kotak1Reverse = {
  for (final e in kotak1Codes.entries) e.value: e.key,
};
final Map<String, String> _kotak2Reverse = {
  for (final e in kotak2Codes.entries) e.value: e.key,
};

abstract class _KotakCipher extends Cipher {
  const _KotakCipher();

  Map<String, String> get codes;
  Map<String, String> get reverse;

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
        final code = codes[ch];
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
        final letter = reverse[token];
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
          'Kode tidak valid: ${invalid.join(' ')}. Tulis nomor ruang dengan '
          'awalan K (atau X), titik di belakang untuk jumlah titik, '
          'contoh K1 atau K1.');
    }
    if (words.isEmpty) {
      return const TranslationResult.failure('Tidak ada kode untuk dibaca.');
    }
    return TranslationResult.success(words.join(' '));
  }
}

class Kotak1Cipher extends _KotakCipher {
  const Kotak1Cipher();

  @override
  String get id => 'kotak1';

  @override
  String get name => 'Sandi Kotak 1';

  @override
  String get description =>
      'Memakai tanda pagar (#) dan tanda silang (X). Huruf diganti garis yang '
      'mengelilingi ruangnya, dan huruf kedua di tiap pasangan diberi titik. '
      'Ditulis sebagai K1-K9 (ruang #) dan X1-X4 (ruang X: atas, kiri, '
      'kanan, bawah), titik di belakang bila ada. Kode dipisah spasi, kata '
      'dipisah "/".';

  @override
  Map<String, String> get codes => kotak1Codes;

  @override
  Map<String, String> get reverse => _kotak1Reverse;
}

class Kotak2Cipher extends _KotakCipher {
  const Kotak2Cipher();

  @override
  String get id => 'kotak2';

  @override
  String get name => 'Sandi Kotak 2';

  @override
  String get description =>
      'Memakai tanda pagar (#) dengan 9 ruang, tiap ruang berisi tiga huruf. '
      'Huruf diganti garis yang mengelilingi ruangnya; huruf pertama tanpa '
      'titik, kedua satu titik, ketiga dua titik. Ditulis sebagai K1-K9 '
      'dengan titik di belakang, misalnya C = K1... Kode dipisah spasi, kata '
      'dipisah "/".';

  @override
  Map<String, String> get codes => kotak2Codes;

  @override
  Map<String, String> get reverse => _kotak2Reverse;
}
