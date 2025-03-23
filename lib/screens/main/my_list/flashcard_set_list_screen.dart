import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langarden_common/providers/multi_select_controller.dart';
import 'package:langarden_common/widgets/multi_select_actions.dart';

import '../study/flashcard/flashcard_set_edit_screen.dart';
import 'package:langarden_common/utils/trash_manager.dart';
import '../study/flashcard/flashcard_study_screen.dart';
import 'package:langarden_common/widgets/icon_button.dart'; // ✅ 툴팁 적용된 아이콘 버튼 불러오기

class FlashcardSetListScreen extends ConsumerStatefulWidget {
  const FlashcardSetListScreen({super.key});

  @override
  _FlashcardSetListScreenState createState() => _FlashcardSetListScreenState();
}

class _FlashcardSetListScreenState extends ConsumerState<FlashcardSetListScreen> {
  Future<void> _startFlashcardLearning(String setId) async {
    print("DEBUG => _startFlashcardLearning 실행됨! setId: $setId");

    final List<Map<String, dynamic>> flashcards = [];
    final setDocRef = FirebaseFirestore.instance.collection('flashcard_sets').doc(setId);
    print("DEBUG => Firestore에서 해당 setId 문서를 찾는 중...");

    final itemsSnapshot = await setDocRef.collection('items').get();
    print("DEBUG => itemsSnapshot.docs.length: ${itemsSnapshot.docs.length}");

    for (var doc in itemsSnapshot.docs) {
      final data = doc.data();
      final content = data["content"] ?? {};

      print("DEBUG => raw Firestore data: $data");
      if (!data.containsKey("content")) {
        print("⚠️ content 키가 없음! 데이터를 확인하세요.");
        continue;
      }
      print("DEBUG => extracted content: $content");

      // 저장된 데이터 구조가 이미 일관되게 order 값을 부여하고 있다면 그대로 사용
      flashcards.add({
        "text": content["text"] ?? "[텍스트 없음]",
        "meaning": content["meaning"] ?? "[뜻 없음]",
        "order": content["order"] ?? data["order"] ?? 9999,
      });
    }

    // flashcards 리스트를 order 필드 기준 오름차순 정렬
    flashcards.sort((a, b) => (a["order"] as int).compareTo(b["order"] as int));

    print("DEBUG => flashcards (정렬 후): ${flashcards.map((card) => card["text"]).toList()}");

    if (flashcards.isEmpty) {
      print("⚠️ 플래시카드 데이터가 비어 있음! 학습 화면으로 이동하지 않음.");
      return;
    }

    print("✅ 플래시카드 학습 화면으로 이동!");

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
        builder: (context) =>
            AlertDialog(
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
        await TrashManager.moveItemsToTrash(
          context: context,
          docIds: selectedIds.toList(),
          originalCollection: 'flashcard_sets',
          trashCollection: 'trash',
          itemType: 'flashcard_set',
        );

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
            AppIconButton(
              icon: isSelectionMode ? Icons.cancel : Icons.checklist,
              // ✅ 체크리스트 버튼
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

            return Column(
              children: [
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
                    onLearn: () {
                      if (selectedIds.isNotEmpty) {
                        for (var setId in selectedIds) {
                          _startFlashcardLearning(
                              setId); // ✅ 선택된 모든 세트를 학습하도록 변경
                        }
                      }
                    },
                  ),

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
                              ? "${(createdAt as Timestamp)
                              .toDate()
                              .toLocal()} 생성"
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
                              ? "${(createdAt as Timestamp)
                              .toDate()
                              .toLocal()} 생성"
                              : "날짜 없음"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIconButton(
                                icon: Icons.video_library, // ✅ 체크리스트 버튼
                                onPressed: () {
                                  print("DEBUG => 학습 버튼 클릭됨! setId: $docId");
                                  _startFlashcardLearning(docId);
                                },
                              ),
                              const SizedBox(width: 8),
                              AppIconButton(
                                icon: Icons.edit, // ✏️ 편집 버튼
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          FlashcardSetEditScreen(setId: docId),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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
