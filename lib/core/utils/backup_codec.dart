import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

/// Data belajar yang ikut dicadangkan. Pengaturan tema dan penanda
/// onboarding sengaja tidak ikut.
const List<String> backupListKeys = [
  'completed_ciphers',
  'favorite_ciphers',
  'quiz_results',
  'translation_history',
];

const List<String> backupStringKeys = [
  'daily_done',
  'certificate_date',
  'user_name',
  'user_level',
];

const String _prefix = 'SPB1-';
const int _version = 1;
const int _maxCodeLength = 2000000;

class BackupSummary {
  const BackupSummary({
    required this.lessons,
    required this.favorites,
    required this.quizzes,
    required this.translations,
    required this.name,
  });

  final int lessons;
  final int favorites;
  final int quizzes;
  final int translations;
  final String name;
}

class BackupData {
  const BackupData({required this.createdAt, required this.values});

  final DateTime? createdAt;
  final Map<String, Object> values;

  List<String> _list(String key) {
    final v = values[key];
    return v is List<String> ? v : const [];
  }

  BackupSummary get summary => BackupSummary(
        lessons: _list('completed_ciphers').length,
        favorites: _list('favorite_ciphers').length,
        quizzes: _list('quiz_results').length,
        translations: _list('translation_history').length,
        name: (values['user_name'] as String?) ?? '',
      );
}

class BackupParseResult {
  const BackupParseResult.success(BackupData this.data) : error = null;
  const BackupParseResult.failure(String this.error) : data = null;

  final BackupData? data;
  final String? error;
}

/// Membuat kode cadangan dari data lokal.
/// Catatan: kode ini bukan enkripsi. Isinya (nama, riwayat) bisa dibaca
/// oleh siapa pun yang memegang kodenya.
String createBackupCode(SharedPreferences prefs, {DateTime? now}) {
  final values = <String, Object>{};
  for (final key in backupListKeys) {
    final v = prefs.getStringList(key);
    if (v != null) values[key] = v;
  }
  for (final key in backupStringKeys) {
    final v = prefs.getString(key);
    if (v != null) values[key] = v;
  }
  final json = jsonEncode({
    'v': _version,
    't': (now ?? DateTime.now()).toIso8601String(),
    'd': values,
  });
  final body = base64Url.encode(gzip.encode(utf8.encode(json)));
  return '$_prefix${body.replaceAll('=', '')}';
}

/// Membaca dan memeriksa kode cadangan tanpa mengubah data apa pun.
BackupParseResult parseBackupCode(String code) {
  // Pesan WhatsApp bisa menyisipkan spasi atau baris baru.
  final text = code.replaceAll(RegExp(r'\s+'), '');
  if (text.isEmpty) {
    return const BackupParseResult.failure('Kode cadangan masih kosong.');
  }
  if (text.length > _maxCodeLength) {
    return const BackupParseResult.failure('Kode cadangan terlalu panjang.');
  }
  if (!text.startsWith(_prefix)) {
    return const BackupParseResult.failure(
        'Ini bukan kode cadangan Sandi Pramuka (harus diawali SPB1-).');
  }

  try {
    final body = text.substring(_prefix.length);
    final bytes = gzip.decode(base64Url.decode(base64Url.normalize(body)));
    final json = jsonDecode(utf8.decode(bytes));
    if (json is! Map<String, dynamic>) return _damaged();
    if (json['v'] != _version) {
      return const BackupParseResult.failure(
          'Versi cadangan tidak dikenali. Perbarui aplikasi lalu coba lagi.');
    }
    final raw = json['d'];
    if (raw is! Map<String, dynamic>) return _damaged();

    final values = <String, Object>{};
    for (final key in backupListKeys) {
      if (!raw.containsKey(key)) continue;
      final v = raw[key];
      if (v is! List || v.any((e) => e is! String)) return _damaged();
      values[key] = List<String>.from(v);
    }
    for (final key in backupStringKeys) {
      if (!raw.containsKey(key)) continue;
      final v = raw[key];
      if (v is! String) return _damaged();
      values[key] = v;
    }
    if (values.isEmpty) {
      return const BackupParseResult.failure('Cadangan ini tidak berisi data.');
    }

    final t = json['t'];
    return BackupParseResult.success(
      BackupData(
        createdAt: t is String ? DateTime.tryParse(t) : null,
        values: values,
      ),
    );
  } catch (_) {
    return _damaged();
  }
}

BackupParseResult _damaged() => const BackupParseResult.failure(
    'Kode cadangan rusak atau terpotong. Salin ulang kode secara utuh.');

/// Mengganti data lokal dengan isi cadangan.
/// Kunci yang tidak ada di cadangan dihapus dari HP ini.
Future<void> applyBackup(SharedPreferences prefs, BackupData data) async {
  for (final key in backupListKeys) {
    final v = data.values[key];
    if (v is List<String>) {
      await prefs.setStringList(key, v);
    } else {
      await prefs.remove(key);
    }
  }
  for (final key in backupStringKeys) {
    final v = data.values[key];
    if (v is String) {
      await prefs.setString(key, v);
    } else {
      await prefs.remove(key);
    }
  }
}
