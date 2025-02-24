// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/home/home_screen.dart';
import 'screens/main/account/account_screen.dart';
import 'screens/main/input/input_screen.dart';
import 'screens/main/my_list/my_list_screen.dart';
import 'screens/main/study/study_screen.dart';
import 'package:langarden_common/constants.dart';
import 'package:langarden_common/theme.dart';
import 'package:langarden_common/widgets/bottom_nav_bar.dart';

void main() {
  runApp(LangbatApp());
}

class LangbatApp extends StatefulWidget {
  @override
  _LangbatAppState createState() => _LangbatAppState();
}

class _LangbatAppState extends State<LangbatApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _updateTheme(ThemeMode newTheme) {
    print("Theme updated to: $newTheme"); // 로그로 변경 확인
    setState(() {
      _themeMode = newTheme;
    });
    // 선택값 저장 로직 추가 가능 (예: shared_preferences)
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = true; // 실제 인증 로직으로 대체

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: isLoggedIn
          ? MainScreen(
        currentThemeMode: _themeMode,
        onThemeChanged: _updateTheme,
      )
          : LoginScreen(),
    );
  }
}

// MainScreen을 테마 상태를 받도록 수정
class MainScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const MainScreen({
    Key? key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

  class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
  setState(() {
  _selectedIndex = index;
  });
  }

  List<Widget> _buildScreens() {
  return [
  HomeScreen(
  currentThemeMode: widget.currentThemeMode,
  onThemeChanged: widget.onThemeChanged,
  ),
  AccountScreen(),
  InputScreen(),
  MyListScreen(),
  StudyScreen(),
  ];
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  body: IndexedStack(
  index: _selectedIndex,
  children: _buildScreens(), // 여기서 매번 최신 값을 반영하는 화면 생성
  ),
  bottomNavigationBar: BottomNavBar(
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
  ),
  );
  }
  }

