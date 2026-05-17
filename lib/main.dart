import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import
import 'package:firebase_core/firebase_core.dart';
import 'package:langbat/firebase_options.dart';
import 'package:langbat/screens/auth/launch_gate.dart';
import 'package:langbat/src/services/auth_service.dart';
import 'screens/main/main_screen.dart';
import 'package:langarden_common/constants.dart';
import 'package:langarden_common/theme.dart';
import 'package:langarden_common/providers/theme_provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:langbat/services/audio_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _ignoreMacOSDebugKeyboardAssert();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized");
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  if (!kIsWeb && defaultTargetPlatform != TargetPlatform.macOS) {
    // macOS에서는 백그라운드 오디오 세션 없이 Flutter TTS만 사용한다.
    await AudioService.init(
      builder: () => TTSBackgroundHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'langbat.tts',
        androidNotificationChannelName: 'TTS Playback',
        androidNotificationOngoing: true,
      ),
    );
  }

  final authService = AuthService();

  runApp(
    ProviderScope(
      child: LangbatApp(
        authService: authService,
      ),
    ),
  );
}

void _ignoreMacOSDebugKeyboardAssert() {
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final stack = details.stack?.toString() ?? '';
    final isMacOSDebugKeyboardAssert = kDebugMode &&
        defaultTargetPlatform == TargetPlatform.macOS &&
        stack.contains('HardwareKeyboard._assertEventIsRegular');

    if (isMacOSDebugKeyboardAssert) {
      debugPrint('Ignored Flutter macOS debug keyboard assert.');
      return;
    }

    if (previousOnError != null) {
      previousOnError(details);
    } else {
      FlutterError.presentError(details);
    }
  };
}

class LangbatApp extends ConsumerWidget {
  final AuthService authService;

  const LangbatApp({
    super.key,
    required this.authService,
  });

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
      home: LaunchGate(
        authService: authService,
        signedInBuilder: (_) => const MainScreen(),
      ),
    );
  }
}
