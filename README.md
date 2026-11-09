# SANDI PRAMUKA

Belajar Sandi, Pecahkan Rahasia, Kuasai Pramuka. Aplikasi Flutter offline-first.

## Status
- [x] Tahap 1 - Foundation (tema, GoRouter, bottom nav 5 tab, dashboard, katalog awal, pengaturan tema/ukuran teks)
- [ ] Tahap 2 - Materi sandi
- [ ] Tahap 3 - Engine penerjemah
- [ ] Tahap 4 - Interaktivitas
- [ ] Tahap 5 - Database offline
- [ ] Tahap 6 - Firebase
- [ ] Tahap 7 - Penyempurnaan
- [ ] Tahap 8 - Build APK

Halaman bertanda "Tahap N" masih placeholder dan akan diisi di tahap tersebut.

## Setup (sekali saja)
Folder `android/` belum ada, dibuat oleh Flutter:

    flutter create --org com.sandipramuka --project-name sandi_pramuka --platforms android .
    flutter pub get
    flutter analyze
    flutter test
    flutter run

Perintah `flutter create .` tidak menimpa file `lib/` dan `pubspec.yaml` yang sudah ada,
tetapi jika `test/widget_test.dart` tertimpa, salin ulang dari repo.

## Logo dan ikon
- Logo orisinal: `assets/images/app_logo.svg` / `app_logo.png` (perisai, lubang kunci, tunas, titik-garis Morse).
- Bukan lambang resmi Gerakan Pramuka.
- Ikon launcher Android dibuat dengan:

      dart run flutter_launcher_icons

  (jalankan setelah `flutter pub get`).
- Logo di dalam aplikasi digambar dengan `CustomPainter` (`lib/shared/widgets/app_logo.dart`, `cipher_logo.dart`), jadi tajam di semua resolusi.

## Build lewat GitHub Actions
Setiap push ke `main` menjalankan analyze, test, dan build APK
(`.github/workflows/build.yml`). Unduh APK di tab Actions > run terbaru > Artifacts.
