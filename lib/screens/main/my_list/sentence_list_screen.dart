// lib/screens/main/my_list/sentence_list_screen.dart
import 'package:flutter/material.dart';

class SentenceListScreen extends StatelessWidget {
  const SentenceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("문장리스트")),
      body: const Center(
        child: Text("문장리스트 화면 (구현 예정)"),
      ),
    );
  }
}
