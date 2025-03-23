import 'package:flutter/material.dart';
import 'verb_bulk_input_screen.dart';
import 'verb_simple_input_screen.dart'; // 동사 간단입력 화면 파일
import 'sentence_simple_input_screen.dart'; // 문장 간단입력 화면 파일
import 'word_simple_input_screen.dart'; // 단어 간단입력 화면 파일


class InputScreen extends StatelessWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("입력")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 대량 입력 선택 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DataBatchInputSelectionScreen(),
                  ),
                );
              },
              child: const Text("데이터 대량입력"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 간단 입력 페이지로 이동 (추후 구현)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SimpleInputScreen(),
                  ),
                );
              },
              child: const Text("간단 입력"),
            ),
          ],
        ),
      ),
    );
  }
}

class DataBatchInputSelectionScreen extends StatelessWidget {
  const DataBatchInputSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("데이터 대량입력")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 동사 대량입력 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VerbBulkInputScreen(

                    ),
                  ),
                );
              },
              child: const Text("동사"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 문장 대량입력 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SentenceBatchInputScreen(),
                  ),
                );
              },
              child: const Text("문장"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 단어 대량입력 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WordBatchInputScreen(),
                  ),
                );
              },
              child: const Text("단어"),
            ),
          ],
        ),
      ),
    );
  }
}



// 문장 대량입력 페이지 (예시)
class SentenceBatchInputScreen extends StatelessWidget {
  const SentenceBatchInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("문장 대량입력")),
      body: Center(child: Text("여기에 문장 대량입력 UI를 구현합니다.")),
    );
  }
}

// 단어 대량입력 페이지 (예시)
class WordBatchInputScreen extends StatelessWidget {
  const WordBatchInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("단어 대량입력")),
      body: Center(child: Text("여기에 단어 대량입력 UI를 구현합니다.")),
    );
  }
}

// 간단 입력 페이지 (예시)
class SimpleInputScreen extends StatelessWidget {
  const SimpleInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(title: const Text("간단 입력")),
  body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
  children: [
  // 카테고리 선택 버튼들
  Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
  ElevatedButton(
  onPressed: () {
  Navigator.push(
  context,
  MaterialPageRoute(
  builder: (_) => const VerbSimpleInputScreen(),
  ),
  );
  },
  child: const Text("동사"),
  ),
  ElevatedButton(
  onPressed: () {
  Navigator.push(
  context,
  MaterialPageRoute(
  builder: (_) => const SentenceSimpleInputScreen(),
  ),
  );
  },
  child: const Text("문장"),
  ),
  ElevatedButton(
  onPressed: () {
  Navigator.push(
  context,
  MaterialPageRoute(
  builder: (_) => const WordSimpleInputScreen(),
  ),
  );
  },
  child: const Text("단어"),
  ),
  ],
  ),
  const SizedBox(height: 20),
  const Text("원하는 입력 유형을 선택하세요."),
  ],
  ),
  ),
  );
  }
  }

