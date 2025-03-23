import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../study/flashcard/flashcard_set_edit_screen.dart';

/// 커스텀 리스트를 평탄화하는 함수
List<Map<String, dynamic>> flattenCustomList(Node node) {
  List<Map<String, dynamic>> cards = [];
  // 노드 타입이 데이터라면 플래시카드 항목으로 변환 (여기서는 노드의 이름과 data["뜻"] 사용)
  if (node.type == NodeType.data) {
    cards.add({
      "text": node.name,
      "meaning": node.data["뜻"] ?? "",
      "order": 0, // 필요에 따라 순서를 지정
    });
  }
  // 자식 노드가 있다면 재귀적으로 평탄화 처리
  for (var child in node.children) {
    cards.addAll(flattenCustomList(child));
  }
  // 로그 출력: 해당 노드의 평탄화 결과 확인
  print("Node '${node.name}' 평탄화 결과: $cards");
  return cards;
}

/// 기존 동사 리스트의 subcard 생성 함수
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

/// 임시로 Node와 NodeType 클래스를 정의 (실제로는 공통 모델 파일로 분리해야 함)
enum NodeType { category, data }

class Node {
  String name;
  NodeType type;
  Map<String, String> data;
  List<Node> children;
  // Firestore 업데이트 시 사용
  String? docId;

  Node({
    required this.name,
    this.type = NodeType.category,
    Map<String, String>? data,
    List<Node>? children,
    this.docId,
  }) : data = data ?? {},
        children = children ?? [];
}

/// Firestore 문서 하나를 Node로 만드는 함수 (하위 컬렉션까지 재귀적으로 읽음)
Future<Node> buildNodeFromDocument(DocumentSnapshot docSnap) async {
  final docData = docSnap.data() as Map<String, dynamic>? ?? {};
  final node = Node(
    name: docData["data"]?["name"] ?? "",
    type: (docData["data"]?["type"] == 'data') ? NodeType.data : NodeType.category,
    data: (docData["data"] as Map?)?.cast<String, String>() ?? {},
    children: [],
  );

  // 하위 컬렉션 'children' 읽기
  final childrenSnapshot = await docSnap.reference.collection('children').get();
  for (final childDoc in childrenSnapshot.docs) {
    final childNode = await buildNodeFromDocument(childDoc);
    node.children.add(childNode);
  }

  return node;
}

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
            // 플래시카드 세트로 만들기 버튼
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
                      final displayText = type == "custom"
                          ? (content["name"] ?? "")
                          : (content["text"] ?? content["word"] ?? content["sentence"] ?? "");
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

    // 각 cart item마다 처리
    for (var doc in cartItemsSnapshot.docs) {
      final docData = doc.data();
      print("전체 docData: $docData");  // 전체 데이터를 출력
      final type = docData["type"] ?? "unknown";
      print("docData['type']: $type");  // type 필드 값을 출력

      List<Map<String, dynamic>> subcards = [];

      if (type == "verb") {
        // 기존 동사 리스트 처리
        subcards = buildSubcardsFromVerb(docData["data"]);
      } else if (type == "custom") {
        // 커스텀 리스트 처리: 하위 컬렉션까지 읽어와서 Node 트리 구성
        final customNode = await buildNodeFromDocument(doc);
        print("customNode: ${customNode.name}, children count: ${customNode.children.length}");
        subcards = flattenCustomList(customNode);
      }
      // subcards 리스트를 order 값 기준 정렬
      subcards.sort((a, b) => (a["order"] as int).compareTo(b["order"] as int));

      // 각 subcard를 flashcard 세트의 하위 컬렉션 "items"에 저장
      for (var subcard in subcards) {
        final itemRef = newSetRef.collection('items').doc();
        batch.set(itemRef, {
          "content": subcard, // subcard 구조 (text, meaning, order)
          "type": docData["type"],
          "order": subcard["order"],
          "addedAt": FieldValue.serverTimestamp(),
        });
      }
    }

    // 세트 메타데이터 저장
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

  /// 타입별 아이콘 반환 함수
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
