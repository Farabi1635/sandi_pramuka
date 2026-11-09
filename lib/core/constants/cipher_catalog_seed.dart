/// Daftar awal katalog sandi (nama & kategori saja).
/// Isi materi, tabel simbol, dan varian dibuat di Tahap 2 dan 3.
enum Difficulty { mudah, sedang, sulit }

class CipherInfo {
  const CipherInfo(this.id, this.name, this.difficulty);
  final String id;
  final String name;
  final Difficulty difficulty;
}

class CipherCategoryInfo {
  const CipherCategoryInfo(this.id, this.name, this.ciphers);
  final String id;
  final String name;
  final List<CipherInfo> ciphers;
}

const List<CipherCategoryInfo> cipherCategories = [
  CipherCategoryInfo('komunikasi', 'Sandi Komunikasi', [
    CipherInfo('morse', 'Sandi Morse', Difficulty.sedang),
    CipherInfo('semaphore', 'Sandi Semaphore', Difficulty.sedang),
  ]),
  CipherCategoryInfo('bentuk', 'Sandi Bentuk', [
    CipherInfo('kotak1', 'Sandi Kotak 1', Difficulty.mudah),
    CipherInfo('kotak2', 'Sandi Kotak 2', Difficulty.sedang),
    CipherInfo('kotak3', 'Sandi Kotak 3', Difficulty.sulit),
  ]),
  CipherCategoryInfo('pola', 'Sandi Pola', [
    CipherInfo('rumput', 'Sandi Rumput', Difficulty.sedang),
    CipherInfo('sungai', 'Sandi Sungai', Difficulty.sedang),
    CipherInfo('gambar', 'Sandi Gambar', Difficulty.mudah),
  ]),
  CipherCategoryInfo('huruf', 'Sandi Huruf', [
    CipherInfo('an', 'Sandi AN', Difficulty.mudah),
    CipherInfo('az', 'Sandi AZ', Difficulty.mudah),
    CipherInfo('balik', 'Sandi Balik', Difficulty.mudah),
    CipherInfo('geser', 'Sandi Abjad (Pergeseran)', Difficulty.sedang),
  ]),
  CipherCategoryInfo('angka', 'Sandi Angka dan Koordinat', [
    CipherInfo('angka', 'Sandi Angka', Difficulty.mudah),
    CipherInfo('koordinat', 'Sandi Koordinat', Difficulty.sedang),
    CipherInfo('kotak_koordinat', 'Sandi Kotak Koordinat', Difficulty.sedang),
  ]),
  CipherCategoryInfo('khusus', 'Sandi Khusus', [
    CipherInfo('kimia', 'Sandi Kimia', Difficulty.sulit),
    CipherInfo('jam', 'Sandi Jam', Difficulty.sedang),
    CipherInfo('braille', 'Sandi Braille', Difficulty.sulit),
  ]),
];

int get totalCipherCount =>
    cipherCategories.fold(0, (sum, c) => sum + c.ciphers.length);

CipherInfo? findCipher(String id) {
  for (final cat in cipherCategories) {
    for (final c in cat.ciphers) {
      if (c.id == id) return c;
    }
  }
  return null;
}

CipherCategoryInfo? findCategoryOf(String cipherId) {
  for (final cat in cipherCategories) {
    if (cat.ciphers.any((c) => c.id == cipherId)) return cat;
  }
  return null;
}
