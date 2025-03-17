import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../study/flashcard/flashcard_set_edit_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 화면 탭 시 키보드 해제
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("장바구니"),
          actions: [
            // 플래시카드 세트로 만들기 버튼 (휴지통 비우기 옆에)
            IconButton(
              icon: const Icon(Icons.flash_on),
              tooltip: "플래시카드 세트로 만들기",
              onPressed: () async {
                await _createFlashcardSetFromCart(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: "장바구니 비우기",
              onPressed: () {
                _clearCart(); // 장바구니 비우기 함수 실행
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
                      final displayText = content["text"] ?? content["word"] ?? content["sentence"] ?? "";
                      return ListTile(
                        leading: Icon(_getIcon(type)),
                        title: Text(displayText),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _removeFromCart(doc.id); // 개별 항목 삭제
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 개별 아이템 삭제 함수
  void _removeFromCart(String docId) async {
    await FirebaseFirestore.instance.collection('cart').doc(docId).delete();
  }

  /// 장바구니 비우기 함수
  void _clearCart() async {
    final cartSnapshot = await FirebaseFirestore.instance.collection('cart').get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// 서브카드 생성 후 플래시카드 세트로 저장
  Future<void> _createFlashcardSetFromCart(BuildContext context) async {
    // 새로운 flashcard 세트를 위한 문서 생성
    final newSetRef = FirebaseFirestore.instance.collection('flashcard_sets').doc();
    final cartItemsSnapshot = await FirebaseFirestore.instance.collection('cart').get();
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // 각 cart item마다, 동사 데이터를 가공하여 subcard 리스트 생성
    for (var doc in cartItemsSnapshot.docs) {
      final docData = doc.data();
      // verb 데이터는 docData["data"]에 저장되어 있다고 가정합니다.
      final subcards = buildSubcardsFromVerb(docData["data"]);
      // subcards 리스트를 order 값 기준으로 정렬합니다.
      subcards.sort((a, b) => (a["order"] as int).compareTo(b["order"] as int));

      // 각 subcard를 flashcard 세트의 하위 컬렉션 "items"에 저장
      for (var subcard in subcards) {
        final itemRef = newSetRef.collection('items').doc();
        batch.set(itemRef, {
          "content": subcard,            // subcard 구조 (text, meaning, order)
          "type": docData["type"],       // 예를 들어 "verb" 등
          "order": subcard["order"],     // 미리 지정된 order 값 사용
          "addedAt": FieldValue.serverTimestamp(),
        });
      }
    }

    // 세트 메타데이터 저장 (세트 이름 등)
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


  /// 서브카드 생성 함수 (동사 원형, 시제 변형, 예문 포함)
  /// 새 데이터 구조에서, 각 시제별 동사 변형 카드에 order 값을 미리 지정합니다.
    List<Map<String, dynamic>> buildSubcardsFromVerb(Map<String, dynamic> verbData) {
      List<Map<String, dynamic>> subcards = [];

      // 기본 카드: 동사 원형과 뜻 (order: -1)
      final verbText = verbData["text"] ?? "";
      final verbMeaning = verbData["meaning"] ?? "";
      if (verbText.isNotEmpty || verbMeaning.isNotEmpty) {
        subcards.add({
          "text": verbText,
          "meaning": verbMeaning,
          "order": -1,
        });
      }

      // 시제별 동사 변형 카드
      final conjugations = verbData["conjugations"] as Map<String, dynamic>?;
      if (conjugations != null) {
        List<Map<String, dynamic>> conjugationCards = [];
        conjugations.forEach((tense, data) {
          if (data is Map<String, dynamic>) {
            final formsData = data["forms"] as Map<String, dynamic>? ?? {};
            final List<String> orderList = ["yo", "tú", "él/ella/Ud", "nosotros", "vosotros", "ellos/ellas/Uds"];
            String formsString = orderList.map((key) => formsData[key] ?? "").join(", ");
            conjugationCards.add({
              "text": formsString,
              "meaning": "${capitalize(tense)} 시제",
              "order": data["order"] ?? 9999,
            });
          }
        });
        conjugationCards.sort((a, b) => (a["order"] as int).compareTo(b["order"] as int));
        subcards.addAll(conjugationCards);
      }

      // 예문 카드: 예문 하나 = 하나의 subcard
      final examples = verbData["examples"] as Map<String, dynamic>?;
      if (examples != null) {
        examples.forEach((level, exData) {
          int levelOrder;
          switch (level.toLowerCase()) {
            case "beginner":
              levelOrder = 100;
              break;
            case "intermediate":
              levelOrder = 200;
              break;
            case "advanced":
              levelOrder = 300;
              break;
            default:
              levelOrder = 999;
          }
          if (exData is Map<String, dynamic>) {
            // exData["items"]가 예문 배열
            final items = exData["items"] as List<dynamic>? ?? [];
            for (var ex in items) {
              if (ex is Map<String, dynamic>) {
                subcards.add({
                  "text": ex["text"] ?? "",
                  "meaning": ex["meaning"] ?? "",
                  "order": levelOrder,
                });
              }
            }
          }
        });
      }

      subcards.sort((a, b) => (a["order"] as int).compareTo(b["order"] as int));
      return subcards;
    }

  String capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : "";

  /// 타입별 아이콘 반환
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
