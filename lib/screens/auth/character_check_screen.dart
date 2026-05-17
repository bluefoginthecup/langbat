import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../onboarding/onboarding_screen.dart';
import '../main/main_screen.dart';
import 'package:langbat/services/point_service.dart';
import 'package:langbat/src/repos/settings_repository.dart';

class CharacterCheckScreen extends StatelessWidget {
  const CharacterCheckScreen({super.key});

  Future<Widget> checkCharacterAndGiveReward() async {
    final settings = SettingsRepository();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('로그인 정보 없음')));
    }

    final character = await settings.getString('character');
    final hasCharacter = character != null && character.trim().isNotEmpty;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastLoginDate = await settings.getString('lastLoginDate');
    if (lastLoginDate != today) {
      await settings.setString('lastLoginDate', today);
      await PointService.addPoint(
        amount: 10,
        type: 'daily_login',
        description: '하루 첫 접속 보상',
      );
    }

    return hasCharacter ? const MainScreen() : const OnboardingScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: checkCharacterAndGiveReward(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          debugPrint("🔥 오류발생: ${snapshot.error}");
          debugPrint("Stack trace: ${snapshot.stackTrace}");
          return const Scaffold(
            body: Center(child: Text('오류 발생')),
          );
        }

        return snapshot.data!;
      },
    );
  }
}
