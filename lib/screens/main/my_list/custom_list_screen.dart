// lib/screens/main/my_list/custom_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:langbat/models/node_model.dart'; // 공통 Node, NodeType 사용
import 'list_detail_screen.dart'; // 상세 화면
import 'package:langbat/screens/main/my_list/make_list_screen.dart';


class CustomListScreen extends StatelessWidget {
  const CustomListScreen({Key? key}) : super(key: key);

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
        title: Text("커스텀 리스트"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: "새 리스트 생성",
            onPressed: () => _navigateToMakeList(context),
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
          return ListView.builder(
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
              return ListTile(
                title: Text(node.name),
                subtitle: node.type == NodeType.data
                    ? Text("뜻: ${node.data['뜻'] ?? ''}")
                    : null,
                onTap: () {
                  // 리스트를 탭하면 상세 화면(ListDetailScreen)으로 이동
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
            },
          );
        },
      ),
    );
  }
}
