import 'package:flutter/material.dart';

/// Gambar rumput satu huruf. [code] berisi k (puncak kecil) dan B (puncak tinggi).
class RumputCell extends StatelessWidget {
  const RumputCell({super.key, required this.letter, required this.code});

  final String letter;
  final String code;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
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
            width: 92,
            height: 38,
            child: CustomPaint(
              painter: RumputPainter(code, t.colorScheme.onSurface),
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

class RumputPainter extends CustomPainter {
  RumputPainter(this.code, this.ink);

  final String code;
  final Color ink;

  static const double _logicalWidth = 72;
  static const double _base = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / _logicalWidth;
    canvas.scale(s, s);

    final path = Path()..moveTo(0, _base);
    var x = 4.0;
    path.lineTo(x, _base);
    for (final ch in code.split('')) {
      final tall = ch == 'B';
      final w = tall ? 12.0 : 8.0;
      final h = tall ? 20.0 : 9.0;
      path
        ..lineTo(x + w / 2, _base - h)
        ..lineTo(x + w, _base);
      x += w;
    }
    path.lineTo(x + 4, _base);

    canvas.drawPath(
      path,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant RumputPainter old) =>
      old.code != code || old.ink != ink;
}
