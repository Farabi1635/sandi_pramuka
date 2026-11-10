import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:sandi_pramuka/features/exercises/quiz_engine.dart';
import 'package:sandi_pramuka/services/audio_service.dart';
import 'package:sandi_pramuka/services/ciphers/cipher.dart';
import 'package:sandi_pramuka/services/translation_service.dart';

void main() {
  group('Timeline dan audio Morse', () {
    test('SOS pada 12 WPM berdurasi 2700 ms', () {
      final segs = buildMorseTimeline('... --- ...', wpm: 12);
      expect(totalDurationMs(segs), 2700);
      expect(segs.first.on, isTrue);
      expect(segs.first.ms, 100);
    });

    test('isOnAt mengikuti titik dan jeda', () {
      final segs = buildMorseTimeline('..', wpm: 12);
      expect(isOnAt(segs, 50), isTrue);
      expect(isOnAt(segs, 150), isFalse);
      expect(isOnAt(segs, 250), isTrue);
    });

    test('jeda kata 7 unit', () {
      final segs = buildMorseTimeline('. / .', wpm: 12);
      expect(totalDurationMs(segs), 100 + 700 + 100);
    });

    test('teks kosong menghasilkan timeline kosong', () {
      expect(buildMorseTimeline('', wpm: 12), isEmpty);
    });

    test('WAV punya header dan ukuran benar', () {
      final segs = buildMorseTimeline('... --- ...', wpm: 12);
      final wav = buildWav(segs);
      expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
      expect(wav.length, 44 + 2 * 59535);
    });
  });

  group('Mesin kuis', () {
    test('soal valid untuk semua sandi dan level', () {
      for (final cipher in translatableCiphers) {
        final options = CipherOptions(
          variantId: cipher.variants.isEmpty ? null : cipher.variants.first.id,
          shift: 3,
        );
        for (final level in QuizLevel.values) {
          final qs = generateQuiz(
            cipher: cipher,
            options: options,
            level: level,
            count: 10,
            random: Random(1),
          );
          expect(qs.length, 10, reason: '${cipher.id} ${level.name}');
          for (final q in qs) {
            expect(q.options.length, 4);
            expect(q.options.toSet().length, 4);
            expect(q.correctIndex, inInclusiveRange(0, 3));
            final answer = q.options[q.correctIndex];
            if (q.kind == QuizKind.textToCode) {
              expect(cipher.encode(q.shown, options).output, answer);
            } else {
              expect(cipher.decode(q.shown, options).output, answer);
            }
          }
        }
      }
    });

    test('jumlah soal dibatasi ukuran bank kata', () {
      final qs = generateQuiz(
        cipher: translatableCiphers.first,
        options: const CipherOptions(),
        level: QuizLevel.pemula,
        count: 50,
        random: Random(2),
      );
      expect(qs.length, quizWordBank[QuizLevel.pemula]!.length);
    });
  });
}
