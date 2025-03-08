// lib/screens/main/my_list/flashcard_set_screen.dart
import 'package:flutter/material.dart';

class FlashcardSetScreen extends StatelessWidget {
  const FlashcardSetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("플래시카드 세트")),
      body: const Center(
        child: Text("플래시카드 세트 화면 (구현 예정)"),
      ),
    );
  }
}
