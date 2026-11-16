import 'cipher.dart';

/// Kotak Sungai: 5 baris x 8 kolom. Huruf mengelilingi kotak, dimulai dari
/// kata SUNGAI di baris atas, lalu huruf abjad yang belum terpakai.
const String sungaiTop = 'SUNGAIBC'; // kiri ke kanan
const String sungaiBottom = 'TRQPOMLK'; // kiri ke kanan (urutan tulis: kanan ke kiri)
const String sungaiLeft = 'ZYXWV'; // atas ke bawah (urutan tulis: bawah ke atas)
const String sungaiRight = 'DEFHJ'; // atas ke bawah

/// Pasangan huruf: huruf di ujung kolom atau baris yang sama saling bertukar.
final Map<String, String> sungaiPairs = _buildPairs();

Map<String, String> _buildPairs() {
  final m = <String, String>{};
  for (var i = 0; i < sungaiTop.length; i++) {
    m[sungaiTop[i]] = sungaiBottom[i];
    m[sungaiBottom[i]] = sungaiTop[i];
  }
  for (var i = 0; i < sungaiRight.length; i++) {
    m[sungaiRight[i]] = sungaiLeft[i];
    m[sungaiLeft[i]] = sungaiRight[i];
  }
  return m;
}

class SungaiCipher extends Cipher {
  const SungaiCipher();

  @override
  String get id => 'sungai';

  @override
  String get name => 'Sandi Sungai';

  @override
  String get description =>
      'Huruf disusun mengelilingi kotak 5 baris x 8 kolom, dimulai dari kata '
      'SUNGAI. Setiap huruf diganti dengan huruf di seberangnya (satu kolom '
      'atau satu baris). Pasangannya timbal balik, jadi menyandi dan membaca '
      'memakai aturan yang sama.';

  TranslationResult _run(String input) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;

    final unknown = <String>{};
    final words = <String>[];
    for (final word in input.trim().toUpperCase().split(RegExp(r'\s+'))) {
      final out = StringBuffer();
      for (final ch in word.split('')) {
        final p = sungaiPairs[ch];
        if (p == null) {
          unknown.add(ch);
        } else {
          out.write(p);
        }
      }
      words.add(out.toString());
    }
    if (unknown.isNotEmpty) {
      return TranslationResult.failure(
          'Hanya huruf A-Z yang didukung. Karakter tidak valid: '
          '${unknown.join(' ')}');
    }
    return TranslationResult.success(words.join(' '));
  }

  @override
  TranslationResult encode(String input, CipherOptions options) => _run(input);

  @override
  TranslationResult decode(String input, CipherOptions options) => _run(input);
}
