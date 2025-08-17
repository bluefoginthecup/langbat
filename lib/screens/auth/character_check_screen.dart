import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../onboarding/onboarding_screen.dart';
import '../main/main_screen.dart';
import 'package:langbat/services/point_service.dart';

class CharacterCheckScreen extends StatelessWidget {
  const CharacterCheckScreen({super.key});

  Future<Widget> checkCharacterAndGiveReward() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('로그인 정보 없음')));
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();
    final data = doc.data();

    if (data == null) {
      await userRef.set({'createdAt': FieldValue.serverTimestamp()});
      return const OnboardingScreen();
    }

    final hasCharacter = data.containsKey('character');

    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (data['lastLoginDate'] != today) {
      await userRef.update({
        'lastLoginDate': today,
      });
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
