import 'package:flutter/material.dart';

import '../../services/ciphers/sungai_cipher.dart';

/// Kotak Sungai: 5 baris x 8 kolom dengan huruf mengelilingi kotak.
class SungaiGrid extends StatelessWidget {
  const SungaiGrid({super.key});

  Widget _label(BuildContext context, String s) => SizedBox(
        height: 28,
        child: Center(
          child: Text(s,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).colorScheme.outline;

    TableRow labelRow(String letters) => TableRow(
          children: [
            const SizedBox(),
            for (final ch in letters.split('')) _label(context, ch),
            const SizedBox(),
          ],
        );

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(26),
        9: FixedColumnWidth(26),
      },
      defaultColumnWidth: const FlexColumnWidth(1),
      children: [
        labelRow(sungaiTop),
        for (var r = 0; r < 5; r++)
          TableRow(
            children: [
              _label(context, sungaiLeft[r]),
              for (var c = 0; c < 8; c++)
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: line, width: 0.8),
                  ),
                ),
              _label(context, sungaiRight[r]),
            ],
          ),
        labelRow(sungaiBottom),
      ],
    );
  }
}
