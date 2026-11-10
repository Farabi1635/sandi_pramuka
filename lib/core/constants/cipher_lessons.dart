import '../../services/ciphers/cipher.dart';
import '../../services/ciphers/letter_ciphers.dart';
import '../../services/ciphers/morse_cipher.dart';

/// Susunan kotak 5x5 untuk Sandi Kotak Koordinat (I = J).
const String kotakGrid = 'ABCDEFGHIKLMNOPQRSTUVWXYZ';

const String _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

class LessonExample {
  const LessonExample(
    this.plain, {
    this.options = const CipherOptions(),
    this.label,
  });
  final String plain;
  final CipherOptions options;
  final String? label;
}

class Lesson {
  const Lesson({
    required this.definition,
    required this.purpose,
    required this.steps,
    required this.examples,
    required this.mistakes,
    this.history,
    this.tableCaption,
  });

  final String definition;
  final String purpose;
  final String? history;
  final List<String> steps;
  final String? tableCaption;
  final List<LessonExample> examples;
  final List<String> mistakes;
}

bool hasLesson(String cipherId) => lessons.containsKey(cipherId);

/// Isi tabel simbol diambil dari data mesin penerjemah, bukan diketik ulang.
List<MapEntry<String, String>> symbolEntries(String cipherId) {
  switch (cipherId) {
    case 'morse':
      return morseTable.entries.toList();
    case 'an':
      return [
        for (var i = 0; i < 13; i++) MapEntry(_letters[i], _letters[i + 13]),
      ];
    case 'az':
      return [
        for (var i = 0; i < 13; i++) MapEntry(_letters[i], _letters[25 - i]),
      ];
    case 'geser':
      return [
        for (var i = 0; i < 26; i++)
          MapEntry(_letters[i], _letters[(i + 3) % 26]),
      ];
    case 'angka':
      return [
        for (var i = 0; i < 26; i++) MapEntry(_letters[i], '${i + 1}'),
      ];
    default:
      return const [];
  }
}

