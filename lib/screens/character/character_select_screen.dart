import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main/main_screen.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  final List<Map<String, String>> characters = [
    {
      'name': '농부',
      'image': 'assets/characters/farmer.png',
    },
    {
      'name': '까마귀',
      'image': 'assets/characters/crow.png',
    },
    {
      'name': '생쥐',
      'image': 'assets/characters/mouse.png',
    },
    {
      'name': '당나귀',
      'image': 'assets/characters/donkey.png',
    },
  ];

  int _selectedIndex = 0;
  bool _isSaving = false;

  Future<void> _saveCharacter() async {
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final selectedCharacter = characters[_selectedIndex]['name'];

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'character': selectedCharacter,
      'characterSetAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('캐릭터를 선택하세요'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Swiper(
              itemCount: characters.length,
              onIndexChanged: (index) => setState(() => _selectedIndex = index),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        characters[index]['image']!,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        characters[index]['name']!,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
              viewportFraction: 0.8,
              scale: 0.9,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveCharacter,
              child: const Text('이 캐릭터로 시작하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
