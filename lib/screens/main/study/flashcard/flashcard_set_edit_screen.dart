import 'package:flutter/material.dart';

import 'package:langbat/src/repos/flashcard_repository.dart';
import 'package:langbat/src/repos/local_models.dart';

class FlashcardSetEditScreen extends StatefulWidget {
  const FlashcardSetEditScreen({super.key, required this.setId});

  final String setId;

  @override
  State<FlashcardSetEditScreen> createState() => _FlashcardSetEditScreenState();
}

class _FlashcardSetEditScreenState extends State<FlashcardSetEditScreen> {
  final _repo = FlashcardRepository();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _selectedItemIds = <String>{};

  LocalFlashcardSet? _set;
  List<LocalFlashcard> _cards = [];
  bool _loading = true;
  bool _saving = false;

  bool get _selectionMode => _selectedItemIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final set = await _repo.getSet(widget.setId);
    final cards = await _repo.loadCards(widget.setId);
    if (!mounted) return;

    setState(() {
      _set = set;
      _cards = cards;
      _titleController.text = set?.title ?? '';
      _descriptionController.text = set?.description ?? '';
      _selectedItemIds.clear();
      _loading = false;
    });
  }

  Future<void> _saveSetInfo() async {
    if (_saving || _set == null) return;
    setState(() => _saving = true);
    try {
      await _repo.updateSet(
        setId: widget.setId,
        title: _titleController.text,
        description: _descriptionController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('세트 정보가 저장되었습니다.')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final nextCards = List<LocalFlashcard>.from(_cards);
    final item = nextCards.removeAt(oldIndex);
    nextCards.insert(newIndex, item);
    setState(() => _cards = nextCards);

    try {
      await _repo.reorderCards(
        setId: widget.setId,
        itemIds: nextCards.map((card) => card.id).toList(growable: false),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('순서 저장 실패: $e')),
      );
      await _load();
    }
  }

  Future<void> _openCardDialog({LocalFlashcard? card}) async {
    final frontController = TextEditingController(text: card?.text ?? '');
    final backController = TextEditingController(text: card?.meaning ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(card == null ? '카드 추가' : '카드 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: frontController,
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '스페인어',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: backController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '한국어',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final front = frontController.text.trim();
    final back = backController.text.trim();
    if (front.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('스페인어 문장을 입력하세요.')),
      );
      return;
    }

    try {
      if (card == null) {
        await _repo.addSentenceCardToSet(
          setId: widget.setId,
          frontText: front,
          backText: back,
        );
      } else {
        await _repo.updateCardTerm(
          termId: card.termId,
          frontText: front,
          backText: back,
        );
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  Future<void> _openBulkAppendDialog() async {
    final inputController = TextEditingController();
    var preview = _parseSentencePairs('');

    final pairs = await showDialog<List<MapEntry<String, String>>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void refresh() {
            setDialogState(() {
              preview = _parseSentencePairs(inputController.text);
            });
          }

          return AlertDialog(
            title: const Text('대량 추가'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: inputController,
                      minLines: 10,
                      maxLines: 14,
                      keyboardType: TextInputType.multiline,
                      onChanged: (_) => refresh(),
                      decoration: const InputDecoration(
                        labelText: '스페인어 한 줄, 한국어 한 줄',
                        hintText:
                            'La directora es severa.\n교장 선생님은 엄격하다.\n\nVoy a la escuela.\n나는 학교에 간다.',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '카드 ${preview.pairs.length}개 · 오류 ${preview.errorCount}개 · 중복 제외 ${preview.duplicateCount}개',
                      ),
                    ),
                    if (preview.message != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          preview.message!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: preview.pairs.isEmpty
                    ? null
                    : () => Navigator.pop(context, preview.pairs),
                child: const Text('추가'),
              ),
            ],
          );
        },
      ),
    );

    if (pairs == null || pairs.isEmpty) return;

    try {
      await _repo.appendSentencePairsToSet(
        setId: widget.setId,
        pairs: pairs,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카드 ${pairs.length}개를 추가했습니다.')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('추가 실패: $e')),
      );
    }
  }

  Future<void> _deleteSelectedCards() async {
    if (_selectedItemIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 제거'),
        content: Text('${_selectedItemIds.length}개 카드를 이 세트에서 제거할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('제거'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await _repo.removeCardsFromSet(
      setId: widget.setId,
      itemIds: _selectedItemIds,
    );
    await _load();
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('플래시카드 세트 편집')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_set == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('플래시카드 세트 편집')),
        body: const Center(child: Text('세트를 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _selectionMode ? '카드 ${_selectedItemIds.length}개 선택' : '세트 편집'),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              tooltip: '선택 제거',
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSelectedCards,
            ),
            IconButton(
              tooltip: '선택 해제',
              icon: const Icon(Icons.clear),
              onPressed: () => setState(_selectedItemIds.clear),
            ),
          ] else ...[
            IconButton(
              tooltip: '카드 추가',
              icon: const Icon(Icons.add),
              onPressed: () => _openCardDialog(),
            ),
            IconButton(
              tooltip: '대량 추가',
              icon: const Icon(Icons.playlist_add),
              onPressed: _openBulkAppendDialog,
            ),
            IconButton(
              tooltip: '세트 정보 저장',
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              onPressed: _saving ? null : _saveSetInfo,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '세트 이름',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  minLines: 1,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '설명',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cards.isEmpty
                ? const Center(child: Text('카드가 없습니다.'))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _cards.length,
                    onReorder: _reorder,
                    buildDefaultDragHandles: false,
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      final selected = _selectedItemIds.contains(card.id);

                      return ListTile(
                        key: ValueKey(card.id),
                        leading: _selectionMode
                            ? Checkbox(
                                value: selected,
                                onChanged: (_) => _toggleSelection(card.id),
                              )
                            : ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle),
                              ),
                        title: Text(
                          card.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          card.meaning.isEmpty ? '뜻 없음' : card.meaning,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: _selectionMode
                            ? null
                            : IconButton(
                                tooltip: '수정',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _openCardDialog(card: card),
                              ),
                        onTap: _selectionMode
                            ? () => _toggleSelection(card.id)
                            : () => _openCardDialog(card: card),
                        onLongPress: () => _toggleSelection(card.id),
                      );
                    },
                  ),
          ),
        ],
      ),
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
