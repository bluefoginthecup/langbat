import 'package:flutter/material.dart';
import 'package:langarden_common/widgets/multi_select_actions.dart';

import '../../../src/repos/flashcard_repository.dart';
import '../../../src/repos/local_models.dart';
import '../../../src/repos/term_repository.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final _terms = TermRepository();
  final _sets = FlashcardRepository();
  final Set<String> selectedIds = {};
  bool multiSelectMode = false;

  void _toggleMultiSelect() {
    setState(() {
      multiSelectMode = !multiSelectMode;
      if (!multiSelectMode) selectedIds.clear();
    });
  }

  void _toggleSelectAll(List<LocalTerm> terms) {
    setState(() {
      if (selectedIds.length < terms.length) {
        selectedIds
          ..clear()
          ..addAll(terms.map((term) => term.id));
      } else {
        selectedIds.clear();
      }
    });
  }

  Future<void> _addWord({LocalTerm? term}) async {
    final result = await showDialog<_WordFormResult>(
      context: context,
      builder: (_) => _WordDialog(term: term),
    );
    if (result == null) return;

    if (term == null) {
      await _terms.addTerm(
        type: 'word',
        frontText: result.frontText,
        backText: result.backText,
        note: result.note,
      );
    } else {
      await _terms.updateTerm(
        id: term.id,
        type: 'word',
        frontText: result.frontText,
        backText: result.backText,
        note: result.note,
      );
    }
  }

  Future<void> _deleteSelected() async {
    await _terms.softDeleteTerms(selectedIds);
    if (!mounted) return;
    setState(() {
      selectedIds.clear();
      multiSelectMode = false;
    });
  }

  Future<void> _createSetFromSelected() async {
    if (selectedIds.isEmpty) return;
    final ids = selectedIds.toList(growable: false);
    await _sets.createSetFromTerms(
      title: '단어 세트 ${DateTime.now().month}/${DateTime.now().day}',
      termIds: ids,
    );
    if (!mounted) return;
    setState(() {
      selectedIds.clear();
      multiSelectMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('선택한 단어로 플래시카드 세트를 만들었습니다.')),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.text_fields, size: 56),
            const SizedBox(height: 16),
            const Text('저장된 단어가 없습니다.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _addWord,
              icon: const Icon(Icons.add),
              label: const Text('단어 추가'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('단어리스트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '단어 추가',
            onPressed: _addWord,
          ),
          IconButton(
            icon: Icon(multiSelectMode ? Icons.cancel : Icons.checklist),
            tooltip: multiSelectMode ? '멀티 선택 해제' : '멀티 선택 모드',
            onPressed: _toggleMultiSelect,
          ),
        ],
      ),
      body: StreamBuilder<List<LocalTerm>>(
        stream: _terms.watchTerms(type: 'word'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final terms = snapshot.data!;
          if (terms.isEmpty) return _buildEmptyState();

          return Column(
            children: [
              if (multiSelectMode)
                MultiSelectActions(
                  allSelected: selectedIds.length == terms.length,
                  onToggleSelectAll: () => _toggleSelectAll(terms),
                  onTrash: selectedIds.isEmpty ? () {} : _deleteSelected,
                  onCart: selectedIds.isEmpty ? () {} : _createSetFromSelected,
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: terms.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final term = terms[index];
                    if (multiSelectMode) {
                      return CheckboxListTile(
                        title: Text(term.frontText),
                        subtitle: Text(term.backText),
                        value: selectedIds.contains(term.id),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedIds.add(term.id);
                            } else {
                              selectedIds.remove(term.id);
                            }
                          });
                        },
                      );
                    }

                    return ListTile(
                      title: Text(term.frontText),
                      subtitle: Text(term.backText),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _addWord(term: term),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WordFormResult {
  const _WordFormResult({
    required this.frontText,
    required this.backText,
    required this.note,
  });

  final String frontText;
  final String backText;
  final String note;
}

class _WordDialog extends StatefulWidget {
  const _WordDialog({this.term});

  final LocalTerm? term;

  @override
  State<_WordDialog> createState() => _WordDialogState();
}

class _WordDialogState extends State<_WordDialog> {
  late final TextEditingController _frontController;
  late final TextEditingController _backController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.term?.frontText);
    _backController = TextEditingController(text: widget.term?.backText);
    _noteController = TextEditingController(text: widget.term?.note);
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final front = _frontController.text.trim();
    final back = _backController.text.trim();
    if (front.isEmpty) return;

    Navigator.pop(
      context,
      _WordFormResult(
        frontText: front,
        backText: back,
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.term == null ? '단어 추가' : '단어 수정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _frontController,
            decoration: const InputDecoration(labelText: '단어'),
            autofocus: true,
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: _backController,
            decoration: const InputDecoration(labelText: '뜻'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: '메모'),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('저장'),
        ),
      ],
    );
  }
}
