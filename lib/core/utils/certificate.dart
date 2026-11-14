import 'achievements.dart';

/// Syarat sertifikat penyelesaian (penghargaan internal aplikasi).
const int certificateMinQuizzes = 3;
const int certificateMinAverage = 70;

class CertificateStatus {
  const CertificateStatus({
    required this.lessonsDone,
    required this.quizzesDone,
    required this.stats,
  });

  final bool lessonsDone;
  final bool quizzesDone;
  final AchievementStats stats;

  bool get eligible => lessonsDone && quizzesDone;
}

CertificateStatus certificateStatus(AchievementStats s) => CertificateStatus(
      lessonsDone: s.totalLessons > 0 && s.completedLessons >= s.totalLessons,
      quizzesDone:
          s.quizCount >= certificateMinQuizzes &&
              s.averageScore >= certificateMinAverage,
      stats: s,
    );

const List<String> _months = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String formatIndonesianDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year}';
