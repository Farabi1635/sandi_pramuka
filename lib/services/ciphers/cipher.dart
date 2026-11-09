enum TranslateMode { encode, decode }

class TranslationResult {
  const TranslationResult.success(this.output, {this.note})
      : ok = true,
        error = null;

  const TranslationResult.failure(this.error)
      : ok = false,
        output = '',
        note = null;

  final bool ok;
  final String output;
  final String? error;
  final String? note;
}

class CipherVariant {
  const CipherVariant(this.id, this.label, {this.note});
  final String id;
  final String label;
  final String? note;
}

class CipherOptions {
  const CipherOptions({this.variantId, this.shift = 3});
  final String? variantId;
  final int shift;
}

abstract class Cipher {
  const Cipher();

  String get id;
  String get name;
  String get description;
  String get encodeHint => 'Ketik teks biasa';
  String get decodeHint => 'Ketik kode sandi';
  List<CipherVariant> get variants => const [];
  bool get usesShift => false;

  TranslationResult encode(String input, CipherOptions options);
  TranslationResult decode(String input, CipherOptions options);
}

/// Mengembalikan pesan gagal jika input kosong, selain itu null.
TranslationResult? checkNotEmpty(String input) {
  if (input.trim().isEmpty) {
    return const TranslationResult.failure('Teks tidak boleh kosong.');
  }
  return null;
}