const Map<String, Lesson> lessons = {
  'morse': Lesson(
    definition:
        'Sandi Morse mengubah huruf, angka, dan tanda baca menjadi rangkaian '
        'titik (.) dan garis (-). Titik berbunyi pendek, garis berbunyi panjang.',
    purpose:
        'Dipakai untuk mengirim pesan jarak jauh lewat bunyi, cahaya senter, '
        'peluit, atau ketukan. Di Pramuka, Morse sering dilatih lewat peluit '
        'dan senter.',
    history:
        'Dikembangkan pada sekitar 1830-an sampai 1840-an oleh Samuel Morse '
        'dan Alfred Vail untuk telegraf. Versi internasional yang dipakai '
        'sekarang berasal dari penyesuaian pada pertengahan abad ke-19.',
    steps: [
      'Garis berdurasi sekitar 3 kali panjang titik.',
      'Jeda antarsimbol dalam satu huruf selama 1 titik.',
      'Jeda antarhuruf selama 3 titik, antarkata selama 7 titik.',
      'Saat menulis, pisahkan huruf dengan spasi dan kata dengan garis miring (/).',
    ],
    tableCaption: 'Huruf, angka, dan tanda baca (tanda / dipakai sebagai '
        'pemisah kata, jadi tidak dimasukkan).',
    examples: [
      LessonExample('SOS'),
      LessonExample('SIAGA'),
      LessonExample('PRAMUKA GARUDA'),
    ],
    mistakes: [
      'Lupa memberi spasi antarhuruf, sehingga ".-" (A) tertukar dengan "." "-" (E T).',
      'Menulis garis terlalu pendek sehingga mirip titik.',
      'Tidak memisahkan kata dengan garis miring.',
    ],
  ),
  'an': Lesson(
    definition:
        'Sandi AN membagi abjad menjadi dua bagian: A sampai M dan N sampai Z. '
        'Setiap huruf diganti dengan pasangannya di bagian lain.',
    purpose: 'Latihan dasar sandi pengganti huruf yang mudah diingat dan '
        'cepat dipakai karena enkripsi dan dekripsinya sama.',
    history:
        'Prinsip yang sama dikenal di dunia sandi umum sebagai ROT13.',
    steps: [
      'Tulis abjad A sampai M di baris atas, N sampai Z di baris bawah.',
      'Ganti setiap huruf dengan huruf pasangannya (A=N, B=O, ... M=Z).',
      'Untuk membaca, lakukan hal yang sama karena pasangannya berlaku dua arah.',
    ],
    tableCaption: 'Pasangan huruf (berlaku dua arah): huruf atas = huruf bawah.',
    examples: [
      LessonExample('SIAGA'),
      LessonExample('PRAMUKA'),
    ],
    mistakes: [
      'Menggeser huruf secara berurutan, padahal yang benar adalah pasangan N-Z.',
      'Lupa bahwa huruf N sampai Z dikembalikan ke A sampai M.',
    ],
  ),
  'az': Lesson(
    definition:
        'Sandi AZ membalik urutan abjad: huruf pertama ditukar dengan huruf '
        'terakhir, huruf kedua dengan huruf kedua dari belakang, dan seterusnya.',
    purpose: 'Latihan sandi pengganti huruf yang mudah dihafal dan bersifat '
        'dua arah.',
    history: 'Prinsip yang sama dikenal sebagai sandi Atbash.',
    steps: [
      'Tulis abjad A sampai Z, lalu tulis abjad terbalik Z sampai A di bawahnya.',
      'Ganti setiap huruf dengan huruf di bawahnya (A=Z, B=Y, C=X, ...).',
      'Untuk membaca, gunakan aturan yang sama.',
    ],
    tableCaption: 'Pasangan huruf (berlaku dua arah): huruf atas = huruf bawah.',
    examples: [
      LessonExample('SIAGA'),
      LessonExample('PRAMUKA'),
    ],
    mistakes: [
      'Tertukar dengan Sandi AN yang memakai pasangan A=N.',
      'Salah menghitung pasangan huruf di tengah abjad (M=N).',
    ],
  ),
  'balik': Lesson(
    definition:
        'Sandi Balik menuliskan huruf dengan urutan terbalik, sehingga pesan '
        'dibaca dari belakang.',
    purpose: 'Latihan sandi paling sederhana, cocok untuk pengenalan.',
    steps: [
      'Pilih aturan regu: membalik seluruh kalimat, atau membalik tiap kata.',
      'Tulis huruf dari yang paling belakang ke depan sesuai aturan itu.',
      'Untuk membaca, balik lagi dengan aturan yang sama.',
    ],
    examples: [
      LessonExample('SIAGA PRAMUKA',
          options: CipherOptions(variantId: BalikCipher.variantText),
          label: 'Balik seluruh kalimat'),
      LessonExample('SIAGA PRAMUKA',
          options: CipherOptions(variantId: BalikCipher.variantWord),
          label: 'Balik tiap kata'),
    ],
    mistakes: [
      'Mencampur dua aturan (balik kalimat dan balik kata) dalam satu pesan.',
      'Lupa membalik spasi pada aturan balik seluruh kalimat.',
    ],
  ),
  'geser': Lesson(
    definition:
        'Sandi Abjad dengan pergeseran mengganti setiap huruf dengan huruf '
        'yang berjarak beberapa langkah di abjad. Jumlah langkah disebut kunci.',
    purpose: 'Mengenalkan konsep kunci pada sandi: pesan hanya terbaca oleh '
        'orang yang tahu jumlah geserannya.',
    history:
        'Dikenal sebagai sandi Caesar, diambil dari nama Julius Caesar yang '
        'menurut catatan sejarah memakai geseran tiga huruf.',
    steps: [
      'Sepakati kunci geseran, misalnya 3.',
      'Untuk menyandi, geser setiap huruf maju sebanyak kunci (A menjadi D).',
      'Setelah Z kembali ke A (X menjadi A, Y menjadi B).',
      'Untuk membaca, geser mundur sebanyak kunci.',
    ],
    tableCaption: 'Contoh dengan kunci 3: huruf asli di atas, huruf sandi di bawah.',
    examples: [
      LessonExample('PRAMUKA',
          options: CipherOptions(shift: 3), label: 'Geser 3'),
      LessonExample('PRAMUKA',
          options: CipherOptions(shift: 5), label: 'Geser 5'),
    ],
    mistakes: [
      'Lupa kembali ke A setelah melewati Z.',
      'Menggeser mundur saat menyandi, atau maju saat membaca.',
      'Memakai kunci yang berbeda antara pengirim dan penerima.',
    ],
  ),
  'angka': Lesson(
    definition:
        'Sandi Angka mengganti setiap huruf dengan nomor urutnya di abjad: '
        'A=1, B=2, sampai Z=26.',
    purpose: 'Latihan dasar sandi pengganti huruf dengan angka.',
    steps: [
      'Ganti tiap huruf dengan nomor urutnya.',
      'Pisahkan huruf dengan tanda "-" dan kata dengan tanda "/".',
      'Untuk membaca, ubah setiap angka kembali menjadi hurufnya.',
    ],
    tableCaption: 'Huruf dan nomor urutnya.',
    examples: [
      LessonExample('PRAMUKA'),
      LessonExample('SIAGA PENGGALANG'),
    ],
    mistakes: [
      'Tidak memberi pemisah sehingga "1-2" terbaca "12".',
      'Salah menghitung huruf di atas J, misalnya Q menjadi 16 (yang benar 17).',
    ],
  ),
  'kotak_koordinat': Lesson(
    definition:
        'Sandi Kotak Koordinat menyusun abjad dalam kotak 5x5. Setiap huruf '
        'ditulis sebagai dua angka: nomor baris lalu nomor kolom.',
    purpose: 'Latihan membaca koordinat sekaligus sandi pengganti huruf.',
    history:
        'Dikenal sebagai kotak Polybius, diambil dari nama sejarawan Yunani '
        'kuno yang menggambarkan sistem ini.',
    steps: [
      'Susun abjad dalam kotak 5x5, huruf I dan J berbagi satu kotak.',
      'Cari hurufnya, tulis nomor baris diikuti nomor kolom (K = baris 2, kolom 5, ditulis 25).',
      'Pisahkan huruf dengan spasi dan kata dengan tanda "/".',
      'Susunan kotak bisa berbeda antar regu. Sepakati dulu sebelum dipakai.',
    ],
    examples: [
      LessonExample('KAMU'),
      LessonExample('SIAGA'),
    ],
    mistakes: [
      'Tertukar urutan: harus baris dulu, baru kolom.',
      'Tidak memberi spasi sehingga angka sulit dipisah.',
      'Lupa bahwa I dan J memakai kotak yang sama.',
    ],
  ),
};
