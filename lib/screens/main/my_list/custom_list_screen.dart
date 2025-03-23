// lib/screens/main/my_list/custom_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:langbat/models/node_model.dart'; // 공통 Node, NodeType 사용
import 'list_detail_screen.dart'; // 상세 화면
import 'make_list_screen.dart';   // 새 리스트 생성 화면
import 'package:langarden_common/widgets/multi_select_actions.dart'; // 멀티 선택 액션 위젯 (구현된 경우)

class CustomListScreen extends StatefulWidget {
  const CustomListScreen({super.key});

  @override
  _CustomListScreenState createState() => _CustomListScreenState();
}

class _CustomListScreenState extends State<CustomListScreen> {
  bool multiSelectMode = false;
  final Set<String> selectedIds = {};

  void toggleMultiSelect() {
    setState(() {
      multiSelectMode = !multiSelectMode;
      if (!multiSelectMode) selectedIds.clear();
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

  Future<void> addSelectedToCart() async {
    final cartRef = FirebaseFirestore.instance.collection('cart');
    final listsRef = FirebaseFirestore.instance.collection('lists');

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var docId in selectedIds) {
        final docSnapshot = await listsRef.doc(docId).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          batch.set(cartRef.doc(docId), {
            "type": "custom",
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

  void _navigateToMakeList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MakeListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("커스텀 리스트"),
        actions: [
          // 우측 + 아이콘: 새 리스트 생성 화면(MakeListScreen)으로 연결
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "새 리스트 생성",
            onPressed: () => _navigateToMakeList(context),
          ),
          // 멀티 선택 토글 버튼
          IconButton(
            icon: Icon(multiSelectMode ? Icons.cancel : Icons.checklist),
            tooltip: multiSelectMode ? "멀티 선택 해제" : "멀티 선택 모드",
            onPressed: toggleMultiSelect,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('lists').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("오류: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("저장된 리스트가 없습니다."));
          }
          return Column(
            children: [
              if (multiSelectMode)
                MultiSelectActions(
                  allSelected: selectedIds.length == docs.length,
                  onToggleSelectAll: () => toggleSelectAll(docs),
                  onTrash: () {}, // 필요 시 구현 (예: 휴지통 이동)
                  onCart: addSelectedToCart,
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final node = Node(
                      name: data['name'] ?? '',
                      type: data['type'] == 'data' ? NodeType.data : NodeType.category,
                      data: (data['data'] as Map?)?.cast<String, String>() ?? {},
                      children: [],
                    );
                    if (multiSelectMode) {
                      return CheckboxListTile(
                        title: Text(node.name),
                        subtitle: node.type == NodeType.data
                            ? Text("뜻: ${node.data['뜻'] ?? ''}")
                            : null,
                        value: selectedIds.contains(doc.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedIds.add(doc.id);
                            } else {
                              selectedIds.remove(doc.id);
                            }
                          });
                        },
                      );
                    } else {
                      return ListTile(
                        title: Text(node.name),
                        subtitle: node.type == NodeType.data
                            ? Text("뜻: ${node.data['뜻'] ?? ''}")
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListDetailScreen(
                                node: node,
                                docId: doc.id,
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
