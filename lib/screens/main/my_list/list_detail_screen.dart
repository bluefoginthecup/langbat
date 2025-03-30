import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:langbat/models/node_model.dart'; // Node, NodeType 공통 파일
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart'; // XFile을 사용하기 위한 import

import 'package:langbat/services/template_service.dart'; // template_service.dart 에 nodeToJson, generateTemplateJson 함수 정의

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

    QuerySnapshot childrenSnap = await docRef
        .collection('children')
        .orderBy('order')
        .get();
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

    QuerySnapshot childrenSnap = await docRef
        .collection('children')
        .orderBy('order')
        .get();
    for (var childDoc in childrenSnap.docs) {
      Node childNode = await _fetchChildNode(childDoc.reference);
      node.children.add(childNode);
    }
    return node;
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

  Future<void> _saveAllChanges(Node node, DocumentReference docRef) async {
    await docRef.set({
      "name": node.name,
      "type": node.type == NodeType.data ? "data" : "category",
      "data": node.data,
    }, SetOptions(merge: true));

    for (var child in node.children) {
      if (child.docId == null) {
        final newChildDoc = await docRef.collection('children').add({
          "name": child.name,
          "type": child.type == NodeType.data ? "data" : "category",
          "data": child.data,
        });
        child.docId = newChildDoc.id;
      } else {
        DocumentReference childRef =
        docRef.collection('children').doc(child.docId);
        await _saveAllChanges(child, childRef);
      }
    }
  }

  /// 템플릿 다운로드 함수 (template_service.dart의 generateTemplateJson 사용)
  Future<void> _downloadTemplate(BuildContext context) async {
    try {
      Node currentNode = await _futureNode;
      // Node 전체 구조를 JSON 문자열로 변환
      String jsonString = generateTemplateJson(currentNode);

    // 콘솔에 JSON 문자열 출력
    print("생성된 템플릿 JSON: $jsonString");

    // RenderBox로 팝오버 위치 계산
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      throw Exception("RenderBox를 찾을 수 없습니다.");
    }
    final rect = box.localToGlobal(Offset.zero) & box.size;

      // 앱의 문서 디렉토리 경로 가져오기 및 파일 저장
      final appDocDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDocDir.path}/template.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // shareXFiles를 사용해 파일 공유 (iPad 팝오버 위치 지정)
      await Share.shareXFiles(
        [XFile(filePath)],
        text: '실제 구조를 반영한 템플릿 JSON 파일입니다.',
        sharePositionOrigin: rect,
      );

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("템플릿 파일이 저장 및 공유되었습니다.")));
    } catch (e, stacktrace) {
      print('템플릿 생성 중 오류: $e');
      print(stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("템플릿 생성 실패: $e")));
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
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.file_download),
                tooltip: "템플릿 다운로드",
                onPressed: () => _downloadTemplate(context),
              );
            },
          )
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

/// NodeDetailWidget: 각 노드를 ExpansionTile로 표시하고, 탭하면 편집 모드로 전환
class NodeDetailWidget extends StatefulWidget {
  final Node node;
  final int indentLevel;
  final VoidCallback? onDelete;

  const NodeDetailWidget({
    super.key,
    required this.node,
    this.indentLevel = 0,
    this.onDelete,
  });

  @override
  _NodeDetailWidgetState createState() => _NodeDetailWidgetState();
}

class _NodeDetailWidgetState extends State<NodeDetailWidget> {
  bool isExpanded = false;
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

  /// 하위 노드 추가 다이얼로그
  void _addChildNode(BuildContext context, Node parent) {
    String childName = "";
    NodeType selectedType = NodeType.category;
    String additionalData = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("${parent.name}에 추가할 항목"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: "항목 이름"),
                    onChanged: (value) => childName = value,
                  ),
                  DropdownButton<NodeType>(
                    value: selectedType,
                    onChanged: (NodeType? newValue) {
                      setStateDialog(() {
                        selectedType = newValue!;
                      });
                    },
                    items: NodeType.values.map((NodeType type) {
                      return DropdownMenuItem<NodeType>(
                        value: type,
                        child: Text(type == NodeType.category ? "카테고리" : "데이터"),
                      );
                    }).toList(),
                  ),
                  if (selectedType == NodeType.data)
                    TextField(
                      decoration: InputDecoration(hintText: "뜻"),
                      onChanged: (value) => additionalData = value,
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (childName.trim().isNotEmpty) {
                      Node newNode = Node(
                        name: childName,
                        type: selectedType,
                        data: selectedType == NodeType.data
                            ? {"뜻": additionalData}
                            : {},
                      );

                      final parentRef = FirebaseFirestore.instance
                          .collection('lists')
                          .doc(parent.docId);
                      final childDoc = await parentRef.collection('children').add({
                        "name": newNode.name,
                        "type": newNode.type == NodeType.data ? "data" : "category",
                        "data": newNode.data,
                      });

                      newNode.docId = childDoc.id;

                      setState(() {
                        parent.children.add(newNode);
                      });

                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("추가"),
                ),
              ],
            );
          },
        );
      },
    );
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
        onExpansionChanged: (expanded) => setState(() => isExpanded = expanded),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add') _addChildNode(context, widget.node);
                if (value == 'edit') _toggleEditing();
                if (value == 'delete') widget.onDelete?.call();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'add', child: Text("하위 항목 추가")),
                PopupMenuItem(value: 'edit', child: Text("편집")),
                PopupMenuItem(value: 'delete', child: Text("삭제")),
              ],
            ),
            Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          ],
        ),
        children: widget.node.children
            .map((child) =>
            NodeDetailWidget(node: child, indentLevel: widget.indentLevel + 1))
            .toList(),
      ),
    );
  }
}
