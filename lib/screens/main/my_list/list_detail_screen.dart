import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:langbat/models/node_model.dart'; // Node, NodeType 공통 파일

class ListDetailScreen extends StatefulWidget {
  final Node node; // 초기 데이터(참고용)
  final String docId; // 최상위 리스트 문서 ID

  const ListDetailScreen({super.key, required this.node, required this.docId});

  @override
  _ListDetailScreenState createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  late Future<Node> _futureNode;

  @override
  void initState() {
    super.initState();
    _futureNode = _fetchNodeWithChildren(widget.docId);
  }

  // Firestore에서 최상위 문서와 하위 children 서브컬렉션을 재귀적으로 로드
  Future<Node> _fetchNodeWithChildren(String docId) async {
    DocumentReference docRef =
    FirebaseFirestore.instance.collection('lists').doc(docId);
    DocumentSnapshot docSnap = await docRef.get();
    Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;

    Node fetchedNode = Node(
      name: data['name'] ?? '',
      type: data['type'] == 'data' ? NodeType.data : NodeType.category,
      data: (data['data'] as Map?)?.cast<String, String>() ?? {},
      children: [],
      docId: docSnap.id,
    );

    QuerySnapshot childrenSnap = await docRef.collection('children').get();
    for (var childDoc in childrenSnap.docs) {
      Node childNode = await _fetchChildNode(childDoc.reference);
      fetchedNode.children.add(childNode);
    }
    return fetchedNode;
  }

  Future<Node> _fetchChildNode(DocumentReference docRef) async {
    DocumentSnapshot docSnap = await docRef.get();
    Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
    Node node = Node(
      name: data['name'] ?? '',
      type: data['type'] == 'data' ? NodeType.data : NodeType.category,
      data: (data['data'] as Map?)?.cast<String, String>() ?? {},
      children: [],
      docId: docSnap.id,
    );

    QuerySnapshot childrenSnap = await docRef.collection('children').get();
    for (var childDoc in childrenSnap.docs) {
      Node childNode = await _fetchChildNode(childDoc.reference);
      node.children.add(childNode);
    }
    return node;
  }

  // 재귀적으로 전체 노드 트리의 변경사항을 Firestore에 업데이트
  Future<void> _saveAllChanges(Node node, DocumentReference docRef) async {
    await docRef.update({
      'name': node.name,
      'data': node.data,
    });
    for (var child in node.children) {
      DocumentReference childRef = docRef.collection('children').doc(child.docId);
      await _saveAllChanges(child, childRef);
    }
  }

  // AppBar의 글로벌 저장 아이콘을 누르면 전체 변경사항을 Firestore에 업데이트
  Future<void> _globalSave() async {
    try {
      DocumentReference topRef =
      FirebaseFirestore.instance.collection('lists').doc(widget.docId);
      Node currentNode = await _futureNode;
      await _saveAllChanges(currentNode, topRef);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("저장 완료")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("저장 실패: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Node>(
          future: _futureNode,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.name);
            }
            return Text("리스트");
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: "저장",
            onPressed: _globalSave,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "새로고침",
            onPressed: () {
              setState(() {
                _futureNode = _fetchNodeWithChildren(widget.docId);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Node>(
        future: _futureNode,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("오류: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return Center(child: Text("데이터가 없습니다."));
          }
          Node fullNode = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: NodeDetailWidget(node: fullNode),
          );
        },
      ),
    );
  }
}

/// NodeDetailWidget: 각 노드를 ExpansionTile으로 표시하고, 탭하면 편집 모드로 전환되어 TextField가 나타남.
/// 개별 저장 버튼은 제거하고, TextField의 onEditingComplete 이벤트로 편집 모드를 종료함.
class NodeDetailWidget extends StatefulWidget {
  final Node node;
  final int indentLevel;

  const NodeDetailWidget({super.key, required this.node, this.indentLevel = 0});

  @override
  _NodeDetailWidgetState createState() => _NodeDetailWidgetState();
}

class _NodeDetailWidgetState extends State<NodeDetailWidget> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _meaningController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.node.name);
    _meaningController = TextEditingController(
      text: widget.node.type == NodeType.data ? widget.node.data["뜻"] ?? "" : "",
    );
  }

  @override
  void didUpdateWidget(covariant NodeDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _nameController.text = widget.node.name;
    if (widget.node.type == NodeType.data) {
      _meaningController.text = widget.node.data["뜻"] ?? "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: widget.indentLevel * 16.0),
      child: ExpansionTile(
        title: _isEditing
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "이름"),
              onChanged: (value) {
                setState(() {
                  widget.node.name = value;
                });
              },
              onEditingComplete: () {
                setState(() {
                  _isEditing = false;
                });
              },
            ),
            if (widget.node.type == NodeType.data)
              TextField(
                controller: _meaningController,
                decoration: InputDecoration(labelText: "뜻"),
                onChanged: (value) {
                  setState(() {
                    widget.node.data["뜻"] = value;
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
              ),
          ],
        )
            : GestureDetector(
          onTap: _toggleEditing,
          child: Text(
            widget.node.type == NodeType.data
                ? "${widget.node.name} - 뜻: ${widget.node.data['뜻'] ?? ''}"
                : widget.node.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        children: widget.node.children
            .map((child) => NodeDetailWidget(
          node: child,
          indentLevel: widget.indentLevel + 1,
        ))
            .toList(),
      ),
    );
  }
}
