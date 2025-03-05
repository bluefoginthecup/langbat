// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/main/home/home_screen.dart';
import 'screens/main/account/account_screen.dart';
import 'screens/main/input/input_screen.dart';
import 'screens/main/my_list/my_list_screen.dart';
import 'screens/main/study/study_screen.dart';
import 'package:langarden_common/constants.dart';
import 'package:langarden_common/theme.dart';
import 'package:langarden_common/widgets/bottom_nav_bar.dart';
import 'package:langarden_common/providers/theme_provider.dart';
import 'package:langarden_common/auth/auth_screen.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase initialized");
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  runApp(
    ProviderScope(
      child: LangbatApp(),
    ),
  );
}

class LangbatApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod을 사용해 테마 상태를 구독합니다.
    final themeMode = ref.watch(themeModeProvider);

    // 로그인 상태 등 다른 전역 상태도 여기서 구독할 수 있습니다.
    bool isLoggedIn = true; // 실제 인증 로직으로 대체

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Riverpod에서 관리하는 테마 모드 사용
        builder: (context, child) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: child,
      );
    },
    home: Builder(
        builder: (context) {
          return AuthScreen(
              onAuthSuccess: (User user) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
              );
            });
          }),
    );
  }
}

