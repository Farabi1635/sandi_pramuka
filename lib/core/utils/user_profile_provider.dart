import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_provider.dart';

enum ScoutLevel { siaga, penggalang, penegak, pandega }

String scoutLevelLabel(ScoutLevel l) => switch (l) {
      ScoutLevel.siaga => 'Siaga',
      ScoutLevel.penggalang => 'Penggalang',
      ScoutLevel.penegak => 'Penegak',
      ScoutLevel.pandega => 'Pandega',
    };

class UserProfile {
  const UserProfile({this.name = '', this.level});

  final String name;
  final ScoutLevel? level;

  bool get hasName => name.trim().isNotEmpty;
}

/// Nama dan tingkatan Pramuka, disimpan lokal.
class UserProfileNotifier extends Notifier<UserProfile> {
  static const _nameKey = 'user_name';
  static const _levelKey = 'user_level';
  static const maxNameLength = 30;

  @override
  UserProfile build() {
    final prefs = ref.read(sharedPrefsProvider);
    final name = prefs.getString(_nameKey) ?? '';
    final levelName = prefs.getString(_levelKey);
    ScoutLevel? level;
    for (final l in ScoutLevel.values) {
      if (l.name == levelName) level = l;
    }
    return UserProfile(name: name, level: level);
  }

  Future<void> save({required String name, required ScoutLevel? level}) async {
    var clean = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.length > maxNameLength) {
      clean = clean.substring(0, maxNameLength).trim();
    }
    state = UserProfile(name: clean, level: level);

    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_nameKey, clean);
    if (level == null) {
      await prefs.remove(_levelKey);
    } else {
      await prefs.setString(_levelKey, level.name);
    }
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile>(UserProfileNotifier.new);
