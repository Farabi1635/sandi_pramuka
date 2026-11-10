import 'package:flutter/material.dart';

/// Gambar satu sel Braille (2 kolom x 3 baris) beserta hurufnya.
class BrailleCell extends StatelessWidget {
  const BrailleCell({super.key, required this.letter, required this.dots});

  final String letter;

  /// Nomor titik yang timbul, misalnya "145".
  final String dots;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: 64,
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
            width: 28,
            height: 42,
            child: CustomPaint(
              painter: _CellPainter(
                dots: dots,
                filled: t.colorScheme.onSurface,
                empty: t.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(dots, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _CellPainter extends CustomPainter {
  _CellPainter({required this.dots, required this.filled, required this.empty});

  final String dots;
  final Color filled;
  final Color empty;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width * 0.17;
    for (var n = 1; n <= 6; n++) {
      final col = n <= 3 ? 0 : 1;
      final row = (n - 1) % 3;
      final center = Offset(
        size.width * (col == 0 ? 0.27 : 0.73),
        size.height * (0.17 + row * 0.33),
      );
      if (dots.contains('$n')) {
        canvas.drawCircle(center, r, Paint()..color = filled);
      } else {
        canvas.drawCircle(
          center,
          r * 0.8,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = empty,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CellPainter old) =>
      old.dots != dots || old.filled != filled || old.empty != empty;
}
