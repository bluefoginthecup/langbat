import 'package:flutter/material.dart';
import 'package:langarden_common/widgets/multi_select_actions.dart';

import '../../../src/repos/flashcard_repository.dart';
import '../../../src/repos/local_models.dart';
import '../../../src/repos/term_repository.dart';
import '../input/verb_detail_input_screen.dart' show VerbDetailInputScreen;

class VerbListScreen extends StatefulWidget {
  const VerbListScreen({super.key});

  @override
  State<VerbListScreen> createState() => _VerbListScreenState();
}

class _VerbListScreenState extends State<VerbListScreen> {
  final _terms = TermRepository();
  final _sets = FlashcardRepository();
  final Set<String> selectedIds = {};
  bool multiSelectMode = false;

  void toggleMultiSelect() {
    setState(() {
      multiSelectMode = !multiSelectMode;
      if (!multiSelectMode) selectedIds.clear();
    });
  }

  void toggleSelectAll(List<LocalTerm> terms) {
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

  Future<void> sendSelectedToTrash() async {
    await _terms.softDeleteTerms(selectedIds);
    if (!mounted) return;
    setState(() {
      selectedIds.clear();
      multiSelectMode = false;
    });
  }

  Future<void> addSelectedToCart() async {
    if (selectedIds.isEmpty) return;
    await _sets.createSetFromTerms(
      title: '동사 세트 ${DateTime.now().month}/${DateTime.now().day}',
      termIds: selectedIds.toList(growable: false),
    );
    if (!mounted) return;
    setState(() {
      selectedIds.clear();
      multiSelectMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('선택한 동사로 플래시카드 세트를 만들었습니다.')),
    );
  }

  Future<void> _openEditor([LocalTerm? term]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerbDetailInputScreen(
          termId: term?.id,
          text: term?.frontText ?? '',
          meaning: term?.backText ?? '',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories_outlined, size: 56),
            const SizedBox(height: 16),
            const Text('저장된 동사가 없습니다.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add),
              label: const Text('동사 추가'),
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
        title: const Text('동사리스트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '동사 추가',
            onPressed: () => _openEditor(),
          ),
          IconButton(
            icon: Icon(multiSelectMode ? Icons.cancel : Icons.checklist),
            tooltip: multiSelectMode ? '멀티 선택 해제' : '멀티 선택 모드',
            onPressed: toggleMultiSelect,
          ),
        ],
      ),
      body: StreamBuilder<List<LocalTerm>>(
        stream: _terms.watchTerms(type: 'verb'),
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
                  onToggleSelectAll: () => toggleSelectAll(terms),
                  onTrash: selectedIds.isEmpty ? () {} : sendSelectedToTrash,
                  onCart: addSelectedToCart,
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
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openEditor(term),
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
