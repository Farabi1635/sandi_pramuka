import 'package:flutter/material.dart';

import '../../shared/widgets/coming_soon_view.dart';

class TranslatorPage extends StatelessWidget {
  const TranslatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penerjemah')),
      body: const ComingSoonView(
        icon: Icons.translate,
        title: 'Penerjemah Sandi',
        message:
            'Mesin encode/decode berbasis tabel simbol dibuat di Tahap 3.',
        stage: 'Tahap 3 - Engine Penerjemah',
      ),
    );
  }
}
