import 'package:flutter/material.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final List<Map<String, String>> flashcards;

  /// flashcards의 각 요소는 {"text": "...", "meaning": "..."} 형태로 되어 있어야 함
  const FlashcardStudyScreen({Key? key, required this.flashcards}) : super(key: key);

  @override
  _FlashcardStudyScreenState createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  int _currentIndex = 0;
  bool _showMeaning = false;

  @override
  Widget build(BuildContext context) {
    // 현재 카드
    final currentCard = widget.flashcards[_currentIndex];
    final text = currentCard["text"] ?? "";
    final meaning = currentCard["meaning"] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("플래시카드 학습"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 카드 영역
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      // showMeaning가 true일 때만 의미 표시
                      if (_showMeaning)
                        Text(
                          meaning,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 현재 카드 인덱스 + 총 개수 표시
            Text("카드 ${_currentIndex + 1} / ${widget.flashcards.length}"),

            const SizedBox(height: 10),

            // 정답 보기/숨기기 버튼
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showMeaning = !_showMeaning;
                });
              },
              child: Text(_showMeaning ? "정답 숨기기" : "정답 보기"),
            ),

            const SizedBox(height: 10),

            // 이전/다음 이동 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _currentIndex > 0
                      ? () {
                    setState(() {
                      _currentIndex--;
                      _showMeaning = false;
                    });
                  }
                      : null,
                  child: const Text("이전"),
                ),
                ElevatedButton(
                  onPressed: _currentIndex < widget.flashcards.length - 1
                      ? () {
                    setState(() {
                      _currentIndex++;
                      _showMeaning = false;
                    });
                  }
                      : null,
                  child: const Text("다음"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
