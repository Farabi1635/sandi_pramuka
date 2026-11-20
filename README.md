# Sandi Pramuka

**Belajar Sandi, Pecahkan Rahasia, Kuasai Pramuka.**

Aplikasi Android untuk belajar, menerjemahkan, dan melatih berbagai sandi kepramukaan.
Dibuat dengan Flutter dan Dart. Seluruh fitur berjalan **tanpa internet**, dan semua data
disimpan di HP pengguna.

## Status

Versi 0.1.0. Sudah ada 16 dari 18 sandi di katalog. Sandi **Kotak 3** dan **Gambar** belum
dikerjakan karena bahan acuannya belum lengkap. Fitur online (login, sinkronisasi,
leaderboard, tantangan antaranggota) tidak dibuat: aplikasi sengaja dibuat sepenuhnya
offline, dan pemindahan data antar-HP dilakukan lewat kode cadangan.

## Fitur

- **Katalog sandi** dengan pencarian, penanda favorit, penanda selesai, dan bilah progres.
- **Materi per sandi:** pengertian, fungsi, cara membaca, tabel simbol, contoh, dan
  kesalahan umum. Tabel dan contoh dihitung dari mesin penerjemah yang sama, jadi tidak
  mungkin berbeda dari hasil terjemahan.
- **Penerjemah dua arah** (teks ke sandi dan sandi ke teks) dengan validasi, pilihan varian,
  salin hasil, dan riwayat. Untuk sandi bergambar, hasilnya juga digambar sebagai simbol.
- **Morse Audio:** bunyi dibuat langsung di aplikasi (tanpa berkas audio), lampu berkedip,
  kecepatan dan nada bisa diatur, latihan mendengar, dan mode senyap.
- **Semaphore Interaktif:** belajar posisi lengan, animasi kata, dan tebak huruf.
- **Kuis otomatis** dengan tiga level, timer, skor, pembahasan, dan riwayat nilai. Soal
  dibuat dari aturan sandi, jadi kunci jawabannya selalu sesuai aturan.
- **Tantangan:** buat pesan rahasia, bagikan kode `SP1-...`, dan kerjakan tantangan teman
  dengan nilai otomatis. Ada juga tantangan harian dari bank soal lokal.
- **Kamus Sandi:** cari satu huruf atau simbol untuk melihat kodenya di semua sandi, atau
  cari sebuah kode untuk mengetahui artinya.
- **Profil, badge, dan sertifikat penyelesaian.** Sertifikat adalah penghargaan internal
  aplikasi dan **bukan** sertifikasi resmi Gerakan Pramuka.
- **Cadangkan dan pulihkan data** lewat kode teks `SPB1-...`.
- Tema terang, gelap, atau mengikuti sistem, ukuran teks, dan pengantar (onboarding).

## Sandi yang tersedia

| Sandi | Bentuk kode di aplikasi |
|---|---|
| Morse | titik dan garis, huruf dipisah spasi, kata dipisah `/` |
| Semaphore | pasangan posisi lengan 1-8, misalnya A = `1.2` |
| AN, AZ | huruf pengganti (dua arah) |
| Balik | dua varian: balik kalimat atau balik tiap kata |
| Abjad (pergeseran) | geseran 1-25 |
| Angka | A = 1 sampai Z = 26 |
| Kotak Koordinat | kotak 5x5, I = J, misalnya K = `25` |
| Braille | nomor titik 1-6, misalnya D = `145` |
| Jam | A = `03.00`, tiap huruf +5 menit |
| Kimia | rumus dari lambang H, O, N, S, A (Morse yang disamarkan) |
| Rumput | puncak kecil `k` dan tinggi `B`, misalnya A = `kB` |
| Sungai | pasangan huruf di seberang kotak 5x8 |
| Koordinat | MERAH PUTIH dan GUDEP SEDIA, misalnya R = `RI` (tanpa Z) |
| Kotak 1, Kotak 2 | ruang `K1`-`K9` dan `X1`-`X4`, titik di belakang |

## Memasang di HP

APK dibuat otomatis oleh GitHub Actions.

1. Buka tab **Actions** di repo, pilih run terbaru yang berstatus hijau.
2. Unduh artifact **sandi-pramuka-apk**, lalu ekstrak.
3. Kirim `app-release.apk` ke HP Android dan buka berkasnya.
4. Izinkan pemasangan dari sumber tidak dikenal jika diminta.

APK ini ditandatangani dengan kunci debug bawaan Flutter. Itu cukup untuk uji coba, tapi
**belum cocok untuk Play Store**. Rilis resmi butuh keystore sendiri (lihat bagian
Rilis).

## Menjalankan di komputer

Butuh Flutter versi stabil terbaru.

```
flutter create --org com.sandipramuka --project-name sandi_pramuka --platforms android .
flutter pub get
dart run flutter_launcher_icons
flutter analyze --no-fatal-infos
flutter test
flutter run
```

Perintah `flutter create .` hanya membuat folder `android/` yang belum ada dan tidak
menimpa kode di `lib/`.

## Struktur proyek

