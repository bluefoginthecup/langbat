// lib/screens/main/my_list/custom_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:langbat/models/node_model.dart'; // 공통 Node, NodeType 사용
import 'list_detail_screen.dart'; // 상세 화면
import 'make_list_screen.dart'; // 새 리스트 생성 화면
import 'package:langarden_common/widgets/multi_select_actions.dart'; // 멀티 선택 액션 위젯 (구현된 경우)
import 'package:langarden_common/utils/trash_manager.dart';

/// 이 파일 안에 바로 경로 도우미를 정의 (외부 폴더/파일 불필요)
class _FireRefs {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  _FireRefs(this._db, this._auth);

  String get uid {
    final u = _auth.currentUser;
    if (u == null) {
      throw StateError('로그인이 필요합니다. (currentUser == null)');
    }
    return u.uid;
  }

  /// users/{uid}/<name>
  CollectionReference<Map<String, dynamic>> col(String name) =>
      _db.collection('users').doc(uid).collection(name);

  CollectionReference<Map<String, dynamic>> get lists => col('lists');
  CollectionReference<Map<String, dynamic>> get cart => col('cart');
  CollectionReference<Map<String, dynamic>> get trash => col('trash');
}

class CustomListScreen extends StatefulWidget {
  const CustomListScreen({super.key});

  @override
  _CustomListScreenState createState() => _CustomListScreenState();
}

class _CustomListScreenState extends State<CustomListScreen> {
  bool multiSelectMode = false;
  final Set<String> selectedIds = {};

  late final _FireRefs _refs =
      _FireRefs(FirebaseFirestore.instance, FirebaseAuth.instance);

  void toggleMultiSelect() {
    setState(() {
      multiSelectMode = !multiSelectMode;
      if (!multiSelectMode) selectedIds.clear();
    });
  }

  void toggleSelectAll(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    setState(() {
      if (selectedIds.length < docs.length) {
        selectedIds
          ..clear()
          ..addAll(docs.map((d) => d.id));
      } else {
        selectedIds.clear();
      }
    });
  }

  Future<void> addSelectedToCart() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('커스텀 리스트 장바구니는 로컬 저장 구조로 전환 중입니다.'),
      ),
    );
  }

  void _navigateToMakeList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MakeListScreen()),
    );
  }

  Future<void> sendSelectedToTrash() async {
    try {
      // TrashManager가 문자열 경로를 받아 .collection('users/uid/lists')처럼 쓰는 구조면 OK
      await TrashManager.moveItemsToTrash(
        context: context,
        docIds: selectedIds.toList(),
        originalCollection: 'users/${_refs.uid}/lists',
        trashCollection: 'users/${_refs.uid}/trash',
        itemType: 'custom',
      );
      if (!mounted) return;
      setState(() {
        selectedIds.clear();
        multiSelectMode = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('휴지통 이동 실패: $e')),
      );
    }
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // 기존 'lists' → users/{uid}/lists
        stream: _refs.lists.snapshots(),
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
                  onTrash: selectedIds.isEmpty ? () {} : sendSelectedToTrash,
                  onCart: addSelectedToCart,
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();

                    final node = Node(
                      name: (data['name'] ?? '').toString(),
                      type: data['type'] == 'data'
                          ? NodeType.data
                          : NodeType.category,
                      data:
                          (data['data'] as Map?)?.cast<String, String>() ?? {},
                      children: const [],
                    );

                    if (multiSelectMode) {
                      return CheckboxListTile(
                        title: Text(node.name.isEmpty ? '(제목 없음)' : node.name),
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
                        title: Text(node.name.isEmpty ? '(제목 없음)' : node.name),
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
