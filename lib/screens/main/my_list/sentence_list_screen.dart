// lib/screens/main/my_list/sentence_list_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:langbat/src/repos/flashcard_repository.dart';
import 'package:langbat/src/repos/local_models.dart';
import 'package:langbat/src/repos/term_repository.dart';
import 'package:langbat/src/services/app_path_service.dart';

class SentenceListScreen extends StatefulWidget {
  const SentenceListScreen({super.key});

  @override
  State<SentenceListScreen> createState() => _SentenceListScreenState();
}

class _SentenceListScreenState extends State<SentenceListScreen> {
  final _termRepo = TermRepository();
  final _flashcardRepo = FlashcardRepository();
  final _paths = const AppPathService();
  final _selectedIds = <String>{};
  List<LocalTerm> _lastTerms = [];

  bool get _selectionMode => _selectedIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_selectionMode ? '문장 선택됨 ${_selectedIds.length}개' : '문장리스트'),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              tooltip: '플래시카드 세트 만들기',
              icon: const Icon(Icons.style),
              onPressed: _createFlashcardSetFromSelection,
            ),
            IconButton(
              tooltip: '선택 해제',
              icon: const Icon(Icons.clear),
              onPressed: () => setState(_selectedIds.clear),
            ),
          ] else ...[
            IconButton(
              tooltip: '문장 추가',
              icon: const Icon(Icons.add),
              onPressed: () => _openAddDialog(context),
            ),
          ],
        ],
      ),
      body: StreamBuilder<List<LocalTerm>>(
        stream: _termRepo.watchTerms(type: 'sentence'),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('오류: ${snap.error}'));
          }

          final terms = snap.data ?? const <LocalTerm>[];
          _lastTerms = terms;
          if (terms.isEmpty) {
            return const _EmptyHint();
          }

          return ListView.separated(
            itemCount: terms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final term = terms[i];
              final selected = _selectedIds.contains(term.id);

              return FutureBuilder<File?>(
                future: _imageFile(term.imagePath),
                builder: (context, imageSnap) {
                  final file = imageSnap.data;
                  return ListTile(
                    leading: file == null
                        ? const Icon(Icons.chat_bubble_outline)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              file,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                    title: Text(
                      term.frontText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: term.backText.isEmpty
                        ? null
                        : Text(
                            term.backText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    trailing: _selectionMode
                        ? Checkbox(
                            value: selected,
                            onChanged: (_) => _toggleSelect(term.id),
                          )
                        : null,
                    onLongPress: () => _toggleSelect(term.id),
                    onTap: () {
                      if (_selectionMode) {
                        _toggleSelect(term.id);
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<File?> _imageFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    final file = await _paths.resolveAppFile(imagePath);
    return file.existsSync() ? file : null;
  }

  Future<void> _openAddDialog(BuildContext context) async {
    final sentenceCtl = TextEditingController();
    final meaningCtl = TextEditingController();
    XFile? picked;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> save() async {
            final sentence = sentenceCtl.text.trim();
            final meaning = meaningCtl.text.trim();
            if (sentence.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('문장을 입력하세요.')),
              );
              return;
            }

            try {
              final termId = const Uuid().v4();
              final imagePath = picked == null
                  ? null
                  : await _copyPickedImage(termId: termId, picked: picked!);

              await _termRepo.addTerm(
                id: termId,
                type: 'sentence',
                frontText: sentence,
                backText: meaning,
                imagePath: imagePath,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('추가되었습니다.')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('저장 실패: $e')),
              );
            }
          }

          return AlertDialog(
            title: const Text('문장 추가'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: sentenceCtl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: '문장',
                      hintText: '예) I need a nap.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: meaningCtl,
                    decoration: const InputDecoration(
                      labelText: '뜻 (선택)',
                      hintText: '예) 나 낮잠 필요해.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final x = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 2000,
                          );
                          if (x != null) setDialogState(() => picked = x);
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('이미지 선택'),
                      ),
                      const SizedBox(width: 12),
                      if (picked != null)
                        Expanded(
                          child: Text(
                            picked!.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save),
                label: const Text('저장'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<String> _copyPickedImage({
    required String termId,
    required XFile picked,
  }) async {
    final original = await picked.readAsBytes();
    final compressed = await FlutterImageCompress.compressWithList(
      original,
      quality: 75,
      minWidth: 1600,
      minHeight: 1066,
      format: CompressFormat.jpeg,
    );

    final root = await _paths.termImagesRoot();
    final dir = Directory(p.join(root.path, termId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File(p.join(dir.path, 'front.jpg'));
    await file.writeAsBytes(compressed, flush: true);
    return _paths.normalizeToRelativePath(file.path);
  }

  Future<void> _createFlashcardSetFromSelection() async {
    if (_selectedIds.isEmpty) return;

    final titleCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('플래시카드 세트 만들기'),
        content: TextField(
          controller: titleCtl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '세트 이름',
            hintText: '예) 여행 회화 1',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('만들기'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final orderedIds = _lastTerms
          .where((term) => _selectedIds.contains(term.id))
          .map((term) => term.id)
          .toList(growable: false);

      await _flashcardRepo.createSetFromTerms(
        title: titleCtl.text.trim().isEmpty ? '새 세트' : titleCtl.text.trim(),
        termIds: orderedIds,
      );

      if (!mounted) return;
      setState(_selectedIds.clear);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('플래시카드 세트가 생성되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('세트 생성 실패: $e')),
      );
    }
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Center(
          child: Text(
            '저장된 문장이 없어요.\n오른쪽 상단 + 버튼으로 추가하세요.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
