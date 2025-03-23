import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SentenceSimpleInputScreen extends StatefulWidget {
  const SentenceSimpleInputScreen({super.key});

  @override
  _SentenceSimpleInputScreenState createState() => _SentenceSimpleInputScreenState();
}

class _SentenceSimpleInputScreenState extends State<SentenceSimpleInputScreen> {
  final TextEditingController _sentenceController = TextEditingController();

  Future<void> _saveSentences() async {
    final input = _sentenceController.text;
    // 각 줄을 하나의 문장으로 간주 (빈 줄은 제외)
    final sentences = input.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    if (sentences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("문장을 하나 이상 입력하세요.")),
      );
      return;
    }

    try {
      // Firestore 배치 쓰기를 사용하여 여러 문장을 한 번에 저장
      final batch = FirebaseFirestore.instance.batch();
      final collectionRef = FirebaseFirestore.instance.collection('sentences');
      for (var sentence in sentences) {
        final docRef = collectionRef.doc(); // 자동 생성 ID 사용
        batch.set(docRef, {
          "sentence": sentence,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("문장 데이터가 저장되었습니다.")),
      );
      _sentenceController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    }
  }

  @override
  void dispose() {
    _sentenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("문장 간단 입력")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("문장을 줄바꿈으로 구분하여 입력하세요:"),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _sentenceController,
                decoration: const InputDecoration(
                  labelText: "문장 입력",
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveSentences,
              child: const Text("저장"),
            ),
          ],
        ),
      ),
    );
  }
}
