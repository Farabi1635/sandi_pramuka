import 'dart:convert';

import '../../services/ciphers/cipher.dart';
import '../../services/translation_service.dart';

enum ChallengeLevel { mudah, sedang, sulit }

String challengeLevelLabel(ChallengeLevel l) => switch (l) {
      ChallengeLevel.mudah => 'Mudah',
      ChallengeLevel.sedang => 'Sedang',
      ChallengeLevel.sulit => 'Sulit',
    };

/// Jumlah percobaan menurut tingkat kesulitan.
int maxAttempts(ChallengeLevel level) => switch (level) {
      ChallengeLevel.mudah => 3,
      ChallengeLevel.sedang => 2,
      ChallengeLevel.sulit => 1,
    };

/// Nilai berdasarkan percobaan ke-[attempt] (mulai dari 1) yang benar.
int challengeScore(ChallengeLevel level, int attempt) {
  if (attempt < 1 || attempt > maxAttempts(level)) return 0;
  const table = {
    ChallengeLevel.mudah: [100, 70, 40],
    ChallengeLevel.sedang: [100, 60],
    ChallengeLevel.sulit: [100],
  };
  return table[level]![attempt - 1];
}

/// Tingkat Sulit menyembunyikan nama sandi.
bool showsCipherName(ChallengeLevel level) => level != ChallengeLevel.sulit;

class Challenge {
  const Challenge({
    required this.cipherId,
    required this.variantId,
    required this.shift,
    required this.level,
    required this.coded,
  });

  final String cipherId;
  final String? variantId;
  final int shift;
  final ChallengeLevel level;

  /// Pesan yang sudah disandikan.
  final String coded;

  CipherOptions get options =>
      CipherOptions(variantId: variantId, shift: shift);

  Cipher? get cipher => cipherById(cipherId);

  /// Jawaban yang benar, dihitung dari mesin sandi.
  String get expectedAnswer =>
      cipher?.decode(coded, options).output ?? '';
}

class ChallengeBuildResult {
  const ChallengeBuildResult.success(Challenge this.challenge, {this.note})
      : error = null;
  const ChallengeBuildResult.failure(String this.error)
      : challenge = null,
        note = null;

  final Challenge? challenge;
  final String? error;
  final String? note;
}

/// Membuat tantangan dari pesan biasa.
ChallengeBuildResult buildChallenge({
  required Cipher cipher,
  required CipherOptions options,
  required String message,
  required ChallengeLevel level,
}) {
  final res = cipher.encode(message, options);
  if (!res.ok) return ChallengeBuildResult.failure(res.error ?? 'Gagal.');
  return ChallengeBuildResult.success(
    Challenge(
      cipherId: cipher.id,
      variantId: options.variantId,
      shift: options.shift,
      level: level,
      coded: res.output,
    ),
    note: res.note,
  );
}

const String _prefix = 'SP1-';

/// Kode tantangan yang bisa disalin dan dibagikan.
/// Catatan: bukan enkripsi, hanya pembungkus agar mudah dikirim.
String encodeChallenge(Challenge c) {
  final json = jsonEncode({
    'c': c.cipherId,
    'v': c.variantId,
    's': c.shift,
    'l': c.level.name,
    'm': c.coded,
  });
  final body = base64Url.encode(utf8.encode(json)).replaceAll('=', '');
  return '$_prefix$body';
}

/// Membaca kode tantangan. Mengembalikan null jika tidak valid.
Challenge? decodeChallenge(String code) {
  final text = code.trim();
  if (!text.startsWith(_prefix)) return null;
  try {
    final body = text.substring(_prefix.length);
    final json = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(body))));
    if (json is! Map<String, dynamic>) return null;

    final cipherId = json['c'];
    final variantId = json['v'];
    final shift = json['s'];
    final level = json['l'];
    final coded = json['m'];
    if (cipherId is! String ||
        (variantId != null && variantId is! String) ||
        shift is! int ||
        level is! String ||
        coded is! String ||
        coded.trim().isEmpty) {
      return null;
    }

    final cipher = cipherById(cipherId);
    if (cipher == null) return null;
    final lv = ChallengeLevel.values.where((e) => e.name == level);
    if (lv.isEmpty) return null;

    final challenge = Challenge(
      cipherId: cipherId,
      variantId: variantId as String?,
      shift: shift,
      level: lv.first,
      coded: coded,
    );
    // Pastikan pesan benar-benar bisa dibaca dengan sandi tersebut.
    if (!cipher.decode(coded, challenge.options).ok) return null;
    return challenge;
  } catch (_) {
    return null;
  }
}

String normalizeAnswer(String s) =>
    s.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');

bool isCorrectAnswer(Challenge c, String answer) =>
    normalizeAnswer(answer) == normalizeAnswer(c.expectedAnswer);
