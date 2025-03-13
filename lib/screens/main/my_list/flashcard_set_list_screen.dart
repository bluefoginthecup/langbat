import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 이미 만들어둔 Provider와 액션 위젯 (MultiSelectActions)
import 'package:langarden_common/providers/multi_select_controller.dart';
import 'package:langarden_common/widgets/multi_select_actions.dart';

import '../study/flashcard/flashcard_set_edit_screen.dart';
import 'package:langarden_common/utils/trash_manager.dart';
import '../study/flashcard/flashcard_study_screen.dart';
import 'package:langarden_common/widgets/icon_button.dart'; // ✅ 툴팁 적용된 아이콘 버튼 불러오기


class FlashcardSetListScreen extends ConsumerStatefulWidget {
  const FlashcardSetListScreen({Key? key}) : super(key: key);

  @override
  _FlashcardSetListScreenState createState() => _FlashcardSetListScreenState();
}

class _FlashcardSetListScreenState extends ConsumerState<FlashcardSetListScreen> {
  // 여기서는 docs를 굳이 로컬에 저장하지 않고, StreamBuilder의 snapshot 데이터만 사용.
  Future<void> _startFlashcardLearning() async {
    // 1) 선택된 세트들의 items를 모으기
    final List<Map<String, String>> flashcards = [];
    final controller = ref.read(multiSelectControllerProvider.notifier);
    final selectedSetIds = controller.state;

    for (String setId in selectedSetIds) {
      final setDocRef = FirebaseFirestore.instance
          .collection('flashcard_sets')
          .doc(setId);

      final itemsSnapshot = await setDocRef.collection('items').get();

      for (var doc in itemsSnapshot.docs) {
        final data = doc.data();
        // 예: data = {"content": {"text": "Hola", "meaning": "안녕"}}
        final content = data["content"] ?? {};
        flashcards.add({
          "text": content["text"] ?? "",
          "meaning": content["meaning"] ?? "",
        });
      }
      print("DEBUG => flashcards: $flashcards");
    }

    // 2) 멀티선택 해제
    controller.toggleSelectionMode();
    controller.clearSelection();

    // 3) 학습 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardStudyScreen(flashcards: flashcards),
      ),
    );
  }


  Future<void> moveSelectedSetsToTrash() async {
    final controller = ref.read(multiSelectControllerProvider.notifier);
    final selectedIds = controller.state;

    if (selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("휴지통으로 이동"),
        content: Text("${selectedIds.length}개의 세트를 휴지통으로 보내시겠습니까?"),
        actions: [
          TextButton(
            child: const Text("취소"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("확인"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // trash_manager.dart의 함수 호출 (moveItemsToTrash)
      await TrashManager.moveItemsToTrash(
        context: context,
        docIds: selectedIds.toList(),
        originalCollection: 'flashcard_sets', // 원본
        trashCollection: 'trash',            // 휴지통 컬렉션 (예시)
        itemType: 'flashcard_set',           // 유형
      );

      // 멀티선택 해제
      controller.toggleSelectionMode();
      controller.clearSelection();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("휴지통 이동 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(multiSelectControllerProvider.notifier);
    final selectedIds = ref.watch(multiSelectControllerProvider);
    final isSelectionMode = controller.selectionMode;

    return Scaffold(
      appBar: AppBar(
        title: Text("내 플래시카드 세트"),
        actions: [
          IconButton(
            icon: Icon(isSelectionMode ? Icons.cancel : Icons.checklist),
            onPressed: () {
              setState(() {
                controller.toggleSelectionMode();
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('flashcard_sets')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("오류: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("생성된 세트가 없습니다."));
          }

          // 🔑 이제 docs를 여기서 사용할 수 있음
          return Column(
            children: [
              // 멀티선택 모드일 때만 MultiSelectActions 노출
              if (isSelectionMode)
                MultiSelectActions(
                  allSelected: selectedIds.length == docs.length,
                  onToggleSelectAll: () {
                    setState(() {
                      if (selectedIds.length == docs.length) {
                        controller.clearSelection();
                      } else {
                        for (var doc in docs) {
                          if (!selectedIds.contains(doc.id)) {
                            controller.toggleItem(doc.id);
                          }
                        }
                      }
                    });
                  },
                  onTrash: moveSelectedSetsToTrash,
                  onLearn: _startFlashcardLearning,

                ),

              // 이제 실제 리스트 뷰
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;
                    final name = data['name'] ?? '이름 없음';
                    final createdAt = data['createdAt'];

                    final isSelected = selectedIds.contains(docId);

                    if (isSelectionMode) {
                      return CheckboxListTile(
                        key: ValueKey(docId),
                        title: Text(name),
                        subtitle: Text(createdAt != null
                            ? "${(createdAt as Timestamp).toDate().toLocal()} 생성"
                            : "날짜 없음"),
                        value: isSelected,
                        onChanged: (checked) {
                          setState(() {
                            controller.toggleItem(docId);
                          });
                        },
                      );
                    } else {
                      return ListTile(
                        key: ValueKey(docId),
                        leading: const Icon(Icons.folder),
                        title: Text(name),
                        subtitle: Text(createdAt != null
                            ? "${(createdAt as Timestamp).toDate().toLocal()} 생성"
                            : "날짜 없음"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FlashcardSetEditScreen(setId: docId),
                            ),
                          );
                        },
                      );
                    }
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
