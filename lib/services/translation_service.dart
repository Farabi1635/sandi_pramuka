import 'ciphers/braille_cipher.dart';
import 'ciphers/cipher.dart';
import 'ciphers/jam_cipher.dart';
import 'ciphers/letter_ciphers.dart';
import 'ciphers/morse_cipher.dart';
import 'ciphers/number_ciphers.dart';
import 'ciphers/semaphore_cipher.dart';

/// Daftar sandi yang sudah punya mesin penerjemah.
/// Sandi bergambar lain (Kotak 1-3, Rumput, dll.) menyusul.
const List<Cipher> translatableCiphers = [
  MorseCipher(),
  SemaphoreCipher(),
  AnCipher(),
  AzCipher(),
  BalikCipher(),
  GeserCipher(),
  AngkaCipher(),
  KotakKoordinatCipher(),
  BrailleCipher(),
  JamCipher(),
];

Cipher? cipherById(String id) {
  for (final c in translatableCiphers) {
    if (c.id == id) return c;
  }
  return null;
}
