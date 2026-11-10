import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/ciphers/cipher.dart';
import '../../services/translation_service.dart';
import '../../shared/widgets/cipher_logo.dart';
import 'challenge_codec.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tantangan'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Buat'), Tab(text: 'Kerjakan')],
          ),
        ),
        body: const TabBarView(
          children: [_CreateTab(), _SolveTab()],
        ),
      ),
    );
  }
}

class _CreateTab extends StatefulWidget {
  const _CreateTab();

  @override
  State<_CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<_CreateTab> {
  final TextEditingController _message = TextEditingController();

  Cipher _cipher = translatableCiphers.first;
  String? _variantId;
  int _shift = 3;
  ChallengeLevel _level = ChallengeLevel.mudah;

  Challenge? _created;
  String? _note;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _selectCipher(Cipher c) {
    setState(() {
      _cipher = c;
      _variantId = c.variants.isEmpty ? null : c.variants.first.id;
      _created = null;
      _error = null;
    });
  }

  void _create() {
    final res = buildChallenge(
      cipher: _cipher,
      options: CipherOptions(variantId: _variantId, shift: _shift),
      message: _message.text,
      level: _level,
    );
    setState(() {
      _created = res.challenge;
      _note = res.note;
      _error = res.error;
    });
  }

  Future<void> _copy(String text, String label) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text('$label disalin.')));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final variants = _cipher.variants;
    final created = _created;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Buat pesan rahasia untuk temanmu.',
            style: t.textTheme.bodySmall),
        const SizedBox(height: 12),
        DropdownMenu<String>(
          key: ValueKey('challenge-${_cipher.id}'),
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
            final c = id == null ? null : cipherById(id);
            if (c != null) _selectCipher(c);
          },
        ),
        if (variants.length > 1) ...[
          const SizedBox(height: 12),
          DropdownMenu<String>(
            key: ValueKey('challenge-variant-${_cipher.id}'),
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
              _created = null;
            }),
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
              _created = null;
            }),
          ),
        ],
        const SizedBox(height: 12),
        Text('Tingkat kesulitan', style: t.textTheme.labelLarge),
        const SizedBox(height: 6),
        SegmentedButton<ChallengeLevel>(
          segments: [
            for (final l in ChallengeLevel.values)
              ButtonSegment(value: l, label: Text(challengeLevelLabel(l))),
          ],
          selected: {_level},
          onSelectionChanged: (s) => setState(() {
            _level = s.first;
            _created = null;
          }),
        ),
        const SizedBox(height: 6),
        Text(
          'Mudah: 3 percobaan, nama sandi terlihat. '
          'Sedang: 2 percobaan, nama sandi terlihat. '
          'Sulit: 1 percobaan, nama sandi disembunyikan.',
          style: t.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _message,
          minLines: 2,
          maxLines: 5,
          onChanged: (_) => setState(() => _created = null),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Pesan rahasia',
            hintText: 'Contoh: SIAGA BERKEMAH',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _create,
          icon: const Icon(Icons.flag),
          label: const Text('Buat tantangan'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: t.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(_error!,
                  style: TextStyle(color: t.colorScheme.onErrorContainer)),
            ),
          ),
        ],
        if (created != null) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: t.colorScheme.primary.withAlpha(25),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pesan tersandi', style: t.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  SelectableText(
                    created.coded,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  if (_note != null) ...[
                    const SizedBox(height: 6),
                    Text(_note!, style: t.textTheme.bodySmall),
                  ],
                  const SizedBox(height: 12),
                  Text('Kode tantangan', style: t.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  SelectableText(
                    encodeChallenge(created),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _copy(encodeChallenge(created), 'Kode tantangan'),
                        icon: const Icon(Icons.copy),
                        label: const Text('Salin kode'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _copy(created.coded, 'Pesan tersandi'),
                        icon: const Icon(Icons.copy),
                        label: const Text('Salin pesan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Jawaban yang benar: ${created.expectedAnswer}',
                      style: t.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    'Kirim kode tantangan ke temanmu lewat chat. Kode ini '
                    'hanya pembungkus pesan, bukan enkripsi.',
                    style: t.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SolveTab extends StatefulWidget {
  const _SolveTab();

  @override
  State<_SolveTab> createState() => _SolveTabState();
}

class _SolveTabState extends State<_SolveTab> {
  final TextEditingController _code = TextEditingController();
  final TextEditingController _answer = TextEditingController();

  Challenge? _challenge;
  String? _codeError;
  int _attempts = 0;
  int? _score;
  String? _feedback;

  @override
  void dispose() {
    _code.dispose();
    _answer.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    setState(() => _code.text = data?.text ?? '');
  }

  void _open() {
    final c = decodeChallenge(_code.text);
    setState(() {
      _challenge = c;
      _codeError = c == null
          ? 'Kode tantangan tidak valid. Pastikan kode disalin utuh '
              '(diawali SP1-).'
          : null;
      _attempts = 0;
      _score = null;
      _feedback = null;
      _answer.clear();
    });
  }

  void _check() {
    final c = _challenge;
    if (c == null || _score != null) return;
    if (_answer.text.trim().isEmpty) {
      setState(() => _feedback = 'Ketik jawabanmu dulu.');
      return;
    }
    final attempt = _attempts + 1;
    if (isCorrectAnswer(c, _answer.text)) {
      setState(() {
        _attempts = attempt;
        _score = challengeScore(c.level, attempt);
        _feedback = 'Benar!';
      });
    } else if (attempt >= maxAttempts(c.level)) {
      setState(() {
        _attempts = attempt;
        _score = 0;
        _feedback = 'Percobaan habis. Jawaban yang benar: ${c.expectedAnswer}';
      });
    } else {
      setState(() {
        _attempts = attempt;
        _feedback = 'Belum tepat. Sisa percobaan: '
            '${maxAttempts(c.level) - attempt}.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = _challenge;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Tempel kode tantangan dari temanmu.',
            style: t.textTheme.bodySmall),
        const SizedBox(height: 12),
        TextField(
          controller: _code,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Kode tantangan',
            hintText: 'SP1-...',
            suffixIcon: IconButton(
              tooltip: 'Tempel',
              icon: const Icon(Icons.paste),
              onPressed: _paste,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _open,
          icon: const Icon(Icons.lock_open),
          label: const Text('Buka tantangan'),
        ),
        if (_codeError != null) ...[
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: t.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(_codeError!,
                  style: TextStyle(color: t.colorScheme.onErrorContainer)),
            ),
          ),
        ],
        if (c != null) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: t.colorScheme.primary.withAlpha(25),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tingkat ${challengeLevelLabel(c.level)} - '
                    '${maxAttempts(c.level)} percobaan',
                    style: t.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  if (showsCipherName(c.level) && c.cipher != null)
                    Row(
                      children: [
                        CipherLogo(cipherId: c.cipherId, size: 32),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c.cipher!.usesShift
                                ? '${c.cipher!.name} (geser ${c.shift})'
                                : c.cipher!.name,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text('Jenis sandi disembunyikan. Tebak sendiri!'),
                  const SizedBox(height: 10),
                  Text('Pesan tersandi:', style: t.textTheme.bodySmall),
                  SelectableText(
                    c.coded,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_score == null) ...[
            TextField(
              controller: _answer,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Jawabanmu',
              ),
              onSubmitted: (_) => _check(),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _check,
              child: Text('Periksa (percobaan ${_attempts + 1} dari '
                  '${maxAttempts(c.level)})'),
            ),
          ],
          if (_feedback != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_feedback!, style: t.textTheme.titleSmall),
            ),
          if (_score != null)
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('$_score', style: t.textTheme.displayMedium),
                    Text('Nilai tantangan', style: t.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
