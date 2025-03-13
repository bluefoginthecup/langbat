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
              _clearCart(); // ✅ 장바구니 비우기 함수 실행
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
                          _removeFromCart(doc.id); // ✅ 개별 항목 삭제
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
                    await _createFlashcardSetFromCart(context); // ✅ 서브카드 생성 후 세트 저장
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ✅ 개별 아이템 삭제 함수
  void _removeFromCart(String docId) async {
    await FirebaseFirestore.instance.collection('cart').doc(docId).delete();
  }

  /// ✅ 장바구니 비우기 함수
  void _clearCart() async {
    final cartSnapshot = await FirebaseFirestore.instance.collection('cart').get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// ✅ 서브카드 생성 후 플래시카드 세트로 저장
  Future<void> _createFlashcardSetFromCart(BuildContext context) async {
    final newSetRef = FirebaseFirestore.instance.collection('flashcard_sets').doc();
    final cartItemsSnapshot = await FirebaseFirestore.instance.collection('cart').get();
    WriteBatch batch = FirebaseFirestore.instance.batch();

    int order = 0;
    for (var doc in cartItemsSnapshot.docs) {
      final docData = doc.data();
      final subcards = buildSubcardsFromVerb(docData["data"]); // ✅ 서브카드 생성

      for (var subcard in subcards) {
        batch.set(newSetRef.collection('items').doc(), {
          "content": subcard,
          "type": docData["type"],
          "order": order++,
          "addedAt": FieldValue.serverTimestamp(),
        });
      }
    }

    batch.set(newSetRef, {
      "name": "새 플래시카드 세트",
      "createdAt": FieldValue.serverTimestamp(),
    });

    await batch.commit();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardSetEditScreen(setId: newSetRef.id),
      ),
    );
  }

  /// ✅ 서브카드 생성 함수 (시제 변형, 예문 포함)
  List<Map<String, String>> buildSubcardsFromVerb(Map<String, dynamic> verbData) {
    List<Map<String, String>> subcards = [];

    // 🔹 동사 원형 카드 추가
    final verbText = verbData["text"] ?? "";
    final verbMeaning = verbData["meaning"] ?? "";
    if (verbText.isNotEmpty || verbMeaning.isNotEmpty) {
      subcards.add({
        "text": verbText,
        "meaning": verbMeaning,
      });
    }

    // 🔹 시제별 변형 카드 추가
    final conjugations = verbData["conjugations"] as Map<String, dynamic>?;
    if (conjugations != null) {
      conjugations.forEach((tense, forms) {
        final conjugationString = _mapToString(forms);
        subcards.add({
          "text": "$tense 시제",
          "meaning": conjugationString,
        });
      });
    }

    // 🔹 예문 추가
    final examples = verbData["examples"] as Map<String, dynamic>?;
    if (examples != null) {
      examples.forEach((level, sentence) {
        subcards.add({
          "text": "예문($level)",
          "meaning": sentence,
        });
      });
    }

    return subcards;
  }

  /// ✅ 시제 변형을 문자열로 변환
  String _mapToString(Map<String, dynamic> conjMap) {
    List<String> parts = [];
    conjMap.forEach((pronoun, form) {
      parts.add("$pronoun: $form");
    });
    return parts.join(", ");
  }

  /// ✅ 타입별 아이콘 반환
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
