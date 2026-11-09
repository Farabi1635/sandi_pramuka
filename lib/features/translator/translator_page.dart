import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/ciphers/cipher.dart';
import '../../services/translation_service.dart';
import '../../shared/widgets/cipher_logo.dart';

class _HistoryItem {
  const _HistoryItem({
    required this.cipherId,
    required this.variantId,
    required this.shift,
    required this.mode,
    required this.input,
    required this.output,
  });
  final String cipherId;
  final String? variantId;
  final int shift;
  final TranslateMode mode;
  final String input;
  final String output;
}

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_HistoryItem> _history = [];

  Cipher _cipher = translatableCiphers.first;
  String? _variantId;
  int _shift = 3;
  TranslateMode _mode = TranslateMode.encode;
  TranslationResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _defaultVariant(Cipher c) =>
      c.variants.isEmpty ? null : c.variants.first.id;

  void _selectCipher(Cipher c) {
    setState(() {
      _cipher = c;
      _variantId = _defaultVariant(c);
      _result = null;
    });
  }

  void _run() {
    final options = CipherOptions(variantId: _variantId, shift: _shift);
    final text = _controller.text;
    final res = _mode == TranslateMode.encode
        ? _cipher.encode(text, options)
        : _cipher.decode(text, options);
    setState(() {
      _result = res;
      if (res.ok) {
        _history.insert(
          0,
          _HistoryItem(
            cipherId: _cipher.id,
            variantId: _variantId,
            shift: _shift,
            mode: _mode,
            input: text,
            output: res.output,
          ),
        );
        if (_history.length > 10) _history.removeLast();
      }
    });
  }

  void _swap() {
    final res = _result;
    setState(() {
      if (res != null && res.ok) {
        _controller.text = res.output;
      }
      _mode = _mode == TranslateMode.encode
          ? TranslateMode.decode
          : TranslateMode.encode;
      _result = null;
    });
  }

  void _clear() {
    setState(() {
      _controller.clear();
      _result = null;
    });
  }

  Future<void> _copy(String text) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Hasil disalin ke papan klip.')),
    );
  }

  void _restore(_HistoryItem item) {
    final c = cipherById(item.cipherId);
    if (c == null) return;
    setState(() {
      _cipher = c;
      _variantId = item.variantId;
      _shift = item.shift;
      _mode = item.mode;
      _controller.text = item.input;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isEncode = _mode == TranslateMode.encode;
    final variants = _cipher.variants;
    CipherVariant? activeVariant;
    for (final v in variants) {
      if (v.id == _variantId) activeVariant = v;
    }
    final res = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Penerjemah Sandi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownMenu<String>(
            key: ValueKey('cipher-${_cipher.id}'),
            label: const Text('Jenis sandi'),
            initialSelection: _cipher.id,
            expandedInsets: EdgeInsets.zero,
            requestFocusOnTap: false,
            leadingIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: CipherLogo(cipherId: _cipher.id, size: 28),
            ),
            dropdownMenuEntries: [
              for (final c in translatableCiphers)
                DropdownMenuEntry<String>(value: c.id, label: c.name),
            ],
            onSelected: (id) {
              if (id == null) return;
              final c = cipherById(id);
              if (c != null) _selectCipher(c);
            },
          ),
          const SizedBox(height: 8),
          Text(_cipher.description, style: t.textTheme.bodySmall),
          if (variants.length > 1) ...[
            const SizedBox(height: 12),
            DropdownMenu<String>(
              key: ValueKey('variant-${_cipher.id}'),
              label: const Text('Varian'),
              initialSelection: _variantId,
              expandedInsets: EdgeInsets.zero,
              requestFocusOnTap: false,
              dropdownMenuEntries: [
                for (final v in variants)
                  DropdownMenuEntry<String>(value: v.id, label: v.label),
              ],
              onSelected: (id) => setState(() {
                _variantId = id;
                _result = null;
              }),
            ),
          ],
          if (activeVariant != null) ...[
            const SizedBox(height: 6),
            Text(
              variants.length > 1
                  ? (activeVariant.note ?? '')
                  : '${activeVariant.label}. ${activeVariant.note ?? ''}',
              style: t.textTheme.bodySmall,
            ),
          ],
          if (_cipher.usesShift) ...[
            const SizedBox(height: 12),
            Text('Geseran: $_shift', style: t.textTheme.titleSmall),
            Slider(
              value: _shift.toDouble(),
              min: 1,
              max: 25,
              divisions: 24,
              label: '$_shift',
              onChanged: (v) => setState(() {
                _shift = v.round();
                _result = null;
              }),
            ),
          ],
          const SizedBox(height: 12),
          SegmentedButton<TranslateMode>(
            segments: const [
              ButtonSegment(
                value: TranslateMode.encode,
                label: Text('Teks ke Sandi'),
                icon: Icon(Icons.lock_outline),
              ),
              ButtonSegment(
                value: TranslateMode.decode,
                label: Text('Sandi ke Teks'),
                icon: Icon(Icons.lock_open),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() {
              _mode = s.first;
              _result = null;
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('input_field'),
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: isEncode ? 'Teks biasa' : 'Kode sandi',
              hintText: isEncode ? _cipher.encodeHint : _cipher.decodeHint,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _run,
                  icon: const Icon(Icons.translate),
                  label: const Text('Terjemahkan'),
                ),
              ),
              IconButton(
                tooltip: 'Tukar mode',
                onPressed: _swap,
                icon: const Icon(Icons.swap_vert),
              ),
              IconButton(
                tooltip: 'Hapus',
                onPressed: _clear,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          if (res != null) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: res.ok
                  ? t.colorScheme.primary.withAlpha(25)
                  : t.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: res.ok
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hasil', style: t.textTheme.labelLarge),
                          const SizedBox(height: 6),
                          SelectableText(res.output,
                              style: t.textTheme.titleMedium),
                          if (res.note != null) ...[
                            const SizedBox(height: 8),
                            Text(res.note!, style: t.textTheme.bodySmall),
                          ],
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _copy(res.output),
                              icon: const Icon(Icons.copy),
                              label: const Text('Salin'),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: t.colorScheme.onErrorContainer),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              res.error ?? 'Terjadi kesalahan.',
                              style: TextStyle(
                                  color: t.colorScheme.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
          if (_history.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Riwayat sesi ini', style: t.textTheme.titleMedium),
            const SizedBox(height: 4),
            for (final h in _history)
              Card(
                elevation: 0,
                child: ListTile(
                  leading: CipherLogo(cipherId: h.cipherId, size: 36),
                  title: Text(h.output,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${cipherById(h.cipherId)?.name ?? ''} - '
                    '${h.mode == TranslateMode.encode ? 'Teks ke Sandi' : 'Sandi ke Teks'}',
                  ),
                  onTap: () => _restore(h),
                ),
              ),
            const Text(
              'Riwayat permanen tersimpan di Tahap 5.',
              style: TextStyle(fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
