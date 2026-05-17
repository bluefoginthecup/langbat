import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:langbat/features/photo_flashcards/data/photo_asset_service.dart';
import 'package:langbat/features/photo_flashcards/data/photo_flashcard_repository.dart';
import 'package:langbat/features/photo_flashcards/presentation/photo_card_edit_screen.dart';

class PhotoImportScreen extends StatefulWidget {
  const PhotoImportScreen({super.key});

  @override
  State<PhotoImportScreen> createState() => _PhotoImportScreenState();
}

class _PhotoImportScreenState extends State<PhotoImportScreen> {
  final _titleController = TextEditingController(text: '사진 플래시카드');
  final _repo = PhotoFlashcardRepository();
  final _assetService = const PhotoAssetService();
  List<XFile> _picked = [];
  bool _picking = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    if (_picking || _saving) return;
    setState(() => _picking = true);
    try {
      final photos = await _assetService.pickMultiplePhotos();
      if (!mounted || photos.isEmpty) return;
      setState(() => _picked = photos);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 선택 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    if (_picked.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final deckId = await _repo.createDeckFromPhotos(
        title: _titleController.text,
        description: '사진 기반 스페인어 플래시카드',
        photos: _picked,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PhotoCardEditScreen(deckId: deckId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가져오기 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _picked.isNotEmpty && !_saving;

    return Scaffold(
      appBar: AppBar(title: const Text('사진 카드 가져오기')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: '덱 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving || _picking ? null : _pickPhotos,
              icon: _picking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_library_outlined),
              label: Text(
                _picking
                    ? '선택창 여는 중'
                    : _picked.isEmpty
                        ? '사진 여러 장 선택'
                        : '사진 다시 선택',
              ),
            ),
            const SizedBox(height: 12),
            Text('선택한 사진 ${_picked.length}장'),
            const SizedBox(height: 12),
            if (_picked.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _picked.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_picked[index].path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.image_outlined),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: canSave ? _save : null,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? '저장 중' : '덱 만들기'),
            ),
          ],
        ),
      ),
    );
  }
}
