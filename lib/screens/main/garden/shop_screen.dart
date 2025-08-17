import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langarden_common/providers/garden_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  final Map<String, int> itemPrices = const {
    'flower_pot': 50,
    'tree': 100,
    'bench': 80,
  };

  final Map<String, IconData> itemIcons = const {
    'flower_pot': Icons.local_florist,
    'tree': Icons.park,
    'bench': Icons.event_seat,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoaded = ref.watch(gardenLoadedProvider);
    if (!isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final points = ref.watch(pointsProvider);
    print('[DEBUG] ShopScreen의 현재 포인트: $points');
    final pointsNotifier = ref.read(pointsProvider.notifier);
    final inventoryNotifier = ref.read(inventoryProvider.notifier);
    final inventory = ref.watch(inventoryProvider);

    void buyItem(String item) {
      final price = itemPrices[item]!;
      if (points >= price) {
        pointsNotifier.state -= price;
        inventoryNotifier.addItem(item);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$item 구매 완료!'),
          duration: const Duration(seconds: 1),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('포인트가 부족합니다.'),
          duration: const Duration(seconds: 1),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('상점')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text('보유 포인트: $points',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: itemPrices.keys.map((item) {
                return ListTile(
                  leading: Icon(itemIcons[item]),
                  title: Text(item),
                  subtitle: Text('가격: ${itemPrices[item]}포인트 | 보유: ${inventory[item] ?? 0}개'),
                  trailing: ElevatedButton(
                    onPressed: () => buyItem(item),
                    child: const Text('구매'),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
