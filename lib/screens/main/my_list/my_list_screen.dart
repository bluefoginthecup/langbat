// lib/screens/main/my_list/my_list_screen.dart
import 'package:flutter/material.dart';
import 'package:langbat/features/photo_flashcards/presentation/photo_deck_list_screen.dart';
import 'package:langbat/screens/main/my_list/custom_list_screen.dart';
import 'package:langbat/src/services/auth_service.dart';
import 'package:langbat/src/services/cloud_backup_service.dart';
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

  Future<void> _uploadCloudBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('클라우드 백업을 업로드하는 중입니다...')),
      );
      final result = await CloudBackupService(
        authService: AuthService(),
      ).uploadFullBackup();
      messenger.showSnackBar(
        SnackBar(content: Text('클라우드 백업 완료: ${result.backupId}')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('클라우드 백업 실패: $e')),
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
            ElevatedButton.icon(
              onPressed: () =>
                  _navigateTo(context, const PhotoDeckListScreen()),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text("사진 플래시카드"),
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _uploadCloudBackup(context),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text("클라우드 백업 업로드"),
            ),
          ],
        ),
      ),
    );
  }
}
