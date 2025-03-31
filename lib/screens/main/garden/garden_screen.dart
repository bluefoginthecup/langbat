import 'package:flutter/material.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  static const int rows = 6;
  static const int cols = 10;

  // 정원 그리드
  List<List<String?>> gardenGrid = List.generate(
    6,
        (_) => List.filled(10, null),
  );

  // 현재 선택된 아이템
  String? selectedItem = 'flower_pot';

  // 아이템 아이콘
  final Map<String, IconData> itemIcons = {
    'flower_pot': Icons.local_florist,
    'tree': Icons.park,
    'bench': Icons.event_seat,
  };

  // 초기 인벤토리 (수량 제한)
  Map<String, int> inventory = {
    'flower_pot': 3,
    'tree': 1,
    'bench': 0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('나의 정원')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // 정원 그리드
          Expanded(
            child: GridView.builder(
              itemCount: rows * cols,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ cols;
                int col = index % cols;
                String? item = gardenGrid[row][col];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (item == null && selectedItem != null) {
                        // 배치 시 수량 1 감소
                        if (inventory[selectedItem!]! > 0) {
                          gardenGrid[row][col] = selectedItem;
                          inventory[selectedItem!] =
                              inventory[selectedItem!]! - 1;
                        }
                      } else if (item != null) {
                        // 제거 시 수량 복원
                        inventory[item] = inventory[item]! + 1;
                        gardenGrid[row][col] = null;
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      border: Border.all(color: Colors.green),
                    ),
                    child: Center(
                      child: item != null
                          ? Icon(itemIcons[item], size: 20)
                          : const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            ),
          ),

          // 아이템 선택 바
          Container(
            height: 100,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: itemIcons.entries.map((entry) {
                final isSelected = selectedItem == entry.key;
                final item = entry.key;
                final count = inventory[item] ?? 0;
                final isDisabled = count == 0;

                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () {
                    setState(() {
                      selectedItem = item;
                    });
                  },
                  child: Opacity(
                    opacity: isDisabled ? 0.3 : 1.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          entry.value,
                          size: 30,
                          color: isSelected ? Colors.green : Colors.black,
                        ),
                        Text('$item ($count)'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
