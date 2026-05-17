import 'package:flutter/material.dart';

import 'package:langbat/features/photo_flashcards/data/photo_flashcard_models.dart';
import 'package:langbat/features/photo_flashcards/data/photo_flashcard_repository.dart';
import 'package:langbat/features/photo_flashcards/presentation/photo_card_edit_screen.dart';
import 'package:langbat/features/photo_flashcards/presentation/photo_import_screen.dart';
import 'package:langbat/features/photo_flashcards/presentation/photo_study_screen.dart';

class PhotoDeckListScreen extends StatefulWidget {
  const PhotoDeckListScreen({super.key});

  @override
  State<PhotoDeckListScreen> createState() => _PhotoDeckListScreenState();
}

class _PhotoDeckListScreenState extends State<PhotoDeckListScreen> {
  final _repo = PhotoFlashcardRepository();

  Future<void> _startStudy(PhotoFlashcardDeck deck) async {
    final cards = await _repo.loadCards(deck.id);
    final readyCards = cards
        .where((card) => card.imageAbsolutePath != null)
        .toList(growable: false);
    if (!mounted) return;
    if (readyCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('학습할 사진 카드가 없습니다.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoStudyScreen(
          deckTitle: deck.title,
          cards: readyCards,
        ),
      ),
    );
  }

  Future<void> _openImport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PhotoImportScreen()),
    );
  }

  Future<void> _openEdit(String deckId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PhotoCardEditScreen(deckId: deckId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사진 플래시카드')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openImport,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('가져오기'),
      ),
      body: StreamBuilder<List<PhotoFlashcardDeck>>(
        stream: _repo.watchDecks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }

          final decks = snapshot.data ?? const <PhotoFlashcardDeck>[];
          if (decks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 52,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '사진으로 새 플래시카드 덱을 만들어보세요.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _openImport,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('사진 가져오기'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: decks.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final deck = decks[index];
              return ListTile(
                leading: const Icon(Icons.photo_album_outlined),
                title: Text(deck.title),
                subtitle: Text('${deck.cardCount}장'),
                onTap: () => _startStudy(deck),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: '편집',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _openEdit(deck.id),
                    ),
                    IconButton(
                      tooltip: '학습',
                      icon: const Icon(Icons.play_circle_outline),
                      onPressed: () => _startStudy(deck),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
