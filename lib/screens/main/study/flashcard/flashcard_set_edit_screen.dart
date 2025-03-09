import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:langarden_common/providers/multi_select_controller.dart';
import 'package:langarden_common/widgets/multi_select_actions.dart';
import 'package:langarden_common/utils/firebase_multi_deleter.dart';

class FlashcardSetEditScreen extends ConsumerStatefulWidget {
  final String setId;

  const FlashcardSetEditScreen({Key? key, required this.setId}) : super(key: key);

  @override
  _FlashcardSetEditScreenState createState() => _FlashcardSetEditScreenState();
}

class _FlashcardSetEditScreenState extends ConsumerState<FlashcardSetEditScreen> {
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

  // 세트편집 페이지 내부 deleteSelectedItems() 대체 예시

  Future<void> deleteSelectedItems() async {
    final controller = ref.read(multiSelectControllerProvider.notifier);

    await FirebaseMultiDeleter.deleteItems(
      context: context,
      itemIds: controller.state.toList(),
      collectionRef: FirebaseFirestore.instance
          .collection('flashcard_sets')
          .doc(widget.setId)
          .collection('items'),
      confirmContent: "선택한 플래시카드 항목을 삭제할까요?",
      successMessage: "선택한 플래시카드가 삭제되었습니다.",
    );

    setState(() {
      items.removeWhere((doc) => controller.state.contains(doc.id));
      controller.clearSelection();
      controller.toggleSelectionMode();
    });
  }



  @override
  Widget build(BuildContext context) {
    final selectedIds = ref.watch(multiSelectControllerProvider);
    final controller = ref.read(multiSelectControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("플래시카드 세트 편집"),
        actions: [
          IconButton(
            icon: Icon(controller.selectionMode ? Icons.cancel : Icons.checklist),
            onPressed: () {
              setState(() {
                controller.toggleSelectionMode();
              });
            },
          ),
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

          if (controller.selectionMode) // 👈 여기서 기존 위젯 사용!
            MultiSelectActions(
              allSelected: controller.state.length == items.length,
              onToggleSelectAll: () {
                setState(() {
                  if (controller.state.length == items.length) {
                    controller.clearSelection();
                  } else {
                    controller.state.addAll(items.map((item) => item.id));
                  }
                });
              },
              onTrash: deleteSelectedItems,
              onCart: null, // 필요없으면 null
            ),

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
                final isSelected = controller.state.contains(item.id);

                return ListTile(
                  key: ValueKey(item.id),
                  leading: controller.selectionMode
                      ? Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank)
                      : ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, color: Colors.green),
                  ),
                  title: Text(displayText),
                  onTap: controller.selectionMode
                      ? () {
                    setState(() {
                      controller.toggleItem(item.id);
                    });
                  }
                      : null,
                );
              }).toList(),
            ),
          ),

        ],
      ),
    );
  }
}
