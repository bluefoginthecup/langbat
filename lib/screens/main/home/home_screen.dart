// langbat/lib/screens/main/home/home_screen.dart (Riverpod 방식)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langarden_common/widgets/setting_screen.dart';



class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // onThemeChanged는 전역 상태 업데이트 메서드로 대체됩니다.
    return Scaffold(
      appBar: AppBar(title: Text('홈')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // SettingsScreen은 전역 상태를 사용하므로, 별도의 파라미터 없이 호출합니다.
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            );
          },
          child: Text('테마 설정'),
        ),
      ),
    );
  }
}
