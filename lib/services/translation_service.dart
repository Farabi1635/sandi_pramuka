import 'ciphers/braille_cipher.dart';
import 'ciphers/cipher.dart';
import 'ciphers/jam_cipher.dart';
import 'ciphers/kimia_cipher.dart';
import 'ciphers/koordinat_cipher.dart';
import 'ciphers/kotak3_cipher.dart';
import 'ciphers/kotak_cipher.dart';
import 'ciphers/letter_ciphers.dart';
import 'ciphers/morse_cipher.dart';
import 'ciphers/number_ciphers.dart';
import 'ciphers/rumput_cipher.dart';
import 'ciphers/semaphore_cipher.dart';
import 'ciphers/sungai_cipher.dart';

/// Daftar sandi yang sudah punya mesin penerjemah.
/// Sandi Gambar menyusul.
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
  KimiaCipher(),
  RumputCipher(),
  SungaiCipher(),
  KoordinatCipher(),
  Kotak1Cipher(),
  Kotak2Cipher(),
  Kotak3Cipher(),
];

Cipher? cipherById(String id) {
  for (final c in translatableCiphers) {
    if (c.id == id) return c;
  }
  return null;
}
