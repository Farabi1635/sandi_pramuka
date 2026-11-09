import 'package:flutter/material.dart';

import '../../shared/widgets/coming_soon_view.dart';

class ExercisesPage extends StatelessWidget {
  const ExercisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Latihan')),
      body: const ComingSoonView(
        icon: Icons.extension,
        title: 'Latihan dan Kuis',
        message: 'Latihan, kuis, timer, dan penilaian dibuat di Tahap 4.',
        stage: 'Tahap 4 - Interaktivitas',
      ),
    );
  }
}
