import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:sandi_pramuka/features/challenges/challenge_codec.dart';
import 'package:sandi_pramuka/services/ciphers/cipher.dart';
import 'package:sandi_pramuka/services/ciphers/letter_ciphers.dart';
import 'package:sandi_pramuka/services/ciphers/morse_cipher.dart';
import 'package:sandi_pramuka/services/translation_service.dart';

ChallengeBuildResult _build(
  String message, {
  ChallengeLevel level = ChallengeLevel.mudah,
}) =>
    buildChallenge(
      cipher: const MorseCipher(),
      options: const CipherOptions(),
      message: message,
      level: level,
    );

void main() {
  group('Membuat tantangan', () {
    test('pesan Morse menjadi tantangan', () {
      final r = _build('SOS');
      expect(r.error, isNull);
      expect(r.challenge!.coded, '... --- ...');
      expect(r.challenge!.expectedAnswer, 'SOS');
    });

    test('pesan tidak valid ditolak dengan pesan kesalahan', () {
      expect(_build('').error, isNotNull);
      expect(_build('#').error, isNotNull);
    });
  });

  group('Kode tantangan', () {
    test('bolak-balik untuk semua sandi', () {
      for (final cipher in translatableCiphers) {
        final options = CipherOptions(
          variantId: cipher.variants.isEmpty ? null : cipher.variants.first.id,
          shift: 7,
        );
        final built = buildChallenge(
          cipher: cipher,
          options: options,
          message: 'SIAGA PRAMUKA',
          level: ChallengeLevel.sedang,
        );
        expect(built.error, isNull, reason: cipher.id);
        final code = encodeChallenge(built.challenge!);
        expect(code.startsWith('SP1-'), isTrue);

        final back = decodeChallenge(code);
        expect(back, isNotNull, reason: cipher.id);
        expect(back!.cipherId, cipher.id);
        expect(back.coded, built.challenge!.coded);
        expect(back.level, ChallengeLevel.sedang);
        expect(back.expectedAnswer.toUpperCase(), 'SIAGA PRAMUKA',
            reason: cipher.id);
      }
    });

    test('kode rusak atau palsu ditolak', () {
      expect(decodeChallenge(''), isNull);
      expect(decodeChallenge('abc'), isNull);
      expect(decodeChallenge('SP1-'), isNull);
      expect(decodeChallenge('SP1-%%%'), isNull);

      final unknownCipher = base64Url
          .encode(utf8.encode(
              '{"c":"tidak-ada","v":null,"s":3,"l":"mudah","m":"X"}'))
          .replaceAll('=', '');
      expect(decodeChallenge('SP1-$unknownCipher'), isNull);

      final badMessage = base64Url
          .encode(utf8.encode(
              '{"c":"morse","v":null,"s":3,"l":"mudah","m":"abc"}'))
          .replaceAll('=', '');
      expect(decodeChallenge('SP1-$badMessage'), isNull);
    });
  });

  group('Penilaian', () {
    test('nilai menurun sesuai percobaan', () {
      expect(challengeScore(ChallengeLevel.mudah, 1), 100);
      expect(challengeScore(ChallengeLevel.mudah, 2), 70);
      expect(challengeScore(ChallengeLevel.mudah, 3), 40);
      expect(challengeScore(ChallengeLevel.mudah, 4), 0);
      expect(challengeScore(ChallengeLevel.sedang, 2), 60);
      expect(challengeScore(ChallengeLevel.sulit, 1), 100);
      expect(challengeScore(ChallengeLevel.sulit, 2), 0);
    });

    test('jawaban tidak peka huruf besar dan spasi', () {
      final c = _build('aku pramuka').challenge!;
      expect(isCorrectAnswer(c, '  AKU   pramuka '), isTrue);
      expect(isCorrectAnswer(c, 'AKU PRAMUKAA'), isFalse);
    });

    test('nama sandi disembunyikan hanya pada tingkat sulit', () {
      expect(showsCipherName(ChallengeLevel.mudah), isTrue);
      expect(showsCipherName(ChallengeLevel.sedang), isTrue);
      expect(showsCipherName(ChallengeLevel.sulit), isFalse);
    });

    test('sandi Geser memakai kunci yang sama saat dibaca', () {
      final r = buildChallenge(
        cipher: const GeserCipher(),
        options: const CipherOptions(shift: 5),
        message: 'ABC',
        level: ChallengeLevel.mudah,
      );
      expect(r.challenge!.coded, 'FGH');
      expect(r.challenge!.expectedAnswer, 'ABC');
    });
  });
}
