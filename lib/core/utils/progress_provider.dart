import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_provider.dart';

/// Himpunan id yang disimpan lokal (SharedPreferences).
abstract class _IdSetNotifier extends Notifier<Set<String>> {
  String get prefsKey;

  @override
  Set<String> build() {
    final saved = ref.read(sharedPrefsProvider).getStringList(prefsKey);
    return (saved ?? const <String>[]).toSet();
  }

  Future<void> toggle(String id) async {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
    await ref.read(sharedPrefsProvider).setStringList(prefsKey, next.toList());
  }
}

class CompletedNotifier extends _IdSetNotifier {
  @override
  String get prefsKey => 'completed_ciphers';
}

class FavoritesNotifier extends _IdSetNotifier {
  @override
  String get prefsKey => 'favorite_ciphers';
}

final completedProvider =
    NotifierProvider<CompletedNotifier, Set<String>>(CompletedNotifier.new);

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
