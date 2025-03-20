import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum NodeType { category, data }

class Node {
  String name;
  NodeType type;
  Map<String, String> data; // 예: {"뜻": "사과", "예문": "I ate an apple."}
  List<Node> children;

  Node({
    required this.name,
    this.type = NodeType.category,
    Map<String, String>? data,
    List<Node>? children,
  }) : data = data ?? {},
        children = children ?? [];
}

class MakeListScreen extends StatefulWidget {
  @override
  _MakeListScreenState createState() => _MakeListScreenState();
}

class _MakeListScreenState extends State<MakeListScreen> {
  List<Node> lists = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("리스트 생성"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveToFirebase,
          ),
        ],
      ),
      body: lists.isEmpty
          ? Center(child: Text("새 리스트를 생성하세요"))
          : ListView.builder(
        itemCount: lists.length,
        itemBuilder: (context, index) {
          return NodeWidget(node: lists[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewList(context),
        child: Icon(Icons.add),
      ),
    );
  }

  // 새 최상위 리스트(노드) 생성 (Firestore의 최상위 컬렉션 'lists'에 해당)
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
                if (listName
                    .trim()
                    .isNotEmpty) {
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

  // 최상위 리스트를 저장할 때, 노드 이름을 문서 ID로 사용
  Future<void> _saveToFirebase() async {
    try {
      for (var listNode in lists) {
        // 리스트 이름을 문서 ID로 사용 (예: "VerbList" 등)
        DocumentReference listDoc = FirebaseFirestore.instance
            .collection('lists')
            .doc(listNode.name);
        await listDoc.set({
          'name': listNode.name,
          'type': listNode.type == NodeType.category ? 'category' : 'data',
          'data': listNode.data,
          'timestamp': FieldValue.serverTimestamp(),
        });
        // 하위 노드들을 재귀적으로 저장
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


// 부모 문서의 "children" 서브컬렉션에 하위 노드들을 저장할 때도 노드 이름을 문서 ID로 사용
  Future<void> _saveChildren(List<Node> children,
      DocumentReference parentDoc) async {
    for (var child in children) {
      DocumentReference childDoc = parentDoc
          .collection('children')
          .doc(child.name); // 노드 이름을 문서 ID로 사용
      await childDoc.set({
        'name': child.name,
        'type': child.type == NodeType.category ? 'category' : 'data',
        'data': child.data,
      });
      if (child.children.isNotEmpty) {
        await _saveChildren(child.children, childDoc);
      }
    }
  }
}

class NodeWidget extends StatefulWidget {
  final Node node;
  final VoidCallback? onDelete; // 부모에게 삭제 요청을 알리는 콜백

  const NodeWidget({Key? key, required this.node, this.onDelete}) : super(key: key);

  @override
  _NodeWidgetState createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  bool isExpanded = false;

  // 노드 편집 다이얼로그: 이름, 타입, 데이터 입력(여기서는 "뜻")
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
              content: Column(
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
                      this.setState(() {});
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

  // 노드 삭제 (부모에게 삭제 요청)
  void _deleteNode(BuildContext context) {
    if (widget.onDelete != null) {
      widget.onDelete!();
    }
  }

  // 하위 노드 추가 다이얼로그: 이름, 타입, 추가 데이터("뜻") 입력
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
                          data: selectedType == NodeType.data ? {"뜻": additionalData} : {},
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
