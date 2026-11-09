import 'cipher.dart';

/// Memetakan huruf A-Z/a-z lewat fungsi [f] (indeks 0..25 -> 0..25).
/// Karakter lain (spasi, angka, tanda baca) dibiarkan.
String _mapLetters(String input, int Function(int index) f) {
  final out = StringBuffer();
  for (final unit in input.codeUnits) {
    if (unit >= 65 && unit <= 90) {
      out.writeCharCode(65 + (((f(unit - 65)) % 26) + 26) % 26);
    } else if (unit >= 97 && unit <= 122) {
      out.writeCharCode(97 + (((f(unit - 97)) % 26) + 26) % 26);
    } else {
      out.writeCharCode(unit);
    }
  }
  return out.toString();
}

/// Sandi AN: A<->N, B<->O, ... M<->Z (simetris).
class AnCipher extends Cipher {
  const AnCipher();

  @override
  String get id => 'an';
  @override
  String get name => 'Sandi AN';
  @override
  String get description =>
      'Abjad dibagi dua: A-M dan N-Z. Setiap huruf ditukar dengan pasangannya '
      '(A=N, B=O, C=P, ... M=Z). Enkripsi dan dekripsi memakai aturan yang sama.';

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;
    return TranslationResult.success(_mapLetters(input, (i) => i + 13));
  }

  @override
  TranslationResult decode(String input, CipherOptions options) =>
      encode(input, options);
}

/// Sandi AZ: A<->Z, B<->Y, ... (abjad dibalik, simetris).
class AzCipher extends Cipher {
  const AzCipher();

  @override
  String get id => 'az';
  @override
  String get name => 'Sandi AZ';
  @override
  String get description =>
      'Huruf pertama ditukar dengan huruf terakhir (A=Z, B=Y, C=X, ... Z=A). '
      'Enkripsi dan dekripsi memakai aturan yang sama.';

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;
    return TranslationResult.success(_mapLetters(input, (i) => 25 - i));
  }

  @override
  TranslationResult decode(String input, CipherOptions options) =>
      encode(input, options);
}

/// Sandi Balik: urutan huruf dibalik.
class BalikCipher extends Cipher {
  const BalikCipher();

  static const String variantText = 'teks';
  static const String variantWord = 'kata';

  @override
  String get id => 'balik';
  @override
  String get name => 'Sandi Balik';
  @override
  String get description =>
      'Urutan huruf dibalik. Ada dua cara yang umum dipakai, pilih sesuai '
      'kesepakatan regu.';

  @override
  List<CipherVariant> get variants => const [
        CipherVariant(variantText, 'Balik seluruh kalimat',
            note: 'Contoh: "ABC DEF" menjadi "FED CBA".'),
        CipherVariant(variantWord, 'Balik tiap kata',
            note: 'Contoh: "ABC DEF" menjadi "CBA FED".'),
      ];

  String _reverse(String s) => s.split('').reversed.join();

  TranslationResult _run(String input, CipherOptions options) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;
    if (options.variantId == variantWord) {
      return TranslationResult.success(
          input.split(' ').map(_reverse).join(' '));
    }
    return TranslationResult.success(_reverse(input));
  }

  @override
  TranslationResult encode(String input, CipherOptions options) =>
      _run(input, options);

  @override
  TranslationResult decode(String input, CipherOptions options) =>
      _run(input, options);
}

/// Sandi Abjad dengan pergeseran huruf (Caesar), geseran 1-25.
class GeserCipher extends Cipher {
  const GeserCipher();

  @override
  String get id => 'geser';
  @override
  String get name => 'Sandi Abjad (Pergeseran)';
  @override
  String get description =>
      'Setiap huruf digeser sejumlah langkah di abjad. Contoh geser 3: '
      'A menjadi D, B menjadi E. Atur jumlah geseran sesuai kesepakatan.';
  @override
  bool get usesShift => true;

  TranslationResult? _validate(String input, CipherOptions o) {
    final empty = checkNotEmpty(input);
    if (empty != null) return empty;
    if (o.shift < 1 || o.shift > 25) {
      return const TranslationResult.failure('Geseran harus antara 1 sampai 25.');
    }
    return null;
  }

  @override
  TranslationResult encode(String input, CipherOptions options) {
    final bad = _validate(input, options);
    if (bad != null) return bad;
    return TranslationResult.success(
        _mapLetters(input, (i) => i + options.shift));
  }

  @override
  TranslationResult decode(String input, CipherOptions options) {
    final bad = _validate(input, options);
    if (bad != null) return bad;
    return TranslationResult.success(
        _mapLetters(input, (i) => i - options.shift));
  }
}
