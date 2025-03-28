// lib/screens/main/my_list/verb_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../input/verb_detail_input_screen.dart' show VerbDetailInputScreen;
import 'package:langarden_common/widgets/multi_select_actions.dart';
import 'package:langarden_common/utils/trash_manager.dart';

import '../cart/cart_screen.dart';


class VerbListScreen extends StatefulWidget {
  const VerbListScreen({super.key});

  @override
  _VerbListScreenState createState() => _VerbListScreenState();
}

class _VerbListScreenState extends State<VerbListScreen> {
  bool multiSelectMode = false; // 멀티 선택 모드 활성화 여부
  final Set<String> selectedIds = {}; // 선택된 동사의 문서 ID들을 저장

  // 멀티 선택 모드 토글 함수
  void toggleMultiSelect() {
    setState(() {
      multiSelectMode = !multiSelectMode;
      if (!multiSelectMode) {
        selectedIds.clear();
      }
    });
  }

  // 전체 선택 토글: docs 목록을 받아 전체 선택 혹은 해제
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

  // 선택된 동사들을 휴지통으로 보내는 함수 (기존 로직 사용)
  Future<void> sendSelectedToTrash() async {
    await TrashManager.moveItemsToTrash(
      context: context,
      docIds: selectedIds.toList(),
      originalCollection: 'verbs',
      trashCollection: 'trash',
      itemType: 'verb',
    );
    setState(() {
      selectedIds.clear();
      multiSelectMode = false;
    });
  }


  Future<void> addSelectedToCart() async {
    final cartRef = FirebaseFirestore.instance.collection('cart');
    final verbsRef = FirebaseFirestore.instance.collection('verbs');

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var docId in selectedIds) {
        final docSnapshot = await verbsRef.doc(docId).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          batch.set(cartRef.doc(docId), {
            "type": "verb",
            "originalId": docId,
            "data": data,
            "addedAt": FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      setState(() {
        selectedIds.clear();
        multiSelectMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("장바구니에 추가되었습니다.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("장바구니 추가 실패: $e")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("동사리스트"),
        actions: [ IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VerbDetailInputScreen()),
            );
          },
        ),
          IconButton(
            icon: Icon(multiSelectMode ? Icons.cancel : Icons.checklist),
            tooltip: multiSelectMode ? "멀티 선택 해제" : "멀티 선택 모드",
            onPressed: toggleMultiSelect,
          ),
            IconButton(
              icon: Icon(Icons.shopping_cart_checkout),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen()));
              },
            ),
        ],
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
          return Column(
            children: [
              // 멀티 선택 모드가 활성화되면 상단에 MultiSelectActions 위젯 추가
              if (multiSelectMode)
              MultiSelectActions(
                allSelected: selectedIds.length == docs.length,
                onToggleSelectAll: () => toggleSelectAll(docs),
                onTrash: selectedIds.isEmpty ? () {} : sendSelectedToTrash,
                onCart: addSelectedToCart,
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final text = data["text"] ?? "";
                    final meaning = data["meaning"] ?? "";
                    final docId = doc.id;
                    if (multiSelectMode) {
                      return CheckboxListTile(
                        title: Text(text),
                        subtitle: Text(meaning),
                        value: selectedIds.contains(docId),
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
                        title: Text(text),
                        subtitle: Text(meaning),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VerbDetailInputScreen(
                                text: text,
                                meaning: meaning,
                              ),
                            ),
                          );
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
