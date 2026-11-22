import '../../services/ciphers/braille_cipher.dart';
import '../../services/ciphers/cipher.dart';
import '../../services/ciphers/jam_cipher.dart';
import '../../services/ciphers/kimia_cipher.dart';
import '../../services/ciphers/koordinat_cipher.dart';
import '../../services/ciphers/kotak3_cipher.dart';
import '../../services/ciphers/kotak_cipher.dart';
import '../../services/ciphers/letter_ciphers.dart';
import '../../services/ciphers/morse_cipher.dart';
import '../../services/ciphers/rumput_cipher.dart';
import '../../services/ciphers/semaphore_cipher.dart';
import '../../services/ciphers/sungai_cipher.dart';

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
    case 'braille':
      return brailleDots.entries.toList();
    case 'semaphore':
      return semaphoreCodes.entries.toList();
    case 'jam':
      return [
        for (var i = 0; i < 26; i++) MapEntry(_letters[i], jamTimeOf(i)),
      ];
    case 'kimia':
      return kimiaCodes.entries.toList();
    case 'rumput':
      return rumputCodes.entries.toList();
    case 'sungai':
      return [
        for (var i = 0; i < 26; i++)
          MapEntry(_letters[i], sungaiPairs[_letters[i]]!),
      ];
    case 'koordinat':
      return [
        for (final ch in koordinatGrid.split(''))
          MapEntry(ch, koordinatCode(ch, koordinatMerahPutih)!),
      ];
    case 'kotak1':
      return [
        for (var i = 0; i < 26; i++)
          MapEntry(_letters[i], kotak1Codes[_letters[i]]!),
      ];
    case 'kotak2':
      return [
        for (var i = 0; i < 26; i++)
          MapEntry(_letters[i], kotak2Codes[_letters[i]]!),
      ];
    case 'kotak3':
      return [
        for (var i = 0; i < 26; i++)
          MapEntry(_letters[i], kotak3Codes[_letters[i]]!),
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
  'braille': Lesson(
    definition:
        'Braille adalah tulisan timbul yang dipakai tunanetra. Setiap huruf '
        'ditulis dalam satu sel berisi 6 titik yang disusun 2 kolom dan 3 baris.',
    purpose: 'Melatih ketelitian membaca pola titik sekaligus mengenal '
        'tulisan yang dipakai tunanetra.',
    history:
        'Dikembangkan oleh Louis Braille dari Prancis pada sekitar 1824 dan '
        'kini dipakai di seluruh dunia.',
    steps: [
      'Titik pada sel diberi nomor: kolom kiri 1, 2, 3 (atas ke bawah), kolom kanan 4, 5, 6.',
      'Tiap huruf adalah kombinasi titik yang timbul, misalnya A = titik 1 dan B = titik 1 dan 2.',
      'Huruf A sampai J memakai titik 1, 2, 4, 5. Huruf K sampai T sama dengan A sampai J ditambah titik 3.',
      'Huruf U, V, X, Y, Z sama dengan A sampai E ditambah titik 3 dan 6. Huruf W adalah pengecualian (titik 2, 4, 5, 6).',
      'Saat menulis di sini, tulis nomor titik tiap huruf dengan spasi, dan pisahkan kata dengan tanda "/".',
    ],
    tableCaption: 'Gambar sel untuk tiap huruf (titik hitam = timbul) dan nomor titiknya.',
    examples: [
      LessonExample('SIAGA'),
      LessonExample('PRAMUKA'),
    ],
    mistakes: [
      'Tertukar kolom: titik 1-3 di kolom kiri, titik 4-6 di kolom kanan.',
      'Menganggap W mengikuti pola U sampai Z, padahal W pengecualian.',
      'Angka dan tanda baca memakai aturan tambahan dan belum didukung di aplikasi ini.',
    ],
  ),
  'semaphore': Lesson(
    definition:
        'Sandi Semaphore menyampaikan huruf lewat posisi dua lengan (atau dua '
        'bendera). Ada 8 posisi di sekeliling tubuh yang dinomori 1 sampai 8, '
        'dan setiap huruf adalah sepasang posisi.',
    purpose: 'Dipakai untuk berkomunikasi jarak pandang tanpa suara memakai '
        'bendera. Tanda khusus pada bagan (ANGKA, SALAH, SIAP, SELESAI, '
        'U-R/PERHATIAN) belum didukung di aplikasi ini.',
    steps: [
      'Nomor posisi seperti pada gambar: 1 bawah, 2 kiri bawah, 3 kiri, 4 kiri atas, 5 atas, 6 kanan atas, 7 kanan, 8 kanan bawah.',
      'Tiap huruf adalah pasangan dua nomor, misalnya A = 1.2 (satu lengan ke bawah, satu lengan ke kiri bawah).',
      'Urutan nomor dalam pasangan tidak berpengaruh (1.2 sama dengan 2.1) karena kedua lengan bisa bertukar.',
      'Rumus mudah dihafal: 1.2 sampai 1.8 = A sampai G. 2.3 sampai 2.8 = H, I, K, L, M, N. 3.4 sampai 3.8 = O, P, Q, R, S.',
      'Sisanya: 4.5 = T, 4.6 = U, 4.7 = Y, 5.7 = J, 5.8 = V, 6.7 = W, 6.8 = X, 7.8 = Z.',
    ],
    tableCaption: 'Gambar posisi lengan (dilihat dari depan) dan pasangan nomornya.',
    examples: [
      LessonExample('SIAGA'),
      LessonExample('PRAMUKA'),
    ],
    mistakes: [
      'Tertukar kiri dan kanan: nomor 2, 3, 4 ada di sisi kiri gambar.',
      'Mengira J mengikuti urutan abjad. J = 5.7, bukan 2.x.',
      'Lupa bahwa Y = 4.7 dan J = 5.7 adalah pengecualian dari pola berurutan.',
    ],
  ),
  'jam': Lesson(
    definition:
        'Sandi Jam mengganti setiap huruf dengan sebuah waktu. A = 03.00, lalu '
        'setiap huruf berikutnya bertambah 5 menit.',
    purpose: 'Latihan sandi pengganti huruf yang memakai pola hitungan.',
    steps: [
      'Huruf A dimulai pada pukul 03.00.',
      'Tiap huruf berikutnya bertambah 5 menit: B = 03.05, C = 03.10, D = 03.15, dan seterusnya.',
      'Setelah 03.55 jamnya naik: M = 04.00, N = 04.05.',
      'Huruf terakhir Z = 05.05.',
      'Saat menulis, pisahkan huruf dengan spasi dan kata dengan tanda "/".',
    ],
    tableCaption: 'Huruf dan waktunya.',
    examples: [
      LessonExample('SIAGA'),
      LessonExample('PRAMUKA'),
    ],
    mistakes: [
      'Menulis 03.60, padahal setelah 03.55 jamnya naik menjadi 04.00.',
      'Salah menghitung huruf M: M = 04.00, bukan 03.60.',
      'Memakai jam di luar 03.00 sampai 05.05, karena sandi ini hanya memakai rentang itu.',
    ],
  ),
  'kimia': Lesson(
    definition:
        'Sandi Kimia mengganti setiap huruf, angka, dan beberapa tanda baca '
        'dengan rumus yang tersusun dari lambang H, O, N, S, dan A, misalnya '
        'A = OH dan G = H2O. Angka kecil di belakang lambang menyatakan jumlah '
        'pengulangan.',
    purpose: 'Latihan sandi pengganti yang tampak seperti rumus kimia '
        'sehingga pesannya tersamar.',
    steps: [
      'Cari huruf atau angkanya di tabel, lalu tulis rumusnya.',
      'Pisahkan rumus tiap huruf dengan spasi dan kata dengan tanda "/".',
      'Angka di belakang lambang berarti diulang: HO3 dibaca H, O, O, O.',
      'Rahasia pola: setiap rumus sebenarnya kode Morse yang disamarkan. Lambang O dan A mewakili titik, sedangkan H, S, dan N mewakili garis. Contoh: G (garis, garis, titik) = H2O = H, H, O.',
      'Tabel ini berasal dari gambar bahan materi. Regu lain bisa memakai tabel yang berbeda, jadi sepakati dulu sebelum dipakai.',
    ],
    tableCaption: 'Huruf, angka, dan tanda baca beserta rumusnya (Ä, Ö, dan Ch belum didukung).',
    examples: [
      LessonExample('SIAGA'),
      LessonExample('PRAMUKA'),
    ],
    mistakes: [
      'Membaca O3 sebagai "O dan 3". Maksudnya O diulang tiga kali (OOO).',
      'Tidak memberi spasi antarrumus sehingga sulit dipisahkan.',
      'Mengira H, O, N, S, A sebagai unsur kimia sungguhan. Di sini semuanya hanya lambang kode.',
    ],
  ),
  'rumput': Lesson(
    definition:
        'Sandi Rumput menuliskan huruf sebagai garis bergelombang seperti '
        'rumput. Ada dua jenis puncak: puncak kecil dan puncak tinggi.',
    purpose: 'Latihan sandi bergambar yang mengajarkan pola dua jenis tanda '
        'dengan bentuk yang berbeda.',
    steps: [
      'Setiap huruf adalah deretan puncak yang dibaca dari kiri ke kanan.',
      'Puncak kecil sama dengan titik pada Morse, puncak tinggi sama dengan garis.',
      'Contoh: A = puncak kecil lalu puncak tinggi (sama dengan .- pada Morse).',
      'Saat menulis dengan huruf: puncak kecil ditulis k dan puncak tinggi ditulis B, jadi A = kB. Pisahkan huruf dengan spasi dan kata dengan "/".',
    ],
    tableCaption: 'Gambar rumput tiap huruf beserta kodenya (k = puncak kecil, B = puncak tinggi).',
    examples: [
      LessonExample('SIAGA'),
      LessonExample('PRAMUKA'),
    ],
    mistakes: [
      'Tertukar puncak kecil dan puncak tinggi.',
      'Salah menghitung jumlah puncak kecil, misalnya S = 3 puncak kecil dan H = 4 puncak kecil.',
      'Angka belum didukung di aplikasi ini.',
    ],
  ),
  'sungai': Lesson(
    definition:
        'Sandi Sungai memakai kotak 5 baris dan 8 kolom. Huruf diletakkan '
        'mengelilingi kotak, dimulai dari kata SUNGAI. Setiap huruf diganti '
        'dengan huruf yang berada di seberangnya.',
    purpose: 'Latihan sandi pengganti huruf yang memakai gambar kotak dan '
        'pasangan huruf yang saling berhadapan.',
    steps: [
      'Tulis SUNGAI di baris atas, lalu lanjutkan dengan huruf abjad yang belum dipakai: B dan C.',
      'Lanjutkan mengelilingi kotak searah jarum jam: sisi kanan D, E, F, H, J (atas ke bawah), sisi bawah K, L, M, O, P, Q, R, T (kanan ke kiri), lalu sisi kiri V, W, X, Y, Z (bawah ke atas).',
      'Untuk menyandi, tarik garis lurus dari hurufmu ke huruf di seberangnya. Contoh: S di atas berpasangan dengan T di bawah, dan E di kanan berpasangan dengan Y di kiri.',
      'Pasangannya timbal balik, jadi membaca sandi memakai aturan yang sama.',
    ],
    tableCaption: 'Kotak Sungai dan pasangan hurufnya (berlaku dua arah).',
    examples: [
      LessonExample('STELLA MARIS JAYA'),
      LessonExample('BERTANGGUNGJAWAB'),
      LessonExample('SIAGA'),
    ],
    mistakes: [
      'Salah arah mengelilingi kotak sehingga urutan huruf tertukar.',
      'Lupa melewati huruf yang sudah dipakai pada kata SUNGAI.',
      'Menarik pasangan dari huruf di sisi yang sama, padahal harus dari sisi seberang.',
    ],
  ),
  'koordinat': Lesson(
    definition:
        'Sandi Koordinat memakai tabel 5 x 5 berisi huruf A sampai Y. Kolom '
        'diberi nama dari huruf kata MERAH dan baris dari huruf kata PUTIH. '
        'Setiap huruf ditulis sebagai dua huruf: huruf kolom lalu huruf baris.',
    purpose: 'Latihan membaca koordinat. Namanya berbeda di tiap daerah; yang '
        'umum dikenal adalah sandi MERAH PUTIH dan GUDEP SEDIA.',
    steps: [
      'Susun huruf A sampai Y dalam kotak 5 x 5, baris demi baris. Huruf Z tidak ada di tabel.',
      'Beri nama kolom dengan huruf kata MERAH dari kiri ke kanan, dan nama baris dengan huruf kata PUTIH dari atas ke bawah.',
      'Cari hurufnya, tarik ke atas untuk nama kolom dan ke samping untuk nama baris. Contoh: R ada di kolom R dan baris I, jadi kodenya RI.',
      'Tulis kode tiap huruf dengan spasi dan kata dengan tanda "/". Contoh: PRAMUKA = MI RI MP RT MH MT MP.',
      'Varian GUDEP SEDIA memakai pola yang sama dengan kolom GUDEP dan baris SEDIA. Sepakati dulu dengan regumu.',
    ],
    tableCaption: 'Tabel MERAH PUTIH (kolom MERAH, baris PUTIH) dan kode tiap huruf. Huruf Z tidak ada.',
    examples: [
      LessonExample('PRAMUKA'),
      LessonExample('PRAMUKA ITU ASIK'),
      LessonExample('PRAMUKA',
          options: CipherOptions(variantId: koordinatGudepSedia),
          label: 'Varian GUDEP SEDIA'),
    ],
    mistakes: [
      'Tertukar urutan: huruf kolom (atas) dulu, baru huruf baris (samping).',
      'Mencari huruf Z, padahal tabel hanya berisi A sampai Y.',
      'Mencampur kata kunci MERAH PUTIH dengan GUDEP SEDIA dalam satu pesan.',
    ],
  ),
  'kotak1': Lesson(
    definition:
        'Sandi Kotak 1 memakai dua bentuk: tanda pagar (#) dan tanda silang '
        '(X). Setiap huruf diganti garis yang mengelilingi ruangnya, dan huruf '
        'kedua di tiap pasangan diberi sebuah titik.',
    purpose: 'Latihan sandi bergambar yang mengenalkan pola bentuk dan titik.',
    steps: [
      'Gambar tanda pagar (#) dengan 9 ruang, lalu isi pasangan huruf: AB, CD, EF / GH, IJ, KL / MN, OP, QR.',
      'Gambar tanda silang (X) dengan 4 ruang: atas UV, kiri ST, kanan WX, bawah YZ.',
      'Huruf pertama dalam pasangan diganti garis yang mengelilingi ruangnya. Huruf kedua memakai garis yang sama dengan sebuah titik di dalamnya.',
      'Contoh: A = garis kanan dan bawah dari ruang pertama. B = bentuk yang sama dengan satu titik.',
      'Saat menulis dengan huruf: ruang # bernomor K1 sampai K9 dan ruang X bernomor X1 (atas), X2 (kiri), X3 (kanan), X4 (bawah). Titik ditulis "." di belakang, misalnya B = K1. dan V = X1.',
    ],
    tableCaption: 'Gambar simbol tiap huruf dan kodenya (titik hitam di dalam simbol = tanda titik).',
    examples: [
      LessonExample('SIAGA'),
      LessonExample('PRAMUKA'),
    ],
    mistakes: [
      'Lupa menambahkan titik pada huruf kedua dalam pasangan.',
      'Tertukar ruang tanda silang: UV atas, ST kiri, WX kanan, YZ bawah.',
      'Pada gambar bahan materi, simbol G tampak sama dengan C. Mengikuti aturan bentuknya, G seharusnya terbuka di sebelah kiri, dan itu yang dipakai di aplikasi ini.',
    ],
  ),
  'kotak2': Lesson(
    definition:
        'Sandi Kotak 2 memakai tanda pagar (#) dengan 9 ruang, tiap ruang '
        'berisi tiga huruf (ruang terakhir dua huruf). Huruf diganti garis '
        'yang mengelilingi ruangnya, dan jumlah titik menunjukkan urutan '
        'hurufnya.',
    purpose: 'Latihan sandi bergambar dengan tiga huruf di tiap ruang.',
    steps: [
      'Gambar tanda pagar (#) dengan 9 ruang, lalu isi: ABC, DEF, GHI / JKL, MNO, PQR / STU, VWX, YZ.',
      'Huruf pertama di ruang diganti garis yang mengelilingi ruangnya tanpa titik.',
      'Huruf kedua memakai garis yang sama dengan satu titik, dan huruf ketiga dengan dua titik.',
      'Contoh: A = garis kanan dan bawah ruang pertama, B = bentuk itu dengan satu titik, C = bentuk itu dengan dua titik.',
      'Saat menulis dengan huruf: ruang bernomor K1 sampai K9 dan titik ditulis "." di belakang, misalnya A = K1, B = K1., C = K1..',
    ],
    tableCaption: 'Gambar simbol tiap huruf dan kodenya (jumlah titik menunjukkan urutan huruf dalam ruang).',
    examples: [
      LessonExample('SIAGA'),
      LessonExample('PRAMUKA'),
    ],
    mistakes: [
      'Salah menghitung titik: huruf pertama 0 titik, kedua 1 titik, ketiga 2 titik.',
      'Menambahkan titik kedua pada ruang terakhir. Ruang YZ hanya berisi dua huruf.',
      'Tertukar dengan Sandi Kotak 1 yang hanya memakai satu titik untuk huruf kedua.',
    ],
  ),
  'kotak3': Lesson(
    definition:
        'Sandi Kotak 3 memakai gambar tanda pagar (#) yang ditumpuk dengan '
        'belah ketupat sehingga membentuk 26 ruang. Setiap huruf diganti garis '
        'yang membatasi ruangnya. Huruf bertitik membedakan dua ruang yang '
        'bentuk garisnya sama.',
    purpose: 'Latihan sandi bergambar yang paling rumit di antara sandi kotak.',
    steps: [
      'Gambar persegi panjang di tengah dengan dua garis tegak dan dua garis datar yang menembus tepinya (tanda pagar).',
      'Gambar belah ketupat yang sisinya melewati keempat sudut persegi tengah, dengan ujung atas, kanan, bawah, dan kiri di luar persegi.',
      'Isi ruang dengan huruf seperti pada gambar kunci: A dan B di tengah, lima huruf di sekitar tiap sudut persegi, dan F, L, R, X di ujung belah ketupat.',
      'Tiap huruf diganti garis yang membatasi ruangnya: kotak penuh untuk ruang tengah (A, B), dua garis dari satu sudut untuk ruang sudut, dan dua garis miring untuk ujung belah ketupat (F, L, R, X).',
      'Delapan pasang ruang punya bentuk garis yang sama (misalnya E dan N). Salah satunya diberi titik: B, D, H, J, N, P, T, V, dan Z.',
      'Saat menulis dengan huruf: bentuk dinomori K1 sampai K17 (lihat tabel), titik ditulis "." di belakang, misalnya A = K1 dan B = K1.',
    ],
    tableCaption: 'Gambar kunci (huruf dan titik di tiap ruang) dan simbol tiap huruf.',
    examples: [
      LessonExample('SIAGA'),
      LessonExample('PRAMUKA'),
    ],
    mistakes: [
      'Lupa menambahkan titik pada huruf yang bertitik.',
      'Tertukar dua ruang yang bentuk garisnya sama, misalnya E (tanpa titik) dan N (bertitik).',
      'Gambar acuan beresolusi rendah. Susunan huruf dan titik di aplikasi ini disimpulkan dari gambar kunci dan diperiksa dengan aturan titiknya. Jika regumu memakai gambar yang berbeda, sepakati dulu.',
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
