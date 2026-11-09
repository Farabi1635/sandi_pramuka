import 'package:flutter/material.dart';

import '../../core/constants/cipher_catalog_seed.dart';
import '../../core/theme/app_colors.dart';

Color categoryColor(String categoryId) => switch (categoryId) {
      'komunikasi' => AppColors.green,
      'bentuk' => AppColors.army,
      'pola' => AppColors.brown,
      'huruf' => AppColors.greenDark,
      'angka' => const Color(0xFF3F6B4F),
      _ => const Color(0xFF9A7B52),
    };

IconData categoryIcon(String categoryId) => switch (categoryId) {
      'komunikasi' => Icons.cell_tower,
      'bentuk' => Icons.grid_view,
      'pola' => Icons.grass,
      'huruf' => Icons.sort_by_alpha,
      'angka' => Icons.pin,
      _ => Icons.auto_awesome,
    };

/// Logo kategori (kotak berwarna + ikon).
class CategoryLogo extends StatelessWidget {
  const CategoryLogo({super.key, required this.categoryId, this.size = 40});
  final String categoryId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: categoryColor(categoryId),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(categoryIcon(categoryId),
          color: Colors.white, size: size * 0.58),
    );
  }
}

const Map<String, IconData> _iconCiphers = {
  'gambar': Icons.image_outlined,
  'an': Icons.sync_alt,
  'az': Icons.swap_vert,
  'balik': Icons.flip,
  'geser': Icons.keyboard_double_arrow_right,
  'angka': Icons.pin_outlined,
  'koordinat': Icons.grid_on,
  'kotak_koordinat': Icons.my_location,
  'kimia': Icons.science_outlined,
};

/// Logo bergambar untuk setiap sandi.
class CipherLogo extends StatelessWidget {
  const CipherLogo({super.key, required this.cipherId, this.size = 48});
  final String cipherId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cat = findCategoryOf(cipherId);
    final color = categoryColor(cat?.id ?? '');
    final icon = _iconCiphers[cipherId];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: icon != null
          ? Icon(icon, color: Colors.white, size: size * 0.6)
          : Padding(
              padding: EdgeInsets.all(size * 0.14),
              child: CustomPaint(painter: _GlyphPainter(cipherId)),
            ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.id);
  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final fill = Paint()..color = Colors.white;
    final line = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void dash(double x1, double x2, double y) => canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(x1, y - 7, x2, y + 7), const Radius.circular(7)),
        fill);

    switch (id) {
      case 'morse':
        dash(6, 46, 30);
        canvas.drawCircle(const Offset(66, 30), 8, fill);
        canvas.drawCircle(const Offset(88, 30), 8, fill);
        canvas.drawCircle(const Offset(14, 70), 8, fill);
        dash(34, 74, 70);
        canvas.drawCircle(const Offset(92, 70), 6, fill);
      case 'semaphore':
        canvas.drawCircle(const Offset(50, 28), 9, fill);
        canvas.drawLine(const Offset(50, 38), const Offset(50, 70), line);
        canvas.drawLine(const Offset(50, 70), const Offset(38, 94), line);
        canvas.drawLine(const Offset(50, 70), const Offset(62, 94), line);
        canvas.drawLine(const Offset(50, 46), const Offset(22, 20), line);
        canvas.drawLine(const Offset(50, 46), const Offset(78, 64), line);
        canvas.drawRect(const Rect.fromLTWH(8, 4, 18, 14), fill);
        canvas.drawRect(const Rect.fromLTWH(74, 64, 18, 14), fill);
      case 'kotak1':
      case 'kotak2':
      case 'kotak3':
        final thin = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(36, 8), const Offset(36, 92), thin);
        canvas.drawLine(const Offset(64, 8), const Offset(64, 92), thin);
        canvas.drawLine(const Offset(8, 36), const Offset(92, 36), thin);
        canvas.drawLine(const Offset(8, 64), const Offset(92, 64), thin);
        if (id != 'kotak1') {
          canvas.drawCircle(const Offset(22, 22), 6, fill);
          canvas.drawCircle(const Offset(78, 78), 6, fill);
        }
        if (id == 'kotak3') {
          canvas.drawCircle(const Offset(78, 22), 6, fill);
          canvas.drawCircle(const Offset(22, 78), 6, fill);
        }
      case 'braille':
        const xs = [32.0, 68.0];
        const ys = [18.0, 50.0, 82.0];
        const on = {0: true, 3: true, 4: true};
        var i = 0;
        for (final y in ys) {
          for (final x in xs) {
            if (on[i] == true) {
              canvas.drawCircle(Offset(x, y), 10, fill);
            } else {
              canvas.drawCircle(Offset(x, y), 8, line..strokeWidth = 4);
            }
            i++;
          }
        }
      case 'rumput':
        for (final x in [20.0, 38.0, 56.0, 74.0, 90.0]) {
          final tipX = x + (x < 50 ? -8 : 8);
          final h = x == 56 ? 10.0 : 24.0;
          canvas.drawPath(
            Path()
              ..moveTo(x, 90)
              ..quadraticBezierTo(x, 50, tipX, h),
            line,
          );
        }
      case 'sungai':
        for (final y in [28.0, 52.0, 76.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(8, y)
              ..quadraticBezierTo(28, y - 16, 50, y)
              ..quadraticBezierTo(72, y + 16, 92, y),
            line,
          );
        }
      case 'jam':
        canvas.drawCircle(const Offset(50, 50), 40, line);
        canvas.drawLine(const Offset(50, 50), const Offset(50, 26), line);
        canvas.drawLine(const Offset(50, 50), const Offset(68, 60), line);
      default:
        canvas.drawCircle(const Offset(50, 50), 30, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) => old.id != id;
}
