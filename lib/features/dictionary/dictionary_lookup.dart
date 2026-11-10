import '../../services/ciphers/cipher.dart';
import '../../services/translation_service.dart';

class DictionaryHit {
  const DictionaryHit({
    required this.cipherId,
    required this.cipherName,
    required this.value,
  });

  final String cipherId;
  final String cipherName;

  /// Kode sandi (pencarian simbol) atau arti kode (pencarian kode).
  final String value;
}

/// Sandi yang kodenya bukan huruf, sehingga bisa dicari dari kodenya.
const Set<String> codeCipherIds = {
  'morse',
  'angka',
  'kotak_koordinat',
  'braille',
};

/// Sandi pengganti huruf (karakter selain A-Z dibiarkan apa adanya).
const Set<String> letterCipherIds = {'an', 'az', 'geser'};

CipherOptions _defaultOptions(Cipher c) => CipherOptions(
      variantId: c.variants.isEmpty ? null : c.variants.first.id,
      shift: 3,
    );

String _label(Cipher c) => c.usesShift ? '${c.name} (geser 3)' : c.name;

/// Satu huruf, angka, atau simbol -> kodenya di tiap sandi.
/// Sandi Balik dilewati karena tidak punya tabel per simbol.
List<DictionaryHit> lookupSymbol(String query) {
  final q = query.trim().toUpperCase();
  if (q.length != 1) return const [];
  final hits = <DictionaryHit>[];
  for (final c in translatableCiphers) {
    if (c.id == 'balik') continue;
    // Sandi pengganti huruf hanya bermakna untuk huruf A-Z.
    if (letterCipherIds.contains(c.id) && !RegExp(r'^[A-Z]$').hasMatch(q)) {
      continue;
    }
    final r = c.encode(q, _defaultOptions(c));
    if (r.ok) {
      hits.add(DictionaryHit(
        cipherId: c.id,
        cipherName: _label(c),
        value: r.output,
      ));
    }
  }
  return hits;
}

/// Kode (misalnya ".-", "25", "145") -> artinya di tiap sandi berkode.
List<DictionaryHit> lookupCode(String query) {
  final q = query.trim();
  if (q.isEmpty) return const [];
  final hits = <DictionaryHit>[];
  for (final c in translatableCiphers) {
    if (!codeCipherIds.contains(c.id)) continue;
    final r = c.decode(q, _defaultOptions(c));
    if (r.ok) {
      hits.add(DictionaryHit(
        cipherId: c.id,
        cipherName: c.name,
        value: r.output,
      ));
    }
  }
  return hits;
}
