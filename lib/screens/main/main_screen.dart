// lib/screens/main/main_screen.dart
import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'account/account_screen.dart';
import 'input/input_screen.dart';
import 'my_list/my_list_screen.dart';
import 'study/study_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 각 탭에 해당하는 화면들을 리스트에 저장합니다.
  final List<Widget> _screens = [
    HomeScreen(),     // 첫 번째 탭: 홈 화면
    AccountScreen(),  // 두 번째 탭: 계정 화면
    InputScreen(),    // 세 번째 탭: 입력 화면
    MyListScreen(),   // 네 번째 탭: 내 리스트
    StudyScreen(),    // 다섯 번째 탭: 학습 화면
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack를 사용해 각 탭의 화면 상태를 유지하면서 표시합니다.
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // 하단 탭 내비게이션바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
      ),
    );
  }
}
