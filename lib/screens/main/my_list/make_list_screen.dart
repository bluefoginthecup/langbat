import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:langbat/models/node_model.dart';

class MakeListScreen extends StatefulWidget {
  const MakeListScreen({super.key});

  @override
  _MakeListScreenState createState() => _MakeListScreenState();
}

class _MakeListScreenState extends State<MakeListScreen> {

Node _parseNode(Map<String, dynamic> json,
    [int defaultOrder = 0]) {
  List<dynamic> childrenJson =
      json['children'] as List<dynamic>? ?? [];
  List<Node> children = [];
  for (int i = 0; i < childrenJson.length; i++) {
    children.add(_parseNode(childrenJson[i] as Map<String, dynamic>, i));
  }
  return Node(
    name: json['name'] ?? '',
    type: (json['type']?.toLowerCase() == 'data')
        ? NodeType.data
        : NodeType.category,
    data: json['data'] != null
        ? Map<String, String>.from(json['data'])
        : {},
    children: children,
    order: json['order'] ?? defaultOrder,
  );
}




  List<Node> lists = [];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("새 리스트 생성"),
        actions: [
          // 우측에 + 아이콘을 먼저 배치 (디스켓 아이콘 왼쪽)
          IconButton(
            icon: Icon(Icons.add),
            tooltip: "새 리스트 생성",
            onPressed: () => _createNewList(context),
          ),
          // 대량 업로드 버튼
          IconButton(
            icon: Icon(Icons.file_upload),
            tooltip: "대량 업로드",
            onPressed: _bulkUpload,
          ),
          // 저장 버튼
          IconButton(
            icon: Icon(Icons.save),
            tooltip: "저장",
            onPressed: _saveToFirebase,
          ),
        ],
      ),
      body: lists.isEmpty
          ? Center(child: Text("아직 생성된 리스트가 없습니다."))
          : ListView.builder(
        itemCount: lists.length,
        itemBuilder: (context, index) {
          return NodeWidget(node: lists[index]);
        },
      ),
      // floatingActionButton 제거
    );
  }

  // 새 최상위 리스트(노드) 생성 다이얼로그
  void _createNewList(BuildContext context) {
    String listName = "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("새 리스트 생성"),
          content: TextField(
            decoration: InputDecoration(hintText: "리스트 이름"),
            onChanged: (value) {
              listName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (listName.trim().isNotEmpty) {
                  setState(() {
                    lists.add(Node(name: listName));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text("생성"),
            ),
          ],
        );
      },
    );
  }

  // Firestore에 저장하는 함수 (현재는 문서 ID를 자동 생성하는 방식)
  Future<void> _saveToFirebase() async {
    try {
      for (var listNode in lists) {
        DocumentReference listDoc = await FirebaseFirestore.instance
            .collection('lists')
            .add({
          'name': listNode.name,
          'type': listNode.type == NodeType.category ? 'category' : 'data',
          'data': listNode.data,
          'timestamp': FieldValue.serverTimestamp(),
        });
        listNode.docId = listDoc.id;
        await _saveChildren(listNode.children, listDoc);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase 저장 완료')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  // 하위 노드들을 재귀적으로 저장
  Future<void> _saveChildren(
      List<Node> children, DocumentReference parentDoc) async {
    for (var child in children) {
      DocumentReference childDoc = await parentDoc.collection('children').add({
        'name': child.name,
        'type': child.type == NodeType.category ? 'category' : 'data',
        'data': child.data,
      });
      if (child.children.isNotEmpty) {
        await _saveChildren(child.children, childDoc);
      }
    }
  }

  // 대량 업로드 함수: file_picker를 사용해 JSON 파일 선택 후 파싱하여 새로운 리스트 생성
  Future<void> _bulkUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['json'],
    );
    if (result?.files.single.path == null) return;

    String content = await File(result!.files.single.path!).readAsString();
    final jsonData = jsonDecode(content);
    if (jsonData is List) {
      setState(() {
        lists.addAll(
            jsonData.map((e) => _parseNode(e as Map<String, dynamic>))
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("대량 업로드 완료")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("JSON 형식 오류")),
      );
    }
  }
}

class NodeWidget extends StatefulWidget {
  final Node node;
  final VoidCallback? onDelete; // 부모에게 삭제 요청을 알리는 콜백

  const NodeWidget({super.key, required this.node, this.onDelete});

  @override
  _NodeWidgetState createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  bool isExpanded = false;

  // 노드 편집 다이얼로그 (이름, 타입, 추가 데이터 "뜻")
  void _editNode(BuildContext context, Node node) {
    String newName = node.name;
    String additionalData = node.data["뜻"] ?? "";
    NodeType selectedType = node.type;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("노드 편집"),
              content: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4, // 화면 높이의 40% 정도로 제한
                    ),
                    child: Padding(
                      // 아래쪽에 약간의 패딩 추가
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: TextEditingController(text: newName),
                            decoration: InputDecoration(labelText: "이름"),
                            onChanged: (value) => newName = value,
                          ),
                          SizedBox(height: 10),
                          DropdownButton<NodeType>(
                            value: selectedType,
                            onChanged: (NodeType? newValue) {
                              if (newValue != null) {
                                setStateDialog(() {
                                  selectedType = newValue;
                                });
                              }
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
                              controller: TextEditingController(text: additionalData),
                              decoration: InputDecoration(labelText: "뜻"),
                              onChanged: (value) => additionalData = value,
                            ),
                        ],
                      ),
                    ),),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (newName.trim().isNotEmpty) {
                      setState(() {
                        node.name = newName;
                        node.type = selectedType;
                        if (selectedType == NodeType.data) {
                          node.data["뜻"] = additionalData;
                        } else {
                          node.data.clear();
                        }
                      });
                      Navigator.of(context).pop();
                      setState(() {});
                    }
                  },
                  child: Text("저장"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 노드 삭제
  void _deleteNode(BuildContext context) {
    if (widget.onDelete != null) {
      widget.onDelete!();
    }
  }

  // 하위 노드 추가 다이얼로그 (이름, 타입, "뜻" 입력)
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
                    onChanged: (value) {
                      childName = value;
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButton<NodeType>(
                    value: selectedType,
                    onChanged: (NodeType? newValue) {
                      if (newValue != null) {
                        setStateDialog(() {
                          selectedType = newValue;
                        });
                      }
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
                      onChanged: (value) {
                        additionalData = value;
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (childName.trim().isNotEmpty) {
                      setState(() {
                        Node newNode = Node(
                          name: childName,
                          type: selectedType,
                          data: selectedType == NodeType.data
                              ? {"뜻": additionalData}
                              : {},
                        );
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
    return Column(
      children: [
        ListTile(
          title: Text(widget.node.name),
          subtitle: widget.node.type == NodeType.data
              ? Text("뜻: ${widget.node.data["뜻"] ?? ''}")
              : null,
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editNode(context, widget.node);
              } else if (value == 'delete') {
                _deleteNode(context);
              } else if (value == 'add') {
                _addChildNode(context, widget.node);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'add', child: Text("하위 항목 추가")),
              PopupMenuItem(value: 'edit', child: Text("편집")),
              PopupMenuItem(value: 'delete', child: Text("삭제")),
            ],
          ),
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
        ),
        if (isExpanded && widget.node.children.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              children: widget.node.children.map((child) {
                return NodeWidget(
                  node: child,
                  onDelete: () {
                    setState(() {
                      widget.node.children.remove(child);
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}