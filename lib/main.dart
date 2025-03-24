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
import 'package:audio_service/audio_service.dart';
import 'package:langbat/services/audio_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase initialized");
  } catch (e) {
    print("Firebase initialization error: $e");
  }


  // AudioService 초기화 — 백그라운드 TTS 핸들러 등록
  final audioHandler = await AudioService.init(
  builder: () => TTSBackgroundHandler(),
  config: AudioServiceConfig(
  androidNotificationChannelId: 'langbat.tts',
  androidNotificationChannelName: 'TTS Playback',
  androidNotificationOngoing: true,
  ),);


  // SharedPreferences에서 autoLogin 설정 확인
  final prefs = await SharedPreferences.getInstance();
  final autoLogin = prefs.getBool('autoLogin') ?? false;
  final user = FirebaseAuth.instance.currentUser;

  runApp(
      AudioServiceWidget(
      child: ProviderScope(
        child: LangbatApp(autoLogin: autoLogin, user: user, audioHandler: audioHandler,),
      ),
    ),
  );
}

class LangbatApp extends ConsumerWidget {
  final AudioHandler audioHandler;
  final bool autoLogin;
  final User? user;

  const LangbatApp({super.key, required this.autoLogin, this.user, required this.audioHandler});

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
