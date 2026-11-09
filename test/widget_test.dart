import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sandi_pramuka/app.dart';
import 'package:sandi_pramuka/core/constants/cipher_catalog_seed.dart';
import 'package:sandi_pramuka/core/utils/settings_provider.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const SandiPramukaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('katalog seed tidak kosong dan id unik', () {
    final ids = [
      for (final c in cipherCategories) ...c.ciphers.map((e) => e.id)
    ];
    expect(ids, isNotEmpty);
    expect(ids.toSet().length, ids.length);
  });

  testWidgets('navigasi bawah berpindah antar tab', (tester) async {
    await _pumpApp(tester);
    expect(find.text('Salam Pramuka!'), findsOneWidget);

    await tester.tap(find.text('Belajar'));
    await tester.pumpAndSettle();
    expect(find.text('Katalog Sandi'), findsOneWidget);

    await tester.tap(find.text('Penerjemah'));
    await tester.pumpAndSettle();
    expect(find.text('Penerjemah Sandi'), findsOneWidget);
  });
}
