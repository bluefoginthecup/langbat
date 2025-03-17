// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/main/main_screen.dart';
import 'package:langarden_common/constants.dart';
import 'package:langarden_common/theme.dart';
import 'package:langarden_common/providers/theme_provider.dart';
import 'package:langarden_common/auth/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase initialized");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  // SharedPreferences에서 autoLogin 설정 확인
  final prefs = await SharedPreferences.getInstance();
  final autoLogin = prefs.getBool('autoLogin') ?? false;
  final user = FirebaseAuth.instance.currentUser;

  runApp(
    ProviderScope(
      child: LangbatApp(autoLogin: autoLogin, user: user),
    ),
  );
}

class LangbatApp extends ConsumerWidget {
  final bool autoLogin;
  final User? user;

  const LangbatApp({Key? key, required this.autoLogin, this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey, // GlobalKey 할당
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque, // opaque 사용
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
      },
      home: (autoLogin && user != null)
          ? MainScreen()
          : AuthScreen(
        onAuthSuccess: (User user) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('autoLogin', true);
          // navigatorKey를 통해 Navigator 작업 수행
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        },
      ),
    );
  }
}
