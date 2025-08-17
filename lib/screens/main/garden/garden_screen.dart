import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langarden_common/providers/garden_provider.dart';
import 'package:langarden_common/providers/garden_firestore_service.dart'; // ✅ Firestore 서비스 import
import 'package:langbat/screens/main/garden/shop_screen.dart';
import 'package:langarden_common/data/plant_catalog.dart';

class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});


  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen> {
  static const int rows = 6;
  static const int cols = 10;

  List<List<Map<String, dynamic>?>> gardenGrid = List.generate(
    rows,
        (_) => List.filled(cols, null),
  );

  String? selectedItem = 'rose';

  @override
  void initState() {
    super.initState();
    loadGardenData();
  }

  Future<void> loadGardenData() async {
    final service = GardenFirestoreService();
    final data = await service.loadGardenData();
    if (data != null) {
      ref.read(pointsProvider.notifier).state = data['points'] ?? 0;
      ref.read(inventoryProvider.notifier)
          .setInventory(Map<String, int>.from(data['inventory'] ?? {}));
      final savedGrid = List<Map<String, dynamic>>.from(data['garden'] ?? []);
      setState(() {
        for (var item in savedGrid) {
          final row = item['row'];
          final col = item['col'];
          final type = item['type'];
          final growth = item['growth'] ?? 0;
          if (row is int && col is int && type is String) {
            gardenGrid[row][col] = {
              'type': type,
              'growth': growth,
            };
          }
        }
      });
      ref.read(gardenLoadedProvider.notifier).state = true;
    }
  }

  Future<void> saveGardenData() async {
    final service = GardenFirestoreService();
    final points = ref.read(pointsProvider);
    final inventory = ref.read(inventoryProvider);

    final gardenData = <Map<String, dynamic>>[];
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cell = gardenGrid[row][col];
        if (cell != null) {
          gardenData.add({
            'row': row,
            'col': col,
            'type': cell['type'],
            'growth': cell['growth'],
          });
        }
      }
    }

    await service.saveGardenData(
      points: points,
      inventory: inventory,
      gardenGrid: gardenData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final inventoryNotifier = ref.read(inventoryProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('나의 정원')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              itemCount: rows * cols,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ cols;
                int col = index % cols;
                final cell = gardenGrid[row][col];

                return GestureDetector(
                  onTap: () async {
                    final points = ref.read(pointsProvider);

                    if (cell == null && selectedItem != null) {
                      if ((inventory[selectedItem!] ?? 0) > 0) {
                        setState(() {
                          gardenGrid[row][col] = {
                            'type': selectedItem!,
                            'growth': 0,
                          };
                        });
                        inventoryNotifier.removeItem(selectedItem!);
                        await saveGardenData();
                      }
                    } else if (cell != null) {
                      final type = cell['type'];
                      final growth = cell['growth'] ?? 0;

                      if (growth < 3 && plantCatalog.containsKey(type)) {
                        final cost = growthCosts[growth];
                        if (points >= cost) {
                          setState(() {
                            gardenGrid[row][col] = {
                              'type': type,
                              'growth': growth + 1,
                            };
                          });
                          ref.read(pointsProvider.notifier).state -= cost;
                          await saveGardenData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$type 성장! (단계 ${growth + 1})')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('포인트가 부족합니다!')),
                          );
                        }
                      }
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      border: Border.all(color: Colors.green),
                    ),
                    child: Center(
                      child: cell != null && plantCatalog.containsKey(cell['type'])
                          ? Image.asset(
                        plantCatalog[cell['type']]!.stages[cell['growth'] ?? 0],
                        width: 32,
                        height: 32,
                      )
                          : const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 160,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: plantCatalog.entries.map((entry) {
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
                            Image.asset(
                              entry.value.stages[0],
                              width: 32,
                              height: 32,
                            ),
                            Text('${entry.value.displayName} ($count)'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ShopScreen()),
                    );
                  },
                  child: const Text('상점으로 가기'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await saveGardenData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('저장 완료!')),
                    );
                  },
                  child: const Text('저장하기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}