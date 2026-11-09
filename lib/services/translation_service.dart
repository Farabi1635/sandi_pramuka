import 'ciphers/cipher.dart';
import 'ciphers/letter_ciphers.dart';
import 'ciphers/morse_cipher.dart';
import 'ciphers/number_ciphers.dart';

/// Daftar sandi yang sudah punya mesin penerjemah.
/// Sandi bergambar (Semaphore, Kotak 1-3, Rumput, dll.) menyusul di tahap berikutnya.
const List<Cipher> translatableCiphers = [
  MorseCipher(),
  AnCipher(),
  AzCipher(),
  BalikCipher(),
  GeserCipher(),
  AngkaCipher(),
  KotakKoordinatCipher(),
];

Cipher? cipherById(String id) {
  for (final c in translatableCiphers) {
    if (c.id == id) return c;
  }
  return null;
}
