import 'package:flutter/material.dart';
import 'package:langarden_common/widgets/setting_screen.dart';

class HomeScreen extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const HomeScreen({
    Key? key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('홈')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // SettingsScreen을 열고 선택된 테마 값을 기다립니다.
            final selectedTheme = await Navigator.push<ThemeMode>(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  currentThemeMode: currentThemeMode,
                  onThemeChanged: onThemeChanged,
                ),
              ),
            );
            // 반환된 값이 있으면 부모의 상태를 업데이트합니다.
            if (selectedTheme != null) {
              onThemeChanged(selectedTheme);
            }
          },
          child: Text('테마 설정'),
        ),
      ),
    );
  }
}
