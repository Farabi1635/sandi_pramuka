import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_logo.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: AppLogo(size: 88)),
          const SizedBox(height: 12),
          const Center(child: Text('Mode Tamu')),
          const SizedBox(height: 4),
          const Center(
            child: Text('Login dan sinkronisasi tersedia di Tahap 6.',
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings'),
            ),
          ),
        ],
      ),
    );
  }
}
