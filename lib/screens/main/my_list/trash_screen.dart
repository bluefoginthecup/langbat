// lib/screens/my_list/trash_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({Key? key}) : super(key: key);

  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  // 선택된 문서 ID들을 저장할 Set
  final Set<String> selectedIds = {};

  // 영구 삭제 함수 (확인 다이얼로그 포함)
  Future<void> _permanentlyDeleteSelected() async {
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
        final docRef = trashRef.doc(docId);
        batch.delete(docRef);
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
        SnackBar(content: Text("삭제 실패: $e")),
      );
    }
  }

  // 예를 들어, 복원 기능도 추가할 수 있습니다.
  // Future<void> _restoreSelected() async { ... }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("휴지통"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: selectedIds.isEmpty ? null : _permanentlyDeleteSelected,
          )
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
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              // 타입에 따라 제목을 정합니다.
              final type = data["type"] ?? "unknown";
              final title = data["data"]?["verb"] ??
                  data["data"]?["sentence"] ??
                  data["data"]?["word"] ??
                  "데이터";
              final docId = doc.id;
              final isSelected = selectedIds.contains(docId);
              return CheckboxListTile(
                title: Text("$title ($type)"),
                subtitle: Text(
                  "삭제일: ${data['deletedAt'] != null ? data['deletedAt'].toDate().toString() : '정보 없음'}",
                ),
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
            },
          );
        },
      ),
    );
  }
}
