import 'dart:math';

import '../../services/ciphers/cipher.dart';

enum QuizLevel { pemula, menengah, mahir }

String levelLabel(QuizLevel l) => switch (l) {
      QuizLevel.pemula => 'Pemula',
      QuizLevel.menengah => 'Menengah',
      QuizLevel.mahir => 'Mahir',
    };

enum QuizKind { textToCode, codeToText }

/// Bank kata hanya berisi huruf A-Z dan spasi, tanpa huruf J,
/// agar aman untuk semua sandi (termasuk Kotak Koordinat I = J).
const Map<QuizLevel, List<String>> quizWordBank = {
  QuizLevel.pemula: [
    'API', 'TALI', 'PETA', 'REGU', 'KODE', 'TENDA',
    'SIAGA', 'BAKTI', 'TUNAS', 'SANDI', 'PANDU', 'KEMAH',
  ],
  QuizLevel.menengah: [
    'PRAMUKA', 'PANDEGA', 'PENEGAK', 'BENDERA', 'KOMPAS', 'TONGKAT',
    'LAMBANG', 'PELANTIK', 'PERKEMAHAN', 'PENGGALANG', 'KEPRAMUKAAN',
    'SEMAPHORE',
  ],
  QuizLevel.mahir: [
    'SIAGA SATU', 'AYO BERKEMAH', 'SATYA DHARMA', 'SALAM PRAMUKA',
    'TUNAS KELAPA', 'BERBUAT BAIK', 'CINTA ALAM', 'SELALU SIAGA',
    'GOTONG ROYONG', 'PANTANG MENYERAH', 'HIDUP SEDERHANA',
    'SALING MENOLONG',
  ],
};

/// Kata pendek untuk latihan mendengarkan Morse.
List<String> get practiceWords => quizWordBank[QuizLevel.pemula]!;

class QuizQuestion {
  const QuizQuestion({
    required this.kind,
    required this.prompt,
    required this.shown,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final QuizKind kind;
  final String prompt;
  final String shown;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

/// Membuat soal pilihan ganda langsung dari mesin penerjemah,
/// sehingga kunci jawaban selalu sesuai aturan sandi.
List<QuizQuestion> generateQuiz({
  required Cipher cipher,
  required CipherOptions options,
  required QuizLevel level,
  int count = 5,
  Random? random,
}) {
  final rnd = random ?? Random();
  final bank = [...quizWordBank[level]!]..shuffle(rnd);
  final total = min(count, bank.length);
  final questions = <QuizQuestion>[];

  for (var i = 0; i < total; i++) {
    final word = bank[i];
    final kind = rnd.nextBool() ? QuizKind.textToCode : QuizKind.codeToText;
    final code = cipher.encode(word, options).output;
    final correct = kind == QuizKind.textToCode ? code : word;

    final others = bank.where((w) => w != word).toList()..shuffle(rnd);
    final distractors = <String>[];
    for (final w in others) {
      final candidate =
          kind == QuizKind.textToCode ? cipher.encode(w, options).output : w;
      if (candidate != correct && !distractors.contains(candidate)) {
        distractors.add(candidate);
      }
      if (distractors.length == 3) break;
    }

    final choices = [correct, ...distractors]..shuffle(rnd);
    questions.add(
      QuizQuestion(
        kind: kind,
        prompt: kind == QuizKind.textToCode
            ? 'Sandikan teks ini:'
            : 'Apa arti sandi ini?',
        shown: kind == QuizKind.textToCode ? word : code,
        options: choices,
        correctIndex: choices.indexOf(correct),
        explanation: kind == QuizKind.textToCode
            ? '"$word" disandikan menjadi: $code'
            : 'Kode $code dibaca: $word',
      ),
    );
  }
  return questions;
}
