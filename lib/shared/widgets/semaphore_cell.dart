import 'dart:math';

import 'package:flutter/material.dart';

/// Gambar orang dengan dua lengan dan bendera sesuai pasangan posisi,
/// misalnya "1.2". Posisi: 1 bawah, 2 kiri bawah, 3 kiri, 4 kiri atas,
/// 5 atas, 6 kanan atas, 7 kanan, 8 kanan bawah (dilihat dari depan).
class SemaphoreCell extends StatelessWidget {
  const SemaphoreCell({super.key, required this.letter, required this.code});

  final String letter;
  final String code;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final parts = code.split('.');
    final a = int.tryParse(parts.first) ?? 1;
    final b = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 1;
    return Container(
      width: 76,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: t.colorScheme.primary.withAlpha(22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(letter,
              style: t.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SizedBox(
            width: 64,
            height: 72,
            child: CustomPaint(
              painter: SemaphorePainter(a, b, t.colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 4),
          Text(code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ],
      ),
    );
  }
}

/// Vektor arah (x ke kanan, y ke bawah) tiap nomor posisi.
Offset semaphoreDirection(int position) {
  final d = sqrt1_2;
  return switch (position) {
    1 => const Offset(0, 1),
    2 => Offset(-d, d),
    3 => const Offset(-1, 0),
    4 => Offset(-d, -d),
    5 => const Offset(0, -1),
    6 => Offset(d, -d),
    7 => const Offset(1, 0),
    _ => Offset(d, d),
  };
}

class SemaphorePainter extends CustomPainter {
  SemaphorePainter(this.a, this.b, this.ink);

  final int a;
  final int b;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64;
    canvas.scale(s, s);
    final shoulder = const Offset(32, 30);
    const armLength = 20.0;

    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Lengan dan bendera.
    for (final pos in {a, b}) {
      final dir = semaphoreDirection(pos);
      final tip = shoulder + dir * armLength;
      canvas.drawLine(shoulder, tip, stroke);
      final c = tip + dir * 4;
      const h = 5.0;
      final red = Path()
        ..moveTo(c.dx - h, c.dy - h)
        ..lineTo(c.dx + h, c.dy - h)
        ..lineTo(c.dx - h, c.dy + h)
        ..close();
      final yellow = Path()
        ..moveTo(c.dx + h, c.dy - h)
        ..lineTo(c.dx + h, c.dy + h)
        ..lineTo(c.dx - h, c.dy + h)
        ..close();
      canvas.drawPath(red, Paint()..color = const Color(0xFFD32F2F));
      canvas.drawPath(yellow, Paint()..color = const Color(0xFFFFC107));
    }

    // Badan.
    final body = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(const Offset(32, 18), 5.5, Paint()..color = ink);
    canvas.drawLine(const Offset(32, 25), const Offset(32, 46), body);
    canvas.drawLine(const Offset(32, 46), const Offset(26, 66), stroke);
    canvas.drawLine(const Offset(32, 46), const Offset(38, 66), stroke);
  }

  @override
  bool shouldRepaint(covariant SemaphorePainter old) =>
      old.a != a || old.b != b || old.ink != ink;
}
