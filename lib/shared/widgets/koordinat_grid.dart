import 'package:flutter/material.dart';

import '../../services/ciphers/koordinat_cipher.dart';

/// Tabel Sandi Koordinat: nama kolom di atas, nama baris di kiri.
class KoordinatGrid extends StatelessWidget {
  const KoordinatGrid({
    super.key,
    this.columns = 'MERAH',
    this.rows = 'PUTIH',
  });

  final String columns;
  final String rows;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final headerColor = t.colorScheme.primary;

    Widget cell(String s, {bool header = false}) => Container(
          height: 40,
          color: header ? headerColor : null,
          alignment: Alignment.center,
          child: Text(
            s,
            style: header
                ? t.textTheme.titleSmall?.copyWith(
                    color: t.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  )
                : t.textTheme.titleMedium,
          ),
        );

    return Table(
      border: TableBorder.all(color: t.colorScheme.outlineVariant),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            cell('', header: true),
            for (final ch in columns.split('')) cell(ch, header: true),
          ],
        ),
        for (var r = 0; r < 5; r++)
          TableRow(
            children: [
              cell(rows[r], header: true),
              for (var c = 0; c < 5; c++) cell(koordinatGrid[r * 5 + c]),
            ],
          ),
      ],
    );
  }
}
