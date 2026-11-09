import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Di-override di main.dart dengan instance SharedPreferences.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider belum di-override'),
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final saved = ref.read(sharedPrefsProvider).getString(_key);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPrefsProvider).setString(_key, mode.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class TextScaleNotifier extends Notifier<double> {
  static const _key = 'text_scale';

  @override
  double build() =>
      (ref.read(sharedPrefsProvider).getDouble(_key) ?? 1.0).clamp(0.8, 1.4);

  Future<void> set(double value) async {
    state = value;
    await ref.read(sharedPrefsProvider).setDouble(_key, value);
  }
}

final textScaleProvider =
    NotifierProvider<TextScaleNotifier, double>(TextScaleNotifier.new);
