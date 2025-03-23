// lib/screens/main/my_list/my_list_screen.dart
import 'package:flutter/material.dart';
import 'package:langbat/screens/main/my_list/custom_list_screen.dart';
import 'verb_list_screen.dart';
import 'sentence_list_screen.dart';
import 'word_list_screen.dart';
import 'flashcard_set_list_screen.dart';
import 'trash_screen.dart';
import '../cart/cart_screen.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

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
            // "새 리스트 생성" 버튼 추가
            ElevatedButton(
              onPressed: () => _navigateTo(context, CustomListScreen()),
              child: const Text("커스텀 리스트"),
            ),
            ElevatedButton(
              onPressed: () => _navigateTo(context, CartScreen()),
              child: const Text("리스트 바구니"),
            ),
            const SizedBox(height: 16),
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
