import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langarden_common/providers/multi_select_controller.dart';
import 'package:langarden_common/widgets/multi_select_actions.dart';

import '../study/flashcard/flashcard_set_edit_screen.dart';
import 'package:langarden_common/utils/trash_manager.dart';
import '../study/flashcard/flashcard_study_screen.dart';
import 'package:langarden_common/widgets/icon_button.dart'; // ✅ 툴팁 적용된 아이콘 버튼 불러오기
import 'package:firebase_auth/firebase_auth.dart';


class FlashcardSetListScreen extends ConsumerStatefulWidget {
  const FlashcardSetListScreen({super.key});

  @override
  _FlashcardSetListScreenState createState() => _FlashcardSetListScreenState();
}

class _FlashcardSetListScreenState extends ConsumerState<FlashcardSetListScreen> {
  Future<void> _startFlashcardLearning(String setId) async {
    print("DEBUG => _startFlashcardLearning 실행됨! setId: $setId");

    final uid = FirebaseAuth.instance.currentUser!.uid; // ✅ uid 확보
    final List<Map<String, dynamic>> flashcards = [];

    final setDocRef = FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('flashcard_sets').doc(setId);

    print("DEBUG => Firestore에서 해당 setId 문서를 찾는 중...");

    final itemsSnapshot = await setDocRef.collection('items').get();
    print("DEBUG => itemsSnapshot.docs.length: ${itemsSnapshot.docs.length}");

    // ✅ 단일 이미지 필드(imageUrl) 기준으로 구성 (중복 루프 제거)
    for (var doc in itemsSnapshot.docs) {
      final data = doc.data();
      final content = data["content"] ?? {};

      // 단일 이미지 URL(우선순위: content.imageUrl → 과거 front/back → 상위 레벨)
      final imageUrl = (content["imageUrl"]
          ?? content["imageFrontUrl"]
          ?? content["imageBackUrl"]
          ?? data["imageUrl"]
          ?? "") as String;

      flashcards.add({
        "text": content["text"] ?? "[텍스트 없음]",   // 앞면
        "meaning": content["meaning"] ?? "[뜻 없음]", // 뒷면
        "order": content["order"] ?? data["order"] ?? 9999,
        "imageUrl": imageUrl,                         // ✅ 단일 이미지
      });
    }

    // order 정렬
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
      final uid = FirebaseAuth.instance.currentUser?.uid;

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
          body: Builder(
          builder: (context) {
        final uid = FirebaseAuth.instance.currentUser!.uid; // ✅ 로그인 보장 가정

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('flashcard_sets')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint("🔥 flashcard_sets stream error: ${snapshot.error}");
              debugPrint("Stack: ${snapshot.stackTrace}");
              return Center(child: Text("오류: ${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(child: Text('세트가 없습니다.'));
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
      );
    }
      )
        );}
}
