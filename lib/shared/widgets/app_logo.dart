import 'package:flutter/material.dart';

/// Logo orisinal Sandi Pramuka: perisai hijau, lubang kunci (rahasia),
/// tunas daun (Pramuka) dan pola titik-garis Morse.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AppLogoPainter()),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  static const _dark = Color(0xFF183D2B);
  static const _green = Color(0xFF245B3A);
  static const _cream = Color(0xFFF5F0E3);
  static const _leaf = Color(0xFF9DBB6A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);

    final shield = Path()
      ..moveTo(10, 14)
      ..lineTo(50, 3)
      ..lineTo(90, 14)
      ..lineTo(90, 52)
      ..quadraticBezierTo(90, 80, 50, 97)
      ..quadraticBezierTo(10, 80, 10, 52)
      ..close();
    canvas.drawPath(shield, Paint()..color = _dark);
    canvas.drawPath(
      shield,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..color = _cream,
    );

    // Tunas daun
    final leafPaint = Paint()..color = _leaf;
    final leafL = Path()
      ..moveTo(50, 32)
      ..quadraticBezierTo(38, 14, 27, 22)
      ..quadraticBezierTo(33, 34, 50, 32)
      ..close();
    final leafR = Path()
      ..moveTo(50, 32)
      ..quadraticBezierTo(62, 14, 73, 22)
      ..quadraticBezierTo(67, 34, 50, 32)
      ..close();
    canvas.drawPath(leafL, leafPaint);
    canvas.drawPath(leafR, leafPaint);

    // Lubang kunci
    final cream = Paint()..color = _cream;
    canvas.drawCircle(const Offset(50, 46), 10, cream);
    final stem = Path()
      ..moveTo(45, 52)
      ..lineTo(55, 52)
      ..lineTo(59, 68)
      ..lineTo(41, 68)
      ..close();
    canvas.drawPath(stem, cream);
    canvas.drawCircle(const Offset(50, 46), 4, Paint()..color = _green);

    // Morse: titik - garis - titik
    canvas.drawCircle(const Offset(34, 79), 3.2, cream);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(41, 75.8, 18, 6.4), const Radius.circular(3.2)),
      cream,
    );
    canvas.drawCircle(const Offset(66, 79), 3.2, cream);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
