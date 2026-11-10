import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/settings_provider.dart';
import '../../shared/widgets/app_logo.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      final done =
          ref.read(sharedPrefsProvider).getBool('onboarding_done') ?? false;
      context.go(done ? '/home' : '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutBack,
          builder: (context, v, child) => Opacity(
            opacity: v.clamp(0.0, 1.0),
            child: Transform.scale(scale: v, child: child),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(size: 140),
              SizedBox(height: 20),
              Text('SANDI PRAMUKA',
                  style: TextStyle(
                      color: AppColors.greenDark,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2)),
              SizedBox(height: 6),
              Text('Belajar Sandi, Pecahkan Rahasia',
                  style: TextStyle(color: AppColors.brown)),
            ],
          ),
        ),
      ),
    );
  }
}
