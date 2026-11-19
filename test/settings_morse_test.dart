import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sandi_pramuka/core/utils/settings_provider.dart';

Future<ProviderContainer> _container() async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
}

void main() {
  test('nilai bawaan', () async {
    SharedPreferences.setMockInitialValues({});
    final c = await _container();
    expect(c.read(morseWpmProvider), morseWpmDefault);
    expect(c.read(morseFreqProvider), morseFreqDefault);
    expect(c.read(soundEnabledProvider), isTrue);
    c.dispose();
  });

  test('tersimpan dan terbaca ulang', () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = await _container();
    await c1.read(morseWpmProvider.notifier).set(18);
    await c1.read(morseFreqProvider.notifier).set(800);
    await c1.read(soundEnabledProvider.notifier).set(false);

    final c2 = await _container();
    expect(c2.read(morseWpmProvider), 18);
    expect(c2.read(morseFreqProvider), 800);
    expect(c2.read(soundEnabledProvider), isFalse);
    c1.dispose();
    c2.dispose();
  });

  test('nilai di luar batas dipaksa masuk rentang', () async {
    SharedPreferences.setMockInitialValues({
      'morse_wpm': 99.0,
      'morse_freq': 10.0,
    });
    final c = await _container();
    expect(c.read(morseWpmProvider), morseWpmMax);
    expect(c.read(morseFreqProvider), morseFreqMin);

    await c.read(morseWpmProvider.notifier).set(1);
    expect(c.read(morseWpmProvider), morseWpmMin);
    await c.read(morseFreqProvider.notifier).set(5000);
    expect(c.read(morseFreqProvider), morseFreqMax);
    c.dispose();
  });
}
