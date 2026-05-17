import 'package:flutter/material.dart';

import 'package:langbat/screens/main/study/flashcard/flashcard_set_edit_screen.dart';
import 'package:langbat/screens/main/study/flashcard/flashcard_study_screen.dart';
import 'package:langbat/src/repos/flashcard_repository.dart';
import 'package:langbat/src/repos/local_models.dart';

class FlashcardSetListScreen extends StatefulWidget {
  const FlashcardSetListScreen({super.key});

  @override
  State<FlashcardSetListScreen> createState() => _FlashcardSetListScreenState();
}

class _FlashcardSetListScreenState extends State<FlashcardSetListScreen> {
  final _repo = FlashcardRepository();
  final _selectedIds = <String>{};

  bool get _selectionMode => _selectedIds.isNotEmpty;

  Future<void> _startFlashcardLearning(String setId) async {
    final cards = await _repo.loadCards(setId);
    if (!mounted) return;

    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('학습할 카드가 없습니다.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardStudyScreen(
          flashcards: cards.map((card) => card.toStudyMap()).toList(),
        ),
      ),
    );
  }

  Future<void> _editSet(String setId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardSetEditScreen(setId: setId),
      ),
    );
  }

  Future<void> _deleteSelectedSets() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('세트 삭제'),
        content: Text('${_selectedIds.length}개의 세트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await _repo.softDeleteSets(_selectedIds);
    if (!mounted) return;
    setState(_selectedIds.clear);
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _selectionMode ? '세트 선택됨 ${_selectedIds.length}개' : '내 플래시카드 세트'),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              tooltip: '선택 세트 학습',
              icon: const Icon(Icons.play_circle),
              onPressed: () {
                if (_selectedIds.isNotEmpty) {
                  _startFlashcardLearning(_selectedIds.first);
                }
              },
            ),
            IconButton(
              tooltip: '삭제',
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSelectedSets,
            ),
            IconButton(
              tooltip: '선택 해제',
              icon: const Icon(Icons.clear),
              onPressed: () => setState(_selectedIds.clear),
            ),
          ],
        ],
      ),
      body: StreamBuilder<List<LocalFlashcardSet>>(
        stream: _repo.watchSets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }

          final sets = snapshot.data ?? const <LocalFlashcardSet>[];
          if (sets.isEmpty) {
            return const Center(child: Text('세트가 없습니다.'));
          }

          return ListView.separated(
            itemCount: sets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final set = sets[index];
              final isSelected = _selectedIds.contains(set.id);

              if (_selectionMode) {
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(set.title),
                  subtitle: Text('${set.itemCount}장'),
                  onChanged: (_) => _toggleSelection(set.id),
                );
              }

              return ListTile(
                leading: const Icon(Icons.folder),
                title: Text(set.title),
                subtitle: Text('${set.itemCount}장'),
                onLongPress: () => _toggleSelection(set.id),
                onTap: () => _startFlashcardLearning(set.id),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: '편집',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _editSet(set.id),
                    ),
                    IconButton(
                      tooltip: '학습',
                      icon: const Icon(Icons.play_circle_outline),
                      onPressed: () => _startFlashcardLearning(set.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
