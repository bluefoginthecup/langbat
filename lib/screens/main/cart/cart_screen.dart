import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../study/flashcard/flashcard_set_edit_screen.dart';
import '/models/node_model.dart'; // Node 및 NodeType을 가져옵니다.

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

/// Firestore 문서 하나를 Node로 만드는 함수 (하위 컬렉션까지 재귀적으로 읽음)

Future<Node> buildNodeFromDocument(DocumentSnapshot docSnap) async {
  final raw = docSnap.data() as Map<String, dynamic>? ?? {};

  // 최상위 필드에서 name/type 꺼내기 (한 단계 위 구조 반영)
  String name = raw['name']?.toString() ?? docSnap.id;
  NodeType type = (raw['type']?.toString() == 'data')
      ? NodeType.data
      : NodeType.category;

  // 뜻(meaning)만 data 맵에서 꺼냄
  final dataMap = raw['data'] as Map<String, dynamic>? ?? {};
  final node = Node(
    name: name,
    type: type,
    data: {"뜻": dataMap['뜻']?.toString() ?? ""},
    children: [],
  );

  final childrenSnap = await docSnap.reference.collection('children').get();
  for (final child in childrenSnap.docs) {
    node.children.add(await buildNodeFromDocument(child));
  }
  return node;
}

/// Node 트리 → 평탄화 리스트 (플래시카드)
List<Map<String, dynamic>> flattenCustomList(Node node) {
  final cards = <Map<String, dynamic>>[];

  // Leaf 노드거나 category지만 자식이 없는 경우 카드 추가
  if (node.type == NodeType.data || (node.children.isEmpty && node.name.isNotEmpty)) {
    cards.add({
      "text": node.name,
      "meaning": node.data["뜻"] ?? "",
      "order": 0,
    });
  }

  for (var child in node.children) {
    cards.addAll(flattenCustomList(child));
  }
  print("Node '${node.name}' 평탄화 결과: $cards");
  return cards;
}
class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  /// lists 컬렉션에서 특정 문서를 cart에 추가 (참조만)
  Future<void> addListToCart(String listDocId) async {
    await FirebaseFirestore.instance.collection('cart').add({
      "type": "custom",
      "originalId": listDocId,
      "addedAt": FieldValue.serverTimestamp(),
    });
  }

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
            // 저장 버튼 추가: custom list를 Firestore에 저장
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: "Custom List 저장",
              onPressed: () async {
                await _saveCustomListsToFirestore();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Custom List 저장 완료")),
                );
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
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final type = data["type"] ?? "unknown";

                // "custom"인 경우, listDocId로 lists 문서 참조
                String displayText;
                if (type == "custom") {
                  final originalId = data["originalId"] ?? "???";
                  displayText = "참조 문서: $originalId";
                } else {
                  // verb 등 다른 타입
                  final content = data["data"] ?? {};
                  displayText = content["text"] ??
                      content["word"] ??
                      content["sentence"] ??
                      "이름 없음";
                }
                return ListTile(
                  leading: Icon(_getIcon(type)),
                  title: Text(displayText),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _removeFromCart(doc.id);
                    },
                  ),
                );
              },
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
      print("카트 문서: ${doc.id}, type: $type");

      List<Map<String, dynamic>> subcards = [];

      if (type == "verb") {
        // 기존 동사 리스트 처리
        subcards = buildSubcardsFromVerb(docData["data"]);
      } else if (type == "custom") {
        final listDocId = docData["originalId"];
        if (listDocId == null) {
          print("ERROR: custom 문서인데 originalId가 없음");
          continue;
        }
        final listDocSnap = await FirebaseFirestore.instance
            .collection('lists')
            .doc(listDocId)
            .get();
        if (!listDocSnap.exists) {
          print("ERROR: lists/$listDocId 문서가 존재하지 않음");
          continue;
        }
        // 원본 lists 문서를 Node로 변환
        final customNode = await buildNodeFromDocument(listDocSnap);
        subcards = flattenCustomList(customNode);
      }

      // subcards 정렬
      subcards.sort((a, b) => (a["order"] as int).compareTo(b["order"] as int));

      // 각 subcard를 flashcard 세트 items 하위 컬렉션에 저장
      for (var subcard in subcards) {
        final itemRef = newSetRef.collection('items').doc();
        batch.set(itemRef, {
          "content": subcard,
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

  /// custom 리스트들을 Firestore에 저장하는 함수
  Future<void> _saveCustomListsToFirestore() async {
    final cartSnapshot = await FirebaseFirestore.instance.collection('cart').get();
    for (var doc in cartSnapshot.docs) {
      final docData = doc.data();
      final type = docData["type"] ?? "unknown";
      if (type == "custom") {
        // custom 리스트에 대해 Node 트리 구성
        final customNode = await buildNodeFromDocument(doc);
        // 저장할 컬렉션 예시: "custom_lists" 컬렉션에 저장 (doc.id를 키로 사용)
        final customListRef = FirebaseFirestore.instance.collection('custom_lists').doc(doc.id);
        // 루트 노드 저장
        await customListRef.set({
          "data": {
            "name": customNode.name,
            "type": customNode.type == NodeType.data ? "data" : "category",
            "뜻": customNode.data["뜻"] ?? "",
          }
        });
        // 하위 노드 저장 (재귀 호출)
        await _saveNodeChildrenToFirestore(customNode, customListRef);
      }
    }
  }

  Future<void> _saveNodeChildrenToFirestore(Node node, DocumentReference parentRef) async {
    for (final child in node.children) {
      final childRef = parentRef.collection('children').doc();
      await childRef.set({
        "data": {
          "name": child.name,
          "type": child.type == NodeType.data ? "data" : "category",
          "뜻": child.data["뜻"] ?? "",
        }
      });
      // 재귀적으로 하위 children 저장
      await _saveNodeChildrenToFirestore(child, childRef);
    }
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
      case 'custom': // custom 타입에 대해 아이콘 지정
        return Icons.note;
      default:
        return Icons.help_outline;
    }
  }
}
