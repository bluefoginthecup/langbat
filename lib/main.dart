// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/home/home_screen.dart';
import 'screens/main/account/account_screen.dart';
import 'screens/main/input/input_screen.dart';
import 'screens/main/my_list/my_list_screen.dart';
import 'screens/main/study/study_screen.dart';

import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(LangbatApp());
}

class LangbatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 초기 인증 상태를 확인하는 로직을 추가할 수 있습니다.
    bool isLoggedIn = true; // 실제 인증 로직으로 대체

    return MaterialApp(
      title: 'Langbat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn ? MainScreen() : LoginScreen(),
    );
  }
}

// 로그인 후 보여질 메인 화면 예시 (하단 탭바 포함)
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  // 각 탭에 해당하는 화면들을 IndexedStack으로 관리하면 상태 보존에 유리합니다.
  final List<Widget> _screens = [
    HomeScreen(),
    AccountScreen(),
    InputScreen(),
    MyListScreen(),
    StudyScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
