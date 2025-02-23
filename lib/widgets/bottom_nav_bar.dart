// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: '계정',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit),
          label: '입력',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: '내 리스트',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: '학습',
        ),
      ],
    );
  }
}
