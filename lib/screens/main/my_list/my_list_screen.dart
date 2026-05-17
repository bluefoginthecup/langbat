// lib/screens/main/my_list/my_list_screen.dart
import 'package:flutter/material.dart';
import 'package:langbat/screens/main/my_list/custom_list_screen.dart';
import 'package:langbat/src/services/full_backup_service.dart';
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

  Future<void> _createLocalBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('로컬 백업을 생성하는 중입니다...')),
      );
      final result = await const FullBackupService().createBackup();
      messenger.showSnackBar(
        SnackBar(content: Text('백업 생성 완료: ${result.zipFile.path}')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('백업 생성 실패: $e')),
      );
    }
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
              onPressed: () =>
                  _navigateTo(context, const FlashcardSetListScreen()),
              child: const Text("플래시카드 세트"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateTo(context, const TrashScreen()),
              child: const Text("휴지통"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _createLocalBackup(context),
              icon: const Icon(Icons.archive_outlined),
              label: const Text("로컬 백업 생성"),
            ),
          ],
        ),
      ),
    );
  }
}
