// lib/utils/flatten_util.dart
import 'package:langbat/models/node_model.dart';

List<Node> flattenTree(Node node) {
  List<Node> flatList = [];
  void traverse(Node current) {
    flatList.add(current);
    for (var child in current.children) {
      traverse(child);
    }
  }
  traverse(node);
  // 전역 순서를 재할당: 0부터 시작하여 flatList 내 순서대로 order 값을 부여
  for (int i = 0; i < flatList.length; i++) {
    flatList[i].order = i;
  }
  return flatList;
}
