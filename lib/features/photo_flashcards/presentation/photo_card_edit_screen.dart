import 'package:flutter/material.dart';

import 'package:langbat/features/photo_flashcards/data/photo_asset_service.dart';
import 'package:langbat/features/photo_flashcards/data/photo_flashcard_models.dart';
import 'package:langbat/features/photo_flashcards/data/photo_flashcard_repository.dart';
import 'package:langbat/features/photo_flashcards/presentation/widgets/photo_card_image.dart';

class PhotoCardEditScreen extends StatefulWidget {
  const PhotoCardEditScreen({super.key, required this.deckId});

  final String deckId;

  @override
  State<PhotoCardEditScreen> createState() => _PhotoCardEditScreenState();
}

class _PhotoCardEditScreenState extends State<PhotoCardEditScreen> {
  final _repo = PhotoFlashcardRepository();
  final _assetService = const PhotoAssetService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _selectedItemIds = <String>{};

  PhotoFlashcardDeck? _deck;
  List<PhotoFlashcard> _cards = [];
  bool _loading = true;
  bool _saving = false;
  bool _picking = false;

  bool get _selectionMode => _selectedItemIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final deck = await _repo.getDeck(widget.deckId);
    final cards = await _repo.loadCards(widget.deckId);
    if (!mounted) return;
    setState(() {
      _deck = deck;
      _cards = cards;
      _titleController.text = deck?.title ?? '';
      _descriptionController.text = deck?.description ?? '';
      _selectedItemIds.clear();
      _loading = false;
    });
  }

  Future<void> _saveDeckInfo() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _repo.updateDeck(
        deckId: widget.deckId,
        title: _titleController.text,
        description: _descriptionController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('덱 정보가 저장되었습니다.')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addPhotos() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final photos = await _assetService.pickMultiplePhotos();
      if (photos.isEmpty) return;
      await _repo.addPhotosToDeck(deckId: widget.deckId, photos: photos);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 추가 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _openCardDialog(PhotoFlashcard card) async {
    final spanishController = TextEditingController(text: card.spanishText);
    final koreanController = TextEditingController(text: card.koreanText);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사진 카드 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 180,
                width: double.maxFinite,
                child: PhotoCardImage(
                  path: card.thumbnailAbsolutePath ?? card.imageAbsolutePath,
                  fit: BoxFit.contain,
                  borderRadius: 8,
                  cacheWidth: 700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: spanishController,
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '스페인어 문장',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: koreanController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '한국어 뜻',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    try {
      await _repo.updateCardText(
        termId: card.termId,
        spanishText: spanishController.text,
        koreanText: koreanController.text,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카드 저장 실패: $e')),
      );
    }
  }

  Future<void> _deleteSelectedCards() async {
    if (_selectedItemIds.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 제거'),
        content: Text('${_selectedItemIds.length}개 카드를 이 덱에서 제거할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('제거'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await _repo.removeCardsFromDeck(
      deckId: widget.deckId,
      itemIds: _selectedItemIds,
    );
    await _load();
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('사진 카드 편집')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_deck == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('사진 카드 편집')),
        body: const Center(child: Text('덱을 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _selectionMode ? '카드 ${_selectedItemIds.length}개 선택' : '사진 카드 편집'),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              tooltip: '선택 제거',
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSelectedCards,
            ),
            IconButton(
              tooltip: '선택 해제',
              icon: const Icon(Icons.clear),
              onPressed: () => setState(_selectedItemIds.clear),
            ),
          ] else ...[
            IconButton(
              tooltip: '사진 추가',
              icon: _picking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              onPressed: _picking ? null : _addPhotos,
            ),
            IconButton(
              tooltip: '덱 정보 저장',
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              onPressed: _saving ? null : _saveDeckInfo,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '덱 이름',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  minLines: 1,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '설명',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cards.isEmpty
                ? const Center(child: Text('사진 카드가 없습니다.'))
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: _cards.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      final selected = _selectedItemIds.contains(card.itemId);
                      return ListTile(
                        leading: _selectionMode
                            ? Checkbox(
                                value: selected,
                                onChanged: (_) => _toggleSelection(card.itemId),
                              )
                            : SizedBox(
                                width: 62,
                                height: 62,
                                child: PhotoCardImage(
                                  path: card.thumbnailAbsolutePath ??
                                      card.imageAbsolutePath,
                                  cacheWidth: 240,
                                ),
                              ),
                        title: Text(
                          card.spanishText.isEmpty
                              ? '스페인어 문장 없음'
                              : card.spanishText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          card.koreanText.isEmpty
                              ? '한국어 뜻 없음'
                              : card.koreanText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: _selectionMode
                            ? null
                            : const Icon(Icons.edit_outlined),
                        onTap: _selectionMode
                            ? () => _toggleSelection(card.itemId)
                            : () => _openCardDialog(card),
                        onLongPress: () => _toggleSelection(card.itemId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
