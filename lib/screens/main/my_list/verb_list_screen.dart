// lib/screens/my_list/verb_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:langbat/screens/main/input/verb_detail_input_screen.dart'; // 실제 파일 경로에 맞게 수정하세요

class VerbListScreen extends StatelessWidget {
  const VerbListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("동사리스트"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('verbs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("오류: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("저장된 동사가 없습니다."));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final verb = data["verb"] ?? "";
              final meaning = data["meaning"] ?? "";
              return ListTile(
                title: Text(verb),
                subtitle: Text(meaning),
                onTap: () {
                  // 동사 상세 정보를 확인하거나 수정하는 페이지로 전환하는 코드 추가 가능
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VerbDetailInputScreen(
                            verb: verb,
                            meaning: meaning,
                          ),
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
