// lib/screens/main/my_list/sentence_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';


class SentenceListScreen extends StatefulWidget {
  const SentenceListScreen({super.key});
  @override
  State<SentenceListScreen> createState() => _SentenceListScreenState();
}

class _SentenceListScreenState extends State<SentenceListScreen> {
  final _selectedIds = <String>{};
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _lastDocs = [];

  String? _uid;
  bool _authError = false;

  @override
  void initState() {
    super.initState();
    _ensureSignedIn();
  }

  Future<void> _ensureSignedIn() async {
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
      setState(() => _uid = FirebaseAuth.instance.currentUser!.uid);
    } catch (e) {
      setState(() => _authError = true);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _stream() {
        final uid = _uid!;
        return FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('sentences')
            .orderBy('createdAt', descending: true)
            .snapshots();
      }

  bool get _selectionMode => _selectedIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_authError) {
      return const Scaffold(
        body: Center(child: Text('로그인에 실패했어요. 네트워크 상태를 확인해 주세요.')),
      );
    }
    if (_uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            debugPrint("🔥 SentenceListScreen stream error: ${snap.error}");
            debugPrint("Stack trace: ${snap.stackTrace}");

            return Center(child: Text('오류: ${snap.error}'));
          }
          final docs = snap.data?.docs ?? [];
          _lastDocs = docs;
          if (docs.isEmpty) {
            return const _EmptyHint();
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final d = doc.data();
              final sentence = (d['sentence'] ?? '') as String;
              final meaning = (d['meaning'] ?? '') as String;
              final imageUrl = (d['imageUrl'] ?? '') as String;
              final selected = _selectedIds.contains(doc.id);

              return ListTile(
                leading: imageUrl.isEmpty
                    ? const Icon(Icons.chat_bubble_outline)
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  sentence,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: meaning.isEmpty
                    ? null
                    : Text(
                  meaning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: _selectionMode
                    ? Checkbox(
                  value: selected,
                  onChanged: (_) => _toggleSelect(doc.id),
                )
                    : null,
                onLongPress: () => _toggleSelect(doc.id),
                onTap: () {
                  if (_selectionMode) {
                    _toggleSelect(doc.id);
                  } else {
                    // TODO: 상세 보기/편집
                  }
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

  Future<void> _openAddDialog(BuildContext context) async {
    final sentenceCtl = TextEditingController();
    final meaningCtl = TextEditingController();
    XFile? picked;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        Future<void> save() async {
          final sentence = sentenceCtl.text.trim();
          final meaning = meaningCtl.text.trim();
          if (sentence.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('문장을 입력하세요.')),
            );
            return;
          }

          // 로그인 보장 및 uid 확보
          await _ensureSignedIn();
          final uid = _uid!;
          final col = FirebaseFirestore.instance
              .collection('users').doc(uid).collection('sentences');
          final docRef = col.doc();

          String imageUrl = '';
          try {
            if (picked != null) {
              final original = await picked!.readAsBytes();

              // 🔽 긴 변 1600px로 리사이즈 + 품질 75 (jpeg)
              final compressed = await FlutterImageCompress.compressWithList(
                original,
                quality: 75,
                minWidth: 1600,
                minHeight: 1066, // 1600 * (2/3) ≈ 1066 (대략 3:2 목표)
                format: CompressFormat.jpeg,
              );

              final path = 'users/$uid/sentences/${docRef.id}.jpg';
              final task = await FirebaseStorage.instance.ref(path).putData(
                compressed,
                SettableMetadata(
                  contentType: 'image/jpeg',
                  // ✅ 7일 캐시(원하면 1년까지 가능)
                  cacheControl: 'public, max-age=604800, immutable',
                ),
              );
              imageUrl = await task.ref.getDownloadURL();
            }

            await docRef.set({
              'sentence': sentence,
              'meaning': meaning,
              'imageUrl': imageUrl,
              'createdAt': FieldValue.serverTimestamp(),
            });

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
                        if (x != null) setState(() => picked = x);
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
      }),
    );
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('만들기')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _ensureSignedIn();
      final uid = _uid!;
      final fs = FirebaseFirestore.instance;

      // ✅ 사용자 네임스페이스에 세트 생성
      final setRef = fs
          .collection('users')
          .doc(uid)
          .collection('flashcard_sets')
          .doc();

      final title = titleCtl.text.trim().isEmpty ? '새 세트' : titleCtl.text.trim();

      debugPrint('[CreateSet] writing set ${setRef.id}');
      await setRef.set({
        'uid': uid,
        'name': title,
        'createdAt': FieldValue.serverTimestamp(),
        'size': _selectedIds.length,
      });

      // ✅ items도 같은 네임스페이스 하위에 저장
      WriteBatch batch = fs.batch();
      int order = 0;
      int ops = 0;

      for (final doc in _lastDocs) {
        if (!_selectedIds.contains(doc.id)) continue;

        final d = doc.data() as Map<String, dynamic>;
        final sentence = (d['sentence'] ?? '') as String;
        final meaning = (d['meaning'] ?? '') as String;
        final imageUrl = (d['imageUrl'] ?? '') as String;

        final itemRef = setRef.collection('items').doc();
        batch.set(itemRef, {
          'addedAt': FieldValue.serverTimestamp(),
          'order': order,
          'content': {
            'text': sentence,
            'meaning': meaning,
            'order': order,
            'type': 'custom',
            if (imageUrl.isNotEmpty) 'imageFrontUrl': imageUrl,
          },
          'sourceSentenceId': doc.id,
        });
        order++;
        ops++;

        if (ops == 450) {
          debugPrint('[CreateSet] committing partial batch...');
          await batch.commit();
          batch = fs.batch();
          ops = 0;
        }
      }

      if (ops > 0) {
        debugPrint('[CreateSet] committing final batch...');
        await batch.commit();
      }

      if (!mounted) return;
      setState(_selectedIds.clear);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('플래시카드 세트가 생성되었습니다.')),
      );
    } on FirebaseException catch (e, st) {
      debugPrint('🔥 set/items 생성 실패: ${e.code} ${e.message}\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('세트 생성 실패: ${e.code}')),
      );
    } catch (e, st) {
      debugPrint('🔥 set/items 생성 실패(기타): $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('세트 생성 실패(알 수 없는 오류)')),
      );
    }
  }


}

// 파일 바깥(하단)에 둡니다.
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
