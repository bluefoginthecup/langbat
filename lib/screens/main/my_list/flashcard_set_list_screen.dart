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
  const FlashcardSetListScreen({Key? key}) : super(key: key);

  @override
  _FlashcardSetListScreenState createState() => _FlashcardSetListScreenState();
}

class _FlashcardSetListScreenState extends ConsumerState<FlashcardSetListScreen> {
  Future<void> _startFlashcardLearning(String setId) async {
    print("DEBUG => _startFlashcardLearning 실행됨! setId: $setId");

    final List<Map<String, String>> flashcards = [];

    final setDocRef = FirebaseFirestore.instance
        .collection('flashcard_sets')
        .doc(setId);
    print("DEBUG => Firestore에서 해당 setId 문서를 찾는 중...");

    final itemsSnapshot = await setDocRef.collection('items').get();

    print("DEBUG => itemsSnapshot.docs.length: ${itemsSnapshot.docs.length}"); // ✅ 몇 개의 아이템을 불러오는지 확인

    for (var doc in itemsSnapshot.docs) { // ✅ 여기서 setId를 중복 선언하지 않도록 수정
      final data = doc.data();
      final content = data["content"] ?? {};

      print("DEBUG => raw Firestore data: $data"); // ✅ Firestore에서 가져온 원본 데이터 출력

      if (!data.containsKey("content")) {
        print("⚠️ content 키가 없음! 데이터를 확인하세요.");
        continue; // content 키가 없으면 추가하지 않음
      }

      print("DEBUG => extracted content: $content"); // ✅ content 키 안의 데이터 확인

      flashcards.add({
        "text": content["text"] ?? "[텍스트 없음]",
        "meaning": content["meaning"] ?? "[뜻 없음]",
      });
    }

    print("DEBUG => flashcards: $flashcards"); // ✅ 최종적으로 생성된 flashcards 리스트 확인

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
