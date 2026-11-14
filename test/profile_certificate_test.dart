import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sandi_pramuka/core/utils/achievements.dart';
import 'package:sandi_pramuka/core/utils/certificate.dart';
import 'package:sandi_pramuka/core/utils/settings_provider.dart';
import 'package:sandi_pramuka/core/utils/user_profile_provider.dart';

AchievementStats _stats({
  int completed = 8,
  int total = 8,
  int quizzes = 3,
  int average = 70,
}) =>
    AchievementStats(
      completedLessons: completed,
      totalLessons: total,
      quizCount: quizzes,
      averageScore: average,
    );

Future<ProviderContainer> _container() async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
}

void main() {
  group('Syarat sertifikat', () {
    test('memenuhi semua syarat', () {
      expect(certificateStatus(_stats()).eligible, isTrue);
    });

    test('materi belum semua selesai', () {
      final s = certificateStatus(_stats(completed: 7));
      expect(s.lessonsDone, isFalse);
      expect(s.eligible, isFalse);
    });

    test('jumlah kuis kurang', () {
      final s = certificateStatus(_stats(quizzes: 2, average: 100));
      expect(s.quizzesDone, isFalse);
      expect(s.eligible, isFalse);
    });

    test('rata-rata nilai kurang dari 70', () {
      expect(certificateStatus(_stats(average: 69)).eligible, isFalse);
      expect(certificateStatus(_stats(average: 70)).eligible, isTrue);
    });

    test('tanpa materi tidak pernah memenuhi syarat', () {
      expect(certificateStatus(_stats(completed: 0, total: 0)).eligible,
          isFalse);
    });
  });

  group('Format tanggal', () {
    test('bulan dalam bahasa Indonesia', () {
      expect(formatIndonesianDate(DateTime(2026, 11, 11)), '11 November 2026');
      expect(formatIndonesianDate(DateTime(2027, 1, 5)), '5 Januari 2027');
      expect(formatIndonesianDate(DateTime(2026, 8, 17)), '17 Agustus 2026');
    });
  });

  group('Profil pengguna', () {
    test('tersimpan dan terbaca ulang', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = await _container();
      await c1
          .read(userProfileProvider.notifier)
          .save(name: 'Budi', level: ScoutLevel.penggalang);

      final c2 = await _container();
      final p = c2.read(userProfileProvider);
      expect(p.name, 'Budi');
      expect(p.level, ScoutLevel.penggalang);
      c1.dispose();
      c2.dispose();
    });

    test('nama dirapikan dan dibatasi 30 karakter', () async {
      SharedPreferences.setMockInitialValues({});
      final c = await _container();
      final n = c.read(userProfileProvider.notifier);

      await n.save(name: '  Budi    Santoso  ', level: null);
      expect(c.read(userProfileProvider).name, 'Budi Santoso');

      await n.save(name: 'A' * 40, level: null);
      expect(c.read(userProfileProvider).name.length, 30);
      c.dispose();
    });

    test('tingkatan bisa dihapus', () async {
      SharedPreferences.setMockInitialValues({});
      final c = await _container();
      final n = c.read(userProfileProvider.notifier);
      await n.save(name: 'Sari', level: ScoutLevel.siaga);
      await n.save(name: 'Sari', level: null);

      final c2 = await _container();
      expect(c2.read(userProfileProvider).level, isNull);
      expect(c2.read(userProfileProvider).name, 'Sari');
      c.dispose();
      c2.dispose();
    });

    test('profil kosong secara bawaan', () async {
      SharedPreferences.setMockInitialValues({});
      final c = await _container();
      expect(c.read(userProfileProvider).hasName, isFalse);
      expect(c.read(userProfileProvider).level, isNull);
      c.dispose();
    });
  });
}
