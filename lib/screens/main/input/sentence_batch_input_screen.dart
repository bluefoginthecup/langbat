import 'package:flutter/material.dart';

import 'package:langbat/src/repos/flashcard_repository.dart';

class SentenceBatchInputScreen extends StatefulWidget {
  const SentenceBatchInputScreen({super.key});

  @override
  State<SentenceBatchInputScreen> createState() =>
      _SentenceBatchInputScreenState();
}

class _SentenceBatchInputScreenState extends State<SentenceBatchInputScreen> {
  final _setTitleController = TextEditingController();
  final _inputController = TextEditingController();
  final _repo = FlashcardRepository();
  bool _saving = false;

  _SentenceBatchPreview get _preview =>
      _parseSentencePairs(_inputController.text);

  @override
  void initState() {
    super.initState();
    _setTitleController.text = '새 문장 세트';
    _inputController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _inputController.removeListener(_refreshPreview);
    _setTitleController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final preview = _preview;
    if (preview.pairs.isEmpty || _saving) return;

    setState(() => _saving = true);
    try {
      await _repo.createSentenceSetFromPairs(
        title: _setTitleController.text,
        description: '붙여넣기 대량 입력',
        pairs: preview.pairs,
      );

      if (!mounted) return;
      _inputController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문장 카드 ${preview.pairs.length}개를 저장했습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final canSave = preview.pairs.isNotEmpty && !_saving;

    return Scaffold(
      appBar: AppBar(title: const Text('문장 대량입력')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _setTitleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '세트 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inputController,
              minLines: 12,
              maxLines: 18,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: '붙여넣기',
                hintText:
                    'La directora es severa.\n교장 선생님은 엄격하다.\n\nVoy a la escuela.\n나는 학교에 간다.',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _PreviewPanel(preview: preview),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: canSave ? _save : null,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_saving ? '저장 중' : '가져오기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.preview});

  final _SentenceBatchPreview preview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatChip(label: '카드', value: '${preview.pairs.length}개'),
                _StatChip(label: '오류', value: '${preview.errorCount}개'),
                _StatChip(label: '중복 제외', value: '${preview.duplicateCount}개'),
              ],
            ),
            if (preview.message != null) ...[
              const SizedBox(height: 10),
              Text(
                preview.message!,
                style: TextStyle(color: colorScheme.error),
              ),
            ],
            if (preview.pairs.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '미리보기',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              ...preview.pairs.take(3).map(
                    (pair) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pair.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            pair.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (preview.pairs.length > 3)
                Text('외 ${preview.pairs.length - 3}개'),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text('$label $value'),
      backgroundColor: colorScheme.surfaceContainerHighest,
    );
  }
}

class _SentenceBatchPreview {
  const _SentenceBatchPreview({
    required this.pairs,
    required this.errorCount,
    required this.duplicateCount,
    this.message,
  });

  final List<MapEntry<String, String>> pairs;
  final int errorCount;
  final int duplicateCount;
  final String? message;
}

_SentenceBatchPreview _parseSentencePairs(String raw) {
  final lines = raw
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);

  if (lines.isEmpty) {
    return const _SentenceBatchPreview(
      pairs: [],
      errorCount: 0,
      duplicateCount: 0,
    );
  }

  final pairs = <MapEntry<String, String>>[];
  final seen = <String>{};
  var duplicateCount = 0;

  for (var index = 0; index + 1 < lines.length; index += 2) {
    final front = lines[index];
    final back = lines[index + 1];
    final key = '${front.toLowerCase()}|${back.toLowerCase()}';
    if (seen.contains(key)) {
      duplicateCount += 1;
      continue;
    }
    seen.add(key);
    pairs.add(MapEntry(front, back));
  }

  final errorCount = lines.length.isOdd ? 1 : 0;
  final message =
      errorCount == 0 ? null : '마지막 줄에 짝이 없습니다. 스페인어 줄 다음에 한국어 줄을 추가하세요.';

  return _SentenceBatchPreview(
    pairs: pairs,
    errorCount: errorCount,
    duplicateCount: duplicateCount,
    message: message,
  );
}
