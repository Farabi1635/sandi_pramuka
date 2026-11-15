import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sandi_pramuka/core/utils/backup_codec.dart';

Future<SharedPreferences> _prefs(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPreferences.getInstance();
}

String _craft(String json) =>
    'SPB1-${base64Url.encode(gzip.encode(utf8.encode(json))).replaceAll('=', '')}';

const Map<String, Object> _sample = {
  'completed_ciphers': ['morse', 'an'],
  'favorite_ciphers': ['morse'],
  'quiz_results': ['{"a":1}', '{"a":2}', '{"a":3}'],
  'translation_history': ['x', 'y'],
  'user_name': 'Budi',
  'user_level': 'siaga',
  'daily_done': '2026-11-11',
  'certificate_date': '2026-11-12',
};

void main() {
  group('Cadangan dan pemulihan', () {
    test('bolak-balik lengkap', () async {
      final source = await _prefs(_sample);
      final code = createBackupCode(source, now: DateTime(2026, 11, 14));
      expect(code.startsWith('SPB1-'), isTrue);

      final parsed = parseBackupCode(code);
      expect(parsed.error, isNull);
      expect(parsed.data!.createdAt, DateTime(2026, 11, 14));

      final target = await _prefs({});
      await applyBackup(target, parsed.data!);
      expect(target.getStringList('completed_ciphers'), ['morse', 'an']);
      expect(target.getStringList('favorite_ciphers'), ['morse']);
      expect(target.getStringList('quiz_results')!.length, 3);
      expect(target.getStringList('translation_history'), ['x', 'y']);
      expect(target.getString('user_name'), 'Budi');
      expect(target.getString('user_level'), 'siaga');
      expect(target.getString('daily_done'), '2026-11-11');
      expect(target.getString('certificate_date'), '2026-11-12');
    });

    test('ringkasan isi cadangan', () async {
      final prefs = await _prefs(_sample);
      final s = parseBackupCode(createBackupCode(prefs)).data!.summary;
      expect(s.lessons, 2);
      expect(s.favorites, 1);
      expect(s.quizzes, 3);
      expect(s.translations, 2);
      expect(s.name, 'Budi');
    });

    test('data yang tidak ada di cadangan dihapus dari HP tujuan', () async {
      final source = await _prefs({'user_name': 'Sari'});
      final code = createBackupCode(source);

      final target = await _prefs({
        'favorite_ciphers': ['x'],
        'user_name': 'Lama',
        'user_level': 'pandega',
      });
      await applyBackup(target, parseBackupCode(code).data!);
      expect(target.getString('user_name'), 'Sari');
      expect(target.getStringList('favorite_ciphers'), isNull);
      expect(target.getString('user_level'), isNull);
    });

    test('pengaturan tema tidak ikut terhapus atau tercadangkan', () async {
      final source = await _prefs({
        'theme_mode': 'dark',
        'onboarding_done': true,
        'user_name': 'Budi',
      });
      final code = createBackupCode(source);
      final target = await _prefs({'theme_mode': 'light'});
      await applyBackup(target, parseBackupCode(code).data!);
      expect(target.getString('theme_mode'), 'light');
    });

    test('kode dengan spasi dan baris baru tetap terbaca', () async {
      final prefs = await _prefs(_sample);
      final code = createBackupCode(prefs);
      final messy = '${code.substring(0, 20)}\n ${code.substring(20)}\n';
      expect(parseBackupCode(messy).error, isNull);
    });
  });

  group('Kode tidak valid ditolak', () {
    test('kosong, asal, dan potongan', () {
      expect(parseBackupCode('').error, isNotNull);
      expect(parseBackupCode('abc').error, isNotNull);
      expect(parseBackupCode('SPB1-').error, isNotNull);
      expect(parseBackupCode('SPB1-%%%').error, isNotNull);
    });

    test('bukan format gzip', () {
      final fake = 'SPB1-${base64Url.encode(utf8.encode('halo')).replaceAll('=', '')}';
      expect(parseBackupCode(fake).error, isNotNull);
    });

    test('kode terpotong', () async {
      final prefs = await _prefs(_sample);
      final code = createBackupCode(prefs);
      expect(parseBackupCode(code.substring(0, code.length ~/ 2)).error,
          isNotNull);
    });

    test('versi tidak dikenal', () {
      expect(
        parseBackupCode(_craft('{"v":2,"d":{"user_name":"A"}}')).error,
        isNotNull,
      );
    });

    test('tipe data salah', () {
      expect(
        parseBackupCode(_craft('{"v":1,"d":{"completed_ciphers":"morse"}}'))
            .error,
        isNotNull,
      );
      expect(
        parseBackupCode(_craft('{"v":1,"d":{"completed_ciphers":[1,2]}}'))
            .error,
        isNotNull,
      );
      expect(
        parseBackupCode(_craft('{"v":1,"d":{"user_name":5}}')).error,
        isNotNull,
      );
    });

    test('cadangan kosong atau kunci asing diabaikan', () {
      expect(parseBackupCode(_craft('{"v":1,"d":{}}')).error, isNotNull);
      expect(
        parseBackupCode(_craft('{"v":1,"d":{"kunci_asing":"x"}}')).error,
        isNotNull,
      );
      final ok = parseBackupCode(
          _craft('{"v":1,"d":{"user_name":"A","kunci_asing":"x"}}'));
      expect(ok.error, isNull);
      expect(ok.data!.values.containsKey('kunci_asing'), isFalse);
    });
  });
}
