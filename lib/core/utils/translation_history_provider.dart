import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_provider.dart';

class TranslationRecord {
  const TranslationRecord({
    required this.cipherId,
    required this.variantId,
    required this.shift,
    required this.mode,
    required this.input,
    required this.output,
    required this.at,
  });

  final String cipherId;
  final String? variantId;
  final int shift;

  /// 'encode' atau 'decode'.
  final String mode;
  final String input;
  final String output;
  final int at;

  Map<String, Object?> toJson() => {
        'cipherId': cipherId,
        'variantId': variantId,
        'shift': shift,
        'mode': mode,
        'input': input,
        'output': output,
        'at': at,
      };

  factory TranslationRecord.fromJson(Map<String, dynamic> json) =>
      TranslationRecord(
        cipherId: json['cipherId'] as String,
        variantId: json['variantId'] as String?,
        shift: json['shift'] as int,
        mode: json['mode'] as String,
        input: json['input'] as String,
        output: json['output'] as String,
        at: json['at'] as int,
      );

  bool sameContent(TranslationRecord o) =>
      cipherId == o.cipherId &&
      variantId == o.variantId &&
      shift == o.shift &&
      mode == o.mode &&
      input == o.input &&
      output == o.output;
}

/// Riwayat penerjemahan (lokal, terbaru di depan, maksimal 50).
class TranslationHistoryNotifier extends Notifier<List<TranslationRecord>> {
  static const _key = 'translation_history';
  static const maxItems = 50;

  @override
  List<TranslationRecord> build() {
    final raw = ref.read(sharedPrefsProvider).getStringList(_key) ??
        const <String>[];
    final out = <TranslationRecord>[];
    for (final s in raw) {
      try {
        out.add(
            TranslationRecord.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // Lewati data rusak.
      }
    }
    return out;
  }

  Future<void> _save(List<TranslationRecord> list) async {
    state = list;
    await ref
        .read(sharedPrefsProvider)
        .setStringList(_key, [for (final r in list) jsonEncode(r.toJson())]);
  }

  Future<void> add(TranslationRecord r) async {
    if (state.isNotEmpty && state.first.sameContent(r)) return;
    final next = [r, ...state];
    if (next.length > maxItems) next.removeRange(maxItems, next.length);
    await _save(next);
  }

  Future<void> clear() => _save(const []);
}

final translationHistoryProvider =
    NotifierProvider<TranslationHistoryNotifier, List<TranslationRecord>>(
        TranslationHistoryNotifier.new);
