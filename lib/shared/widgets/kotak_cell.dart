import 'package:flutter/material.dart';

import '../../services/ciphers/kotak_cipher.dart';

/// Simbol Sandi Kotak satu huruf. [code] contoh: K1, K1., X2.
class KotakCell extends StatelessWidget {
  const KotakCell({super.key, required this.letter, required this.code});

  final String letter;
  final String code;

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
            width: 44,
            height: 44,
            child: CustomPaint(
              painter: KotakPainter(code, t.colorScheme.onSurface),
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

class KotakPainter extends CustomPainter {
  KotakPainter(this.code, this.ink);

  final String code;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40;
    canvas.scale(s, s);

    final line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final n = int.tryParse(code.length > 1 ? code[1] : '') ?? 1;
    final dots = '.'.allMatches(code).length;

    if (code.startsWith('X')) {
      final path = Path();
      switch (n) {
        case 1: // atas
          path
            ..moveTo(6, 10)
            ..lineTo(20, 30)
            ..lineTo(34, 10);
        case 2: // kiri
          path
            ..moveTo(10, 6)
            ..lineTo(30, 20)
            ..lineTo(10, 34);
        case 3: // kanan
          path
            ..moveTo(30, 6)
            ..lineTo(10, 20)
            ..lineTo(30, 34);
        default: // bawah
          path
            ..moveTo(6, 30)
            ..lineTo(20, 10)
            ..lineTo(34, 30);
      }
      canvas.drawPath(path, line);
    } else {
      final sides = kotakCellSides(n);
      if (sides.contains('top')) {
        canvas.drawLine(const Offset(8, 8), const Offset(32, 8), line);
      }
      if (sides.contains('bottom')) {
        canvas.drawLine(const Offset(8, 32), const Offset(32, 32), line);
      }
      if (sides.contains('left')) {
        canvas.drawLine(const Offset(8, 8), const Offset(8, 32), line);
      }
      if (sides.contains('right')) {
        canvas.drawLine(const Offset(32, 8), const Offset(32, 32), line);
      }
    }

    final fill = Paint()..color = ink;
    if (dots == 1) {
      canvas.drawCircle(const Offset(20, 20), 2.6, fill);
    } else if (dots >= 2) {
      canvas.drawCircle(const Offset(15, 20), 2.6, fill);
      canvas.drawCircle(const Offset(25, 20), 2.6, fill);
    }
  }

  @override
  bool shouldRepaint(covariant KotakPainter old) =>
      old.code != code || old.ink != ink;
}

/// Gambar tanda pagar (#) bernomor beserta huruf di tiap ruangnya.
class KotakGuide extends StatelessWidget {
  const KotakGuide({super.key, required this.kind});

  /// 1 = Sandi Kotak 1 (ada tanda silang), 2 = Sandi Kotak 2.
  final int kind;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cells = kind == 1 ? kotak1Cells : kotak2Cells;
    final side = BorderSide(color: t.colorScheme.onSurface, width: 2.5);

    Widget cell(int n) {
      final sides = kotakCellSides(n);
      return Container(
        height: 64,
        decoration: BoxDecoration(
          border: Border(
            top: sides.contains('top') ? side : BorderSide.none,
            bottom: sides.contains('bottom') ? side : BorderSide.none,
            left: sides.contains('left') ? side : BorderSide.none,
            right: sides.contains('right') ? side : BorderSide.none,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 6,
              top: 4,
              child: Text('$n', style: t.textTheme.labelSmall),
            ),
            Center(
              child: Text(
                cells[n - 1],
                style: t.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          children: [
            for (var r = 0; r < 3; r++)
              TableRow(children: [for (var c = 0; c < 3; c++) cell(r * 3 + c + 1)]),
          ],
        ),
        if (kind == 1) ...[
          const SizedBox(height: 12),
          Text('Tanda silang (X):', style: t.textTheme.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (var i = 0; i < kotak1Wedges.length; i++)
                Chip(
                  label: Text(
                    'X${i + 1} ${const ['atas', 'kiri', 'kanan', 'bawah'][i]}: ${kotak1Wedges[i]}',
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
