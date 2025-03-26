// lib/models/node_model.dart
enum NodeType { category, data }

class Node {
  String name;
  NodeType type;
  Map<String, String> data;
  List<Node> children;
  String? docId; // Firestore 문서 ID 저장 (옵션)
  int order;             // ← 추가

  Node({
    required this.name,
    this.type = NodeType.category,
    this.data = const {},
    this.children = const [],
    this.docId,
    this.order = 0,      // 기본값
  });

  factory Node.fromJson(Map<String, dynamic> json) => Node(
    name: json['name'],
    type: (json['type'] == 'data') ? NodeType.data : NodeType.category,
    data: Map<String,String>.from(json['data'] ?? {}),
    children: (json['children'] as List?)
        ?.map((e) => Node.fromJson(e))
        .toList() ?? [],
    order: json['order'] ?? 0,   // ← JSON 읽기
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type == NodeType.data ? 'data' : 'category',
    'data': data,
    'children': children.map((c) => c.toJson()).toList(),
    'order': order,             // ← JSON 쓰기
  };
}
