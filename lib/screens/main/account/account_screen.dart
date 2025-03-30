// lib/screens/main/account/account_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:langarden_common/auth/auth_screen.dart';
import 'package:langbat/screens/main/main_screen.dart';
import 'package:langarden_common/auth/profile_update_screen.dart'; // 회원정보 수정 페이지


class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userProfileStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();
    } else {
      return const Stream.empty();
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuthScreen(
          onAuthSuccess: (User user) {
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userProfileStream(),
        builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
    return Center(child: Text('오류 발생: ${snapshot.error}'));
    }
    if (!snapshot.hasData || snapshot.data == null) {
    return const Center(child: Text('사용자 정보를 찾을 수 없습니다.'));
    }
    final data = snapshot.data!;
    return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('내 캐릭터: ${data['character'] ?? '선택되지 않음'}',
          style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 12),
      if (data['character'] != null)
        Center(
          child: Image.asset(
            'assets/characters/${_characterToImageFile(data['character'])}',
            height: 150,
          ),
        ),
      const SizedBox(height: 8),
      Text('포인트: ${data['points'] ?? 0}점', style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 8),
      Text('이름: ${data['name'] ?? '정보 없음'}', style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 8),
      Text('이메일: ${data['email'] ?? '정보 없음'}', style: const TextStyle(fontSize: 16)),
    const SizedBox(height: 8),
    // 비밀번호는 표시할 수 없습니다.
    Text('전화번호: ${data['phone'] ?? '정보 없음'}', style: const TextStyle(fontSize: 16)),
    const Spacer(),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    ElevatedButton(
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProfileUpdateScreen(user: FirebaseAuth.instance.currentUser!)),
    );
    },
    child: const Text('회원정보 수정'),
    ),

    const SizedBox(width: 20),
    ElevatedButton(
    onPressed: () => _logout(context),
    child: const Text('로그아웃'),
    ),
    ],
    ),
    ],
    ),
    );
    },
    ),
    );

  }String _characterToImageFile(String characterName) {
    switch (characterName) {
      case '농부':
        return 'farmer.png';
      case '까마귀':
        return 'crow.png';
      case '생쥐':
        return 'mouse.png';
      case '당나귀':
        return 'donkey.png';
      default:
        return 'farmer.png';
    }
  }

}
