// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../study/flashcard/flashcard_set_edit_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("장바구니"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "장바구니 비우기",
            onPressed: () {
              // 장바구니 비우기 로직 구현 필요
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("오류: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("장바구니가 비었습니다."));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final type = data["type"] ?? "unknown";
                    final content = data["data"];
                    final displayText = content["verb"] ?? content["word"] ?? content["sentence"] ?? "";

                    return ListTile(
                      leading: Icon(_getIcon(type)),
                      title: Text(displayText),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // 장바구니에서 개별 항목 삭제 로직 구현 필요
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
          icon: const Icon(Icons.flash_on),
          label: const Text("플래시카드 세트로 만들기"),
          onPressed: () async {
          // 1) 먼저 Firebase에 새로운 세트 문서를 만들고 ID 생성하기
          final newSetRef = FirebaseFirestore.instance.collection('flashcard_sets').doc();

          // 2) 현재 장바구니의 항목들을 새 세트에 복사해 넣기
          final cartItemsSnapshot = await FirebaseFirestore.instance.collection('cart').get();
          WriteBatch batch = FirebaseFirestore.instance.batch();

          int order = 0;
          for (var doc in cartItemsSnapshot.docs) {
          batch.set(newSetRef.collection('items').doc(doc.id), {
          "content": doc['data'],
          "type": doc['type'],
          "order": order++,
          "addedAt": FieldValue.serverTimestamp(),
          });
          }

          // 세트 기본 정보 저장 (이름은 빈 값으로 일단 초기화)
          batch.set(newSetRef, {
          "name": "새 플래시카드 세트",
          "createdAt": FieldValue.serverTimestamp(),
          });

          await batch.commit();

          // 3) 생성한 세트의 편집 화면으로 이동
          Navigator.push(
          context,
          MaterialPageRoute(
          builder: (_) => FlashcardSetEditScreen(setId: newSetRef.id),
          ),
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

  IconData _getIcon(String type) {
    switch (type) {
      case 'verb':
        return Icons.playlist_add_check;
      case 'word':
        return Icons.text_fields;
      case 'sentence':
        return Icons.subject;
      default:
        return Icons.help_outline;
    }
  }
}
