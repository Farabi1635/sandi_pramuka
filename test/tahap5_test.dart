import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sandi_pramuka/core/utils/achievements.dart';
import 'package:sandi_pramuka/core/utils/settings_provider.dart';
import 'package:sandi_pramuka/core/utils/translation_history_provider.dart';

TranslationRecord _rec(String output, {int at = 1}) => TranslationRecord(
      cipherId: 'morse',
      variantId: null,
      shift: 3,
      mode: 'encode',
      input: 'A',
      output: output,
      at: at,
    );

void main() {
  group('Badge pencapaian', () {
    test('belum ada yang diraih saat statistik kosong', () {
      final badges = computeBadges(const AchievementStats());
      expect(badges.where((b) => b.earned), isEmpty);
    });

    test('badge diraih sesuai syarat', () {
      const s = AchievementStats(
        completedLessons: 7,
        totalLessons: 7,
        translationCount: 10,
        quizCount: 3,
        bestScore: 100,
        bestMorseScore: 80,
        averageScore: 90,
      );
      final earned = {
        for (final b in computeBadges(s)) b.id: b.earned,
      };
      expect(earned['pemula_sandi'], isTrue);
      expect(earned['rajin_belajar'], isTrue);
      expect(earned['ahli_morse'], isTrue);
      expect(earned['pemecah_kode'], isTrue);
      expect(earned['juara_kuis'], isTrue);
    });

    test('Ahli Morse butuh nilai minimal 80', () {
      final b = computeBadges(const AchievementStats(bestMorseScore: 79))
          .firstWhere((e) => e.id == 'ahli_morse');
      expect(b.earned, isFalse);
    });
  });

  group('Riwayat terjemahan', () {
    test('JSON bolak-balik', () {
      final r = _rec('... --- ...');
      final back = TranslationRecord.fromJson(r.toJson());
      expect(back.sameContent(r), isTrue);
      expect(back.variantId, isNull);
    });

    test('tersimpan lokal dan terbaca ulang', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final c1 = ProviderContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );
      await c1.read(translationHistoryProvider.notifier).add(_rec('X'));
      await c1.read(translationHistoryProvider.notifier).add(_rec('Y'));
      expect(c1.read(translationHistoryProvider).length, 2);

      final c2 = ProviderContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );
      final loaded = c2.read(translationHistoryProvider);
      expect(loaded.length, 2);
      expect(loaded.first.output, 'Y');

      c1.dispose();
      c2.dispose();
    });

    test('catatan kembar berurutan tidak diulang', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );
      final n = c.read(translationHistoryProvider.notifier);
      await n.add(_rec('X'));
      await n.add(_rec('X', at: 2));
      expect(c.read(translationHistoryProvider).length, 1);
      c.dispose();
    });

    test('dibatasi 50 catatan', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );
      final n = c.read(translationHistoryProvider.notifier);
      for (var i = 0; i < 60; i++) {
        await n.add(_rec('hasil $i', at: i));
      }
      expect(c.read(translationHistoryProvider).length, 50);
      expect(c.read(translationHistoryProvider).first.output, 'hasil 59');
      c.dispose();
    });
  });
}
