// flashcard_set_edit_screen.dart (예시 파일명)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardSetEditScreen extends StatefulWidget {
  final String setId;

  const FlashcardSetEditScreen({Key? key, required this.setId}) : super(key: key);

  @override
  _FlashcardSetEditScreenState createState() => _FlashcardSetEditScreenState();
}

class _FlashcardSetEditScreenState extends State<FlashcardSetEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<DocumentSnapshot> items = [];

  @override
  void initState() {
    super.initState();
    _loadSetData();
  }

  void _loadSetData() async {
    final setDoc = await FirebaseFirestore.instance
        .collection('flashcard_sets')
        .doc(widget.setId)
        .get();

    final itemsSnapshot = await FirebaseFirestore.instance
        .collection('flashcard_sets')
        .doc(widget.setId)
        .collection('items')
        .orderBy('order')
        .get();

    setState(() {
      _nameController.text = setDoc['name'] ?? '';
      items = itemsSnapshot.docs;
    });
  }

  void _saveOrder() {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < items.length; i++) {
      batch.update(items[i].reference, {'order': i});
    }
    batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("플래시카드 세트 편집"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "저장",
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('flashcard_sets')
                  .doc(widget.setId)
                  .update({'name': _nameController.text});
              _saveOrder();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("세트가 저장되었습니다.")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "세트 이름 입력",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              buildDefaultDragHandles: false,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = items.removeAt(oldIndex);
                  items.insert(newIndex, item);
                });
              },
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final data = item.data() as Map<String, dynamic>;
                final displayText = data["content"]["verb"] ?? data["content"]["word"] ?? data["content"]["sentence"] ?? "No data";

                return ListTile(
                  key: ValueKey(item.id),
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, color: Colors.green),
                  ),
                  title: Text(displayText),
                );
              }).toList(),
            ),

          ),
        ],
      ),
    );
  }
}
