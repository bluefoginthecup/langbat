// lib/models/node_model.dart
enum NodeType { category, data }

class Node {
  String name;
  NodeType type;
  Map<String, String> data;
  List<Node> children;
  String? docId; // Firestore 문서 ID 저장 (옵션)

  Node({
    required this.name,
    this.type = NodeType.category,
    Map<String, String>? data,
    List<Node>? children,
    this.docId,
  }) : data = data ?? {},
        children = children ?? [];
}
