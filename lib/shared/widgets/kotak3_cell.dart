import 'package:flutter/material.dart';

import '../../services/ciphers/kotak3_cipher.dart';

const Map<String, Offset> _directions = {
  'U': Offset(0, -1),
  'D': Offset(0, 1),
  'L': Offset(-1, 0),
  'R': Offset(1, 0),
  'UL': Offset(-0.809, -0.588),
  'UR': Offset(0.809, -0.588),
  'DL': Offset(-0.809, 0.588),
  'DR': Offset(0.809, 0.588),
};

/// Simbol Sandi Kotak 3 satu huruf. [code] contoh: K1, K6.
class Kotak3Cell extends StatelessWidget {
  const Kotak3Cell({super.key, required this.letter, required this.code});

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
              painter: Kotak3Painter(code, t.colorScheme.onSurface),
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

class Kotak3Painter extends CustomPainter {
  Kotak3Painter(this.code, this.ink);

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
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = ink;

    final dotted = code.endsWith('.');
    final shape = int.tryParse(code.substring(1).replaceAll('.', '')) ?? 1;

    if (shape == 1) {
      canvas.drawRect(const Rect.fromLTRB(8, 11, 32, 29), line);
      if (dotted) canvas.drawCircle(const Offset(20, 20), 2.6, fill);
      return;
    }

    final rays = (kotak3ShapeRays[shape] ?? const <String>[])
        .map((r) => _directions[r]!)
        .toList();
    if (rays.isEmpty) return;

    const length = 15.0;
    const pivot = Offset(20, 20);
    final tips = [for (final d in rays) pivot + d * length];
    final points = [pivot, ...tips];
    var minX = points.first.dx, maxX = points.first.dx;
    var minY = points.first.dy, maxY = points.first.dy;
    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    final shift = Offset(20 - (minX + maxX) / 2, 20 - (minY + maxY) / 2);

    for (final tip in tips) {
      canvas.drawLine(pivot + shift, tip + shift, line);
    }
    if (dotted) {
      final bis = rays.first + rays.last;
      final unit = bis / bis.distance;
      canvas.drawCircle(pivot + shift + unit * 8, 2.4, fill);
    }
  }

  @override
  bool shouldRepaint(covariant Kotak3Painter old) =>
      old.code != code || old.ink != ink;
}

class _Label {
  const _Label(this.text, this.x, this.y, {this.dotX, this.dotY});
  final String text;
  final double x;
  final double y;
  final double? dotX;
  final double? dotY;
}

/// Gambar kunci Sandi Kotak 3: tanda pagar di tengah ditumpuk belah ketupat,
/// lengkap dengan huruf dan titik di tiap ruang.
class Kotak3Diagram extends StatelessWidget {
  const Kotak3Diagram({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 640 / 437,
      child: CustomPaint(
        painter: _DiagramPainter(Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _DiagramPainter extends CustomPainter {
  _DiagramPainter(this.ink);

  final Color ink;

  // Koordinat pada gambar kunci (titik pojok kiri atas bidang = 130, 48).
  static const List<_Label> _labels = [
    _Label('F', 430, 75),
    _Label('D', 300, 113, dotX: 302, dotY: 85),
    _Label('C', 255, 135),
    _Label('E', 340, 145),
    _Label('Z', 222, 178, dotX: 193, dotY: 178),
    _Label('Y', 262, 203),
    _Label('H', 575, 113, dotX: 573, dotY: 85),
    _Label('G', 535, 145),
    _Label('I', 612, 135),
    _Label('J', 655, 178, dotX: 687, dotY: 180),
    _Label('K', 620, 203),
    _Label('X', 165, 270),
    _Label('L', 733, 268),
    _Label('A', 418, 265),
    _Label('B', 458, 265, dotX: 458, dotY: 238),
    _Label('W', 255, 330),
    _Label('V', 212, 358, dotX: 188, dotY: 358),
    _Label('U', 260, 398),
    _Label('T', 298, 420, dotX: 298, dotY: 447),
    _Label('S', 335, 395),
    _Label('M', 622, 335),
    _Label('N', 670, 358, dotX: 697, dotY: 358),
    _Label('O', 620, 398),
    _Label('P', 578, 420, dotX: 578, dotY: 447),
    _Label('Q', 538, 395),
    _Label('R', 430, 462),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 640, size.width / 640);
    canvas.translate(-130, -48);

    final line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    // Tanda pagar: dua garis tegak dan dua garis datar.
    canvas.drawLine(const Offset(280, 48), const Offset(280, 485), line);
    canvas.drawLine(const Offset(600, 48), const Offset(600, 485), line);
    canvas.drawLine(const Offset(130, 157), const Offset(770, 157), line);
    canvas.drawLine(const Offset(130, 378), const Offset(770, 378), line);

    // Belah ketupat: atas F, kanan L, bawah R, kiri X.
    final diamond = Path()
      ..moveTo(430, 48)
      ..lineTo(770, 268)
      ..lineTo(430, 485)
      ..lineTo(130, 268)
      ..close();
    canvas.drawPath(diamond, line);

    final fill = Paint()..color = ink;
    for (final l in _labels) {
      final tp = TextPainter(
        text: TextSpan(
          text: l.text,
          style: TextStyle(
            color: ink,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(l.x - tp.width / 2, l.y - tp.height / 2));
      if (l.dotX != null && l.dotY != null) {
        canvas.drawCircle(Offset(l.dotX!, l.dotY!), 6, fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DiagramPainter old) => old.ink != ink;
}