```
lib/
  main.dart, app.dart
  core/
    constants/   katalog sandi dan isi materi (cipher_catalog_seed, cipher_lessons)
    routes/      navigasi GoRouter
    theme/       warna dan tema Material 3
    utils/       penyimpanan lokal (Riverpod + SharedPreferences), badge, cadangan
  services/
    ciphers/     mesin penerjemah tiap sandi (Dart murni)
    translation_service.dart   daftar sandi yang bisa diterjemahkan
    audio_service.dart         pembuat bunyi Morse
  features/      satu folder per halaman (dashboard, learning, translator, ...)
  shared/widgets/  widget bersama, termasuk penggambar simbol tiap sandi
test/            tes unit dan widget
```

Pemisahan utamanya: tampilan di `features/` dan `shared/`, logika sandi di
`services/ciphers/`, data lokal di `core/utils/`.

## Menambah sandi baru

1. Buat kelas turunan `Cipher` di `lib/services/ciphers/` dengan `encode` dan `decode`.
2. Daftarkan di `lib/services/translation_service.dart`.
3. Pastikan sandinya ada di `lib/core/constants/cipher_catalog_seed.dart`.
4. Tambahkan materinya di `lib/core/constants/cipher_lessons.dart` (isi `lessons` dan
   `symbolEntries`).
5. Jika sandinya bergambar, tambahkan widget simbol dan daftarkan di
   `lib/shared/widgets/cipher_symbol.dart` dan `symbol_preview.dart`.
6. Jika kodenya bukan huruf, tambahkan id-nya ke `codeCipherIds` di
   `lib/features/dictionary/dictionary_lookup.dart`.
7. Tulis tes. Kuis, tantangan harian, dan tantangan buatan sendiri otomatis ikut memakai
   sandi baru.

Prinsip yang dipakai selama ini: **jangan mengarang aturan sandi**. Aturan diambil dari bahan
acuan, lalu diperiksa dengan pola atau contoh soal dari bahan itu, dan hasil pemeriksaannya
dijadikan tes otomatis.

## Pengujian

```
flutter test
```

Tes mencakup mesin tiap sandi (termasuk pencocokan dengan contoh dari bahan acuan),
pembuat kuis, kode tantangan, kode cadangan, penyimpanan lokal, hitungan animasi
Semaphore, dan alur navigasi utama.

## Data dan privasi

- Semua data (progres, favorit, riwayat, nilai, profil, pengaturan) disimpan lokal di HP.
- Aplikasi tidak mengirim data apa pun ke server dan tidak memakai iklan.
- Kode tantangan (`SP1-`) dan kode cadangan (`SPB1-`) **bukan enkripsi**. Isinya bisa
  dibaca siapa pun yang memegang kodenya, jadi jangan dibagikan sembarangan. Kode cadangan
  memuat nama dan riwayat terjemahan.
- Karena pengguna aplikasi ini termasuk anak-anak, sebelum dirilis ke toko aplikasi sebaiknya
  kebijakan privasi dan aturan untuk aplikasi anak ditinjau terlebih dahulu.

## Catatan tentang bahan sandi

- **Kimia:** tabel berasal dari satu gambar acuan. Regu lain bisa memakai tabel berbeda.
  Ä, Ö, dan Ch belum didukung.
- **Kotak 1:** pada gambar acuan simbol G tampak sama dengan C. Aplikasi memakai bentuk
  menurut aturan (ruang terbuka di sebelah kiri).
- **Koordinat:** tabel hanya berisi A sampai Y. Varian GUDEP SEDIA memakai pola kolom-baris
  yang sama dengan MERAH PUTIH, dan perlu disepakati dengan regu. Contoh soal pada bahan
  acuan tampak kekurangan satu kode.
- **Semaphore:** tanda khusus (ANGKA, SALAH, SIAP, SELESAI, U-R/PERHATIAN) belum didukung.
- **Kotak 3, Gambar:** belum ada.

## Rilis ke Play Store (belum disiapkan)

Yang masih perlu dikerjakan: membuat keystore sendiri dan menyimpannya dengan aman (jangan
diunggah ke repo), mengatur penandatanganan rilis, menyesuaikan application ID bila perlu
(saat ini `com.sandipramuka.sandi_pramuka`), menyiapkan kebijakan privasi, dan menguji APK
di beberapa ukuran layar HP.

## Peringatan saat analisis kode

`flutter analyze` menampilkan peringatan tingkat info bahwa `package:flutter/material.dart`
sudah deprecated dan digantikan `package:material_ui`. Import lama masih berfungsi, dan
workflow memakai `--no-fatal-infos` agar build tidak berhenti karenanya. Migrasi ke
`material_ui` bisa dilakukan nanti dengan `dart fix --apply --code=migrate_design_widgets`.

## Lambang dan hak

Logo aplikasi adalah desain orisinal dan **bukan** lambang resmi Gerakan Pramuka. Pencapaian,
badge, dan sertifikat di dalam aplikasi adalah penghargaan internal aplikasi, bukan
sertifikasi resmi Gerakan Pramuka. Lisensi kode belum ditentukan.
