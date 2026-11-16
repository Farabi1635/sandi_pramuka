import 'cipher.dart';

/// Tabel 5 x 5 berisi huruf A sampai Y (huruf Z tidak ada), disusun
/// baris demi baris.
const String koordinatGrid = 'ABCDEFGHIJKLMNOPQRSTUVWXY';

const String koordinatMerahPutih = 'merah_putih';
const String koordinatGudepSedia = 'gudep_sedia';

/// Kata kunci: [0] = nama kolom (kiri ke kanan), [1] = nama baris (atas ke bawah).
const Map<String, List<String>> koordinatKeys = {
  koordinatMerahPutih: ['MERAH', 'PUTIH'],
  koordinatGudepSedia: ['GUDEP', 'SEDIA'],
};

/// Kode satu huruf: huruf nama kolom lalu huruf nama baris. Null jika
/// huruf tidak ada di tabel.
String? koordinatCode(String letter, String variantId) {
  final keys = koordinatKeys[variantId] ?? koordinatKeys[koordinatMerahPutih]!;
  final i = koordinatGrid.indexOf(letter);
  if (i < 0) return null;
  return '${keys[0][i % 5]}${keys[1][i ~/ 5]}';
}

class KoordinatCipher extends Cipher {
  const KoordinatCipher();

  @override
  String get id => 'koordinat';

  @override
  String get name => 'Sandi Koordinat';

  @override
  String get description =>
      'Huruf A-Y disusun dalam tabel 5 x 5. Kolom diberi nama dari huruf kata '
      'MERAH dan baris dari huruf kata PUTIH. Tiap huruf ditulis sebagai '
      'huruf kolom lalu huruf baris, misalnya R = RI. Huruf Z tidak ada. '
      'Kode dipisah spasi, kata dipisah "/".';

  @override
  String get decodeHint => 'Contoh: MI RI MP RT MH MT MP';

  @override
  List<CipherVariant> get variants => const [
        CipherVariant(koordinatMerahPutih, 'MERAH PUTIH',
            note: 'Kolom MERAH, baris PUTIH (sesuai gambar bahan materi).'),
        CipherVariant(koordinatGudepSedia, 'GUDEP SEDIA',
            note: 'Kolom GUDEP, baris SEDIA. Pola sama dengan MERAH PUTIH; '
                'sepakati dulu dengan regumu.'),
      ];

  String _variant(CipherOptions o) =>
      koordinatKeys.containsKey(o.variantId)
          ? o.variantId!
          : koordinatMerahPutih;

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final variant = _variant(options);
    final unknown = <String>{};
    final words = <String>[];
    for (final word in input.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final codes = <String>[];
      for (final ch in word.split('')) {
        final code = koordinatCode(ch, variant);
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
          'Hanya huruf A-Y yang didukung (huruf Z tidak ada di tabel). '
          'Karakter tidak valid: ${unknown.join(' ')}');
    }
    return TranslationResult.success(words.join(' / '));
  }

  @override
  TranslationResult decode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final variant = _variant(options);
    final reverse = <String, String>{
      for (final ch in koordinatGrid.split(''))
        koordinatCode(ch, variant)!: ch,
    };

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
          'Kode tidak valid: ${invalid.join(' ')}. Tiap kode terdiri dari '
          'huruf kolom lalu huruf baris, misalnya RI.');
    }
    if (words.isEmpty) {
      return const TranslationResult.failure('Tidak ada kode untuk dibaca.');
    }
    return TranslationResult.success(words.join(' '));
  }
}
