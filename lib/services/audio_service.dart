import 'dart:math';
import 'dart:typed_data';

/// Satu potongan waktu Morse: bunyi (on) atau jeda (off), dalam milidetik.
class MorseSegment {
  const MorseSegment(this.on, this.ms);
  final bool on;
  final int ms;
}

/// Mengubah kode Morse (huruf dipisah spasi, kata dipisah "/") menjadi
/// urutan bunyi dan jeda sesuai aturan waktu standar:
/// titik = 1 unit, garis = 3, jeda simbol = 1, jeda huruf = 3, jeda kata = 7.
/// 1 unit = 1200 / wpm milidetik.
List<MorseSegment> buildMorseTimeline(String morse, {int wpm = 12}) {
  final unit = (1200 / wpm.clamp(5, 40)).round();
  final segments = <MorseSegment>[];
  var firstWord = true;
  for (final word in morse.trim().split('/')) {
    final letters =
        word.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (letters.isEmpty) continue;
    if (!firstWord) segments.add(MorseSegment(false, unit * 7));
    firstWord = false;
    for (var li = 0; li < letters.length; li++) {
      if (li > 0) segments.add(MorseSegment(false, unit * 3));
      final code = letters[li];
      for (var si = 0; si < code.length; si++) {
        if (si > 0) segments.add(MorseSegment(false, unit));
        final ch = code[si];
        if (ch == '.') {
          segments.add(MorseSegment(true, unit));
        } else if (ch == '-') {
          segments.add(MorseSegment(true, unit * 3));
        }
      }
    }
  }
  return segments;
}

int totalDurationMs(List<MorseSegment> segments) =>
    segments.fold(0, (sum, s) => sum + s.ms);

/// Apakah pada waktu [ms] sedang ada bunyi.
bool isOnAt(List<MorseSegment> segments, int ms) {
  var t = 0;
  for (final s in segments) {
    if (ms < t + s.ms) return s.on;
    t += s.ms;
  }
  return false;
}

/// Membuat berkas WAV (16-bit mono) berisi nada sinus sesuai [segments].
Uint8List buildWav(
  List<MorseSegment> segments, {
  int frequency = 600,
  int sampleRate = 22050,
}) {
  final counts = [
    for (final s in segments) (s.ms * sampleRate / 1000).round(),
  ];
  final totalSamples = counts.fold(0, (a, b) => a + b);
  final data = ByteData(44 + totalSamples * 2);

  void writeText(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      data.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  writeText(0, 'RIFF');
  data.setUint32(4, 36 + totalSamples * 2, Endian.little);
  writeText(8, 'WAVE');
  writeText(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  writeText(36, 'data');
  data.setUint32(40, totalSamples * 2, Endian.little);

  final fade = max(1, (sampleRate * 0.005).round());
  var pos = 44;
  for (var k = 0; k < segments.length; k++) {
    final n = counts[k];
    final on = segments[k].on;
    for (var i = 0; i < n; i++) {
      var value = 0;
      if (on) {
        final edge = min(i, n - 1 - i);
        final env = edge >= fade ? 1.0 : edge / fade;
        value = (0.6 * sin(2 * pi * frequency * i / sampleRate) * env * 32767)
            .round();
      }
      data.setInt16(pos, value, Endian.little);
      pos += 2;
    }
  }
  return data.buffer.asUint8List();
}
