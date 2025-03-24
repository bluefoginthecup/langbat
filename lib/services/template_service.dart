import 'dart:convert';
import 'package:langbat/models/node_model.dart';

/// Node 전체 구조(카테고리, children, data)를 중첩 JSON으로 변환
Map<String, dynamic> nodeToJson(Node node) {
  return {
    "name": node.name,
    "type": node.type == NodeType.data ? "data" : "category",
    "data": node.data,
    "children": node.children.map(nodeToJson).toList(),
  };
}

/// Node 트리 전체를 JSON 문자열로 만들어 반환
String generateTemplateJson(Node rootNode) {
  Map<String, dynamic> rootMap = nodeToJson(rootNode);
  return jsonEncode(rootMap);
}
