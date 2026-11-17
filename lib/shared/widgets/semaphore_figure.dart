import 'package:flutter/material.dart';

import '../../features/semaphore/semaphore_math.dart';

/// Orang dengan dua lengan dan bendera pada sudut tertentu (derajat).
/// Dipakai untuk animasi; sudut diukur seperti pada [semaphoreAngle].
class SemaphoreFigure extends StatelessWidget {
  const SemaphoreFigure({
    super.key,
    required this.left,
    required this.right,
    this.height = 260,
  });

  final double left;
  final double right;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 64 / 72,
      height: height,
      child: CustomPaint(
        painter: SemaphoreFigurePainter(
          left,
          right,
          Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class SemaphoreFigurePainter extends CustomPainter {
  SemaphoreFigurePainter(this.a, this.b, this.ink);

  final double a;
  final double b;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64;
    canvas.scale(s, s);
    const shoulder = Offset(32, 30);
    const armLength = 20.0;

    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (final angle in [a, b]) {
      final dir = armDirection(angle);
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
  bool shouldRepaint(covariant SemaphoreFigurePainter old) =>
      old.a != a || old.b != b || old.ink != ink;
}
