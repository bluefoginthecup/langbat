import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int points = 300;

  // 인벤토리 (아이템 수량)
  Map<String, int> inventory = {
    'flower_pot': 0,
    'tree': 0,
    'bench': 0,
  };

  // 아이템 가격
  final Map<String, int> itemPrices = {
    'flower_pot': 50,
    'tree': 100,
    'bench': 80,
  };

  final Map<String, IconData> itemIcons = {
    'flower_pot': Icons.local_florist,
    'tree': Icons.park,
    'bench': Icons.event_seat,
  };

  void buyItem(String item) {
    int price = itemPrices[item]!;
    if (points >= price) {
      setState(() {
        points -= price;
        inventory[item] = (inventory[item] ?? 0) + 1;
      });
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

  @override
  Widget build(BuildContext context) {
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
                  subtitle: Text('가격: ${itemPrices[item]}포인트'),
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
