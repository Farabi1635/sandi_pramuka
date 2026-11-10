import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/translation_service.dart';
import '../../shared/widgets/cipher_logo.dart';
import 'dictionary_lookup.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _controller = TextEditingController();
  String? _filter;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() {});
  }

  List<DictionaryHit> _apply(List<DictionaryHit> hits) =>
      hits.where((h) => _filter == null || h.cipherId == _filter).toList();

  Widget _section(
      BuildContext context, String title, List<DictionaryHit> hits) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Text(title, style: t.textTheme.titleMedium),
        ),
        for (final h in hits)
          Card(
            elevation: 0,
            child: ListTile(
              leading: CipherLogo(cipherId: h.cipherId, size: 40),
              title: Text(h.cipherName),
              trailing: SelectableText(
                h.value,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final query = _controller.text.trim();
    final symbolHits = _apply(lookupSymbol(query));
    final codeHits = _apply(lookupCode(query));
    final hasResult = symbolHits.isNotEmpty || codeHits.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Kamus Sandi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Cari huruf, angka, atau kode',
              hintText: 'Contoh: A, 5, .-, 25, 145',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus',
                      icon: const Icon(Icons.clear),
                      onPressed: () => _setQuery(''),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Semua'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                ),
                for (final c in translatableCiphers)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c.name),
                      selected: _filter == c.id,
                      onSelected: (_) => setState(() => _filter = c.id),
                    ),
                  ),
              ],
            ),
          ),
          if (query.isEmpty) ...[
            const SizedBox(height: 24),
            Text('Coba cari:', style: t.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final example in const ['A', 'S', '5', '.-', '25', '145'])
                  ActionChip(
                    label: Text(example),
                    onPressed: () => _setQuery(example),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ketik satu huruf, angka, atau tanda baca untuk melihat kodenya '
              'di semua sandi. Ketik sebuah kode untuk mengetahui artinya.',
              style: t.textTheme.bodySmall,
            ),
          ] else if (!hasResult) ...[
            const SizedBox(height: 32),
            const Center(child: Text('Tidak ada hasil untuk pencarian ini.')),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Untuk menerjemahkan kata atau kalimat, gunakan Penerjemah.',
                style: t.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/translator'),
                icon: const Icon(Icons.translate),
                label: const Text('Buka Penerjemah'),
              ),
            ),
          ] else ...[
            if (symbolHits.isNotEmpty)
              _section(context, 'Kode untuk "${query.toUpperCase()}"',
                  symbolHits),
            if (codeHits.isNotEmpty)
              _section(context, 'Arti dari "$query"', codeHits),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
