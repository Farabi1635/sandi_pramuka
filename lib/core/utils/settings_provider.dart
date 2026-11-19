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

const double morseWpmMin = 5;
const double morseWpmMax = 25;
const double morseWpmDefault = 12;
const double morseFreqMin = 400;
const double morseFreqMax = 1000;
const double morseFreqDefault = 600;

/// Kecepatan Morse bawaan (kata per menit).
class MorseWpmNotifier extends Notifier<double> {
  static const _key = 'morse_wpm';

  @override
  double build() =>
      (ref.read(sharedPrefsProvider).getDouble(_key) ?? morseWpmDefault)
          .clamp(morseWpmMin, morseWpmMax);

  Future<void> set(double value) async {
    state = value.clamp(morseWpmMin, morseWpmMax);
    await ref.read(sharedPrefsProvider).setDouble(_key, state);
  }
}

final morseWpmProvider =
    NotifierProvider<MorseWpmNotifier, double>(MorseWpmNotifier.new);

/// Nada Morse bawaan (Hz).
class MorseFreqNotifier extends Notifier<double> {
  static const _key = 'morse_freq';

  @override
  double build() =>
      (ref.read(sharedPrefsProvider).getDouble(_key) ?? morseFreqDefault)
          .clamp(morseFreqMin, morseFreqMax);

  Future<void> set(double value) async {
    state = value.clamp(morseFreqMin, morseFreqMax);
    await ref.read(sharedPrefsProvider).setDouble(_key, state);
  }
}

final morseFreqProvider =
    NotifierProvider<MorseFreqNotifier, double>(MorseFreqNotifier.new);

/// Bunyi Morse hidup atau mati. Jika mati, hanya lampu yang berkedip.
class SoundEnabledNotifier extends Notifier<bool> {
  static const _key = 'sound_enabled';

  @override
  bool build() => ref.read(sharedPrefsProvider).getBool(_key) ?? true;

  Future<void> set(bool value) async {
    state = value;
    await ref.read(sharedPrefsProvider).setBool(_key, value);
  }
}

final soundEnabledProvider =
    NotifierProvider<SoundEnabledNotifier, bool>(SoundEnabledNotifier.new);
