// lib/screens/my_list/trash_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:langarden_common/widgets/multi_select_actions.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({Key? key}) : super(key: key);

  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  bool multiSelectMode = false;
  final Set<String> selectedIds = {};

  void toggleMultiSelect() {
    setState(() {
      multiSelectMode = !multiSelectMode;
      if (!multiSelectMode) {
        selectedIds.clear();
      }
    });
  }

  void toggleSelectAll(List<DocumentSnapshot> docs) {
    setState(() {
      if (selectedIds.length < docs.length) {
        selectedIds.clear();
        for (var doc in docs) {
          selectedIds.add(doc.id);
        }
      } else {
        selectedIds.clear();
      }
    });
  }

  Future<void> permanentlyDeleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("영구 삭제 확인"),
        content: const Text("선택한 항목들을 영구 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("삭제"),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      final trashRef = FirebaseFirestore.instance.collection('trash');
      for (var docId in selectedIds) {
        batch.delete(trashRef.doc(docId));
      }
      await batch.commit();
      setState(() {
        selectedIds.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("선택한 항목들이 영구 삭제되었습니다.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("영구 삭제 실패: $e")),
      );
    }
  }

  Future<void> restoreSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("복원 확인"),
        content: const Text("선택한 항목들을 복원하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("복원"),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      final trashRef = FirebaseFirestore.instance.collection('trash');
      for (var docId in selectedIds) {
        final docSnapshot = await trashRef.doc(docId).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          final type = data["type"] as String? ?? "unknown";
          final originalId = data["originalId"] as String? ?? "";
          final originalData = data["data"] as Map<String, dynamic>? ?? {};

          String originalCollection;
          switch (type) {
            case "verb":
              originalCollection = "verbs";
              break;
            case "sentence":
              originalCollection = "sentences";
              break;
            case "word":
              originalCollection = "words";
              break;
            case "flashcardSet":
              originalCollection = "flashcardSets";
              break;
            default:
              originalCollection = "others";
          }
          final originalRef = FirebaseFirestore.instance
              .collection(originalCollection)
              .doc(originalId);
          batch.set(originalRef, originalData);
          batch.delete(trashRef.doc(docId));
        }
      }
      await batch.commit();
      setState(() {
        selectedIds.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("선택한 항목들이 복원되었습니다.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("복원 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("휴지통"),
        actions: [
          IconButton(
            icon: Icon(multiSelectMode ? Icons.cancel : Icons.checklist),
            tooltip: multiSelectMode ? "멀티 선택 해제" : "멀티 선택 모드",
            onPressed: toggleMultiSelect,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('trash').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("오류: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("휴지통이 비어 있습니다."));
          }
          final docsCount = docs.length; // 여기서 전체 문서 수를 선언
          return Column(
            children: [
              // AppBar 대신 본문 상단에 전체 선택, 영구 삭제, 복원 버튼을 배치
              if (multiSelectMode)
                MultiSelectActions(
                  allSelected: selectedIds.length == docsCount,
                  onToggleSelectAll: () => toggleSelectAll(docs),
                  onTrash: permanentlyDeleteSelected, // 기본 함수 전달 (내부에서 확인 가능)
                  onRestore: restoreSelected,
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: docsCount,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final type = data["type"] ?? "unknown";
                    final title = data["data"]?["verb"] ??
                        data["data"]?["sentence"] ??
                        data["data"]?["word"] ??
                        "데이터";
                    final docId = doc.id;
                    final isSelected = selectedIds.contains(docId);
                    if (multiSelectMode) {
                      return CheckboxListTile(
                        title: Text("$title ($type)"),
                        subtitle: Text("삭제일: ${data['deletedAt'] != null ? (data['deletedAt'] as Timestamp).toDate().toString() : '정보 없음'}"),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedIds.add(docId);
                            } else {
                              selectedIds.remove(docId);
                            }
                          });
                        },
                      );
                    } else {
                      return ListTile(
                        title: Text("$title ($type)"),
                        subtitle: Text("삭제일: ${data['deletedAt'] != null ? (data['deletedAt'] as Timestamp).toDate().toString() : '정보 없음'}"),
                        onTap: () {
                          // 일반 모드에서는 항목 탭 시 추가 작업 수행
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
