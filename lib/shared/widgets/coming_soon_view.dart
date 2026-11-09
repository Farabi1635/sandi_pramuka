import 'package:flutter/material.dart';

/// Penanda jujur untuk fitur yang dikerjakan di tahap berikutnya.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.stage,
    this.leading,
  });

  /// Jika diisi, ditampilkan menggantikan ikon.
  final Widget? leading;

  final IconData icon;
  final String title;
  final String message;
  final String stage;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading ?? Icon(icon, size: 72, color: t.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title,
                style: t.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Chip(label: Text(stage)),
          ],
        ),
      ),
    );
  }
}
