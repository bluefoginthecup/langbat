// lib/screens/main/account/account_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:langarden_common/auth/auth_screen.dart';
import 'package:langbat/screens/main/main_screen.dart'; // MainScreen이 있는 경로


class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // 로그아웃 후 AuthScreen으로 전환 (onAuthSuccess 콜백은 임시로 아무 동작도 하지 않는 함수로 전달)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuthScreen(
          onAuthSuccess: (User user) {
            // AuthScreen 내에서 로그인 성공 시 호출되는 콜백입니다.
            // 여기에 원하는 동작을 정의할 수 있습니다.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('계정')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _logout(context),
          child: const Text('로그아웃'),
        ),
      ),
    );
  }
}
