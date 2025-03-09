import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../study/flashcard/flashcard_set_edit_screen.dart';
import 'package:langarden_common/providers/multi_select_controller.dart';
import 'package:langarden_common/widgets/multi_select_actions.dart';

class FlashcardSetListScreen extends StatelessWidget {
  const FlashcardSetListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 플래시카드 세트"),
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

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? '이름 없음';
              final createdAt = data['createdAt'] as Timestamp?;

              return ListTile(
                leading: const Icon(Icons.folder),
                title: Text(name),
                subtitle: Text(createdAt != null
                    ? "${createdAt.toDate().toLocal()} 생성"
                    : "날짜 없음"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FlashcardSetEditScreen(setId: doc.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
