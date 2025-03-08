// lib/screens/main/my_list/word_list_screen.dart
import 'package:flutter/material.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("단어리스트")),
      body: const Center(
        child: Text("단어리스트 화면 (구현 예정)"),
      ),
    );
  }
}
