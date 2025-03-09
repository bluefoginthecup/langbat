// lib/screens/main/my_list/my_list_screen.dart
import 'package:flutter/material.dart';
import 'verb_list_screen.dart';
import 'sentence_list_screen.dart';
import 'word_list_screen.dart';
import 'flashcard_set_list_screen.dart';
import 'trash_screen.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, Widget destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("내 리스트")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateTo(context, const VerbListScreen()),
              child: const Text("동사리스트"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateTo(context, const WordListScreen()),
              child: const Text("단어리스트"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateTo(context, const SentenceListScreen()),
              child: const Text("문장리스트"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateTo(context, const FlashcardSetListScreen()),
              child: const Text("플래시카드 세트"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateTo(context, const TrashScreen()),
              child: const Text("휴지통"),
            ),
          ],
        ),
      ),
    );
  }
}
