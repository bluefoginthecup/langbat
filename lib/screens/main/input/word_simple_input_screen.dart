import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WordSimpleInputScreen extends StatefulWidget {
  const WordSimpleInputScreen({Key? key}) : super(key: key);

  @override
  _WordSimpleInputScreenState createState() => _WordSimpleInputScreenState();
}

class _WordSimpleInputScreenState extends State<WordSimpleInputScreen> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();

  Future<void> _saveWord() async {
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("단어를 입력하세요.")),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('words').doc(word).set({
        "word": word,
        "meaning": meaning,
        "createdAt": FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("단어 데이터가 저장되었습니다.")),
      );
      _wordController.clear();
      _meaningController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("단어 간단 입력")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _wordController,
              decoration: const InputDecoration(
                labelText: "단어 (예: apple)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _meaningController,
              decoration: const InputDecoration(
                labelText: "뜻 (예: 사과)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveWord,
              child: const Text("저장"),
            ),
          ],
        ),
      ),
    );
  }
}
