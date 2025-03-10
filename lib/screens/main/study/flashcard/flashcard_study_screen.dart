import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final List<Map<String, String>> flashcards;

  /// flashcards의 각 요소는 {"text": "...", "meaning": "..."} 형태를 가정
  const FlashcardStudyScreen({Key? key, required this.flashcards}) : super(key: key);

  @override
  _FlashcardStudyScreenState createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  late List<Map<String, String>> _originalCards;
  late List<Map<String, String>> _cards;

  int _currentIndex = 0;
  bool _showMeaning = false;

  // 자동넘김 / 반복 / 셔플
  bool _autoPlay = false;
  Timer? _autoPlayTimer;
  final Duration _autoPlayInterval = const Duration(seconds: 2);
  bool _repeatEnabled = false;
  bool _shuffleEnabled = false;

  // TTS 관련
  final FlutterTts _flutterTts = FlutterTts();
  bool _ttsActive = false; // TTS on/off 상태

  @override
  void initState() {
    super.initState();
    _originalCards = List.from(widget.flashcards);
    _cards = List.from(widget.flashcards);

    // TTS 기본 옵션
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  // 다음 카드
  void _goToNextCard() {
    setState(() {
      if (_currentIndex < _cards.length - 1) {
        _currentIndex++;
        _showMeaning = false;
      } else {
        if (_repeatEnabled && _cards.isNotEmpty) {
          _currentIndex = 0;
          _showMeaning = false;
        } else {
          _stopAutoPlay();
        }
      }
    });
    // 카드 바뀐 뒤 TTS 재생
    if (_ttsActive) {
      _speakCurrent();
    }
  }

  // 이전 카드
  void _goToPreviousCard() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
        _showMeaning = false;
      } else {
        if (_repeatEnabled && _cards.isNotEmpty) {
          _currentIndex = _cards.length - 1;
          _showMeaning = false;
        }
      }
    });
    if (_ttsActive) {
      _speakCurrent();
    }
  }

  // 앞/뒤 토글 (tap)
  void _toggleMeaning() {
    setState(() {
      _showMeaning = !_showMeaning;
    });
    // 앞뒤 바뀐 뒤 TTS
    if (_ttsActive) {
      _speakCurrent();
    }
  }

  // 스와이프
  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    if (details.primaryVelocity! < 0) {
      _goToNextCard();
    } else if (details.primaryVelocity! > 0) {
      _goToPreviousCard();
    }
  }

  // 자동넘김
  void _startAutoPlay() {
    setState(() {
      _autoPlay = true;
    });
    _autoPlayTimer = Timer.periodic(_autoPlayInterval, (_) => _goToNextCard());
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    setState(() {
      _autoPlay = false;
    });
  }

  void _toggleAutoPlay() {
    if (_autoPlay) {
      _stopAutoPlay();
    } else {
      _startAutoPlay();
    }
  }

  // 반복
  void _toggleRepeat() {
    setState(() {
      _repeatEnabled = !_repeatEnabled;
    });
  }

  // 셔플
  void _toggleShuffle() {
    setState(() {
      _shuffleEnabled = !_shuffleEnabled;
      if (_shuffleEnabled) {
        _cards.shuffle();
        _currentIndex = 0;
        _showMeaning = false;
      } else {
        _cards = List.from(_originalCards);
        _currentIndex = 0;
        _showMeaning = false;
      }
    });
    if (_ttsActive) {
      _speakCurrent();
    }
  }

  // TTS on/off
  void _toggleTts() {
    setState(() {
      _ttsActive = !_ttsActive;
    });
    if (_ttsActive) {
      // 켜짐과 동시에 현재 카드 음성 재생
      _speakCurrent();
    } else {
      // 끄면 TTS 중단
      _flutterTts.stop();
    }
  }

  // 현재 화면(앞/뒤)에 맞춰 TTS로 읽기
  Future<void> _speakCurrent() async {
    await _flutterTts.stop(); // 이전 음성 중단
    final current = _cards[_currentIndex];

    if (!_showMeaning) {
      // 앞면(스페인어 가정)
      final esText = current["text"] ?? "";
      if (esText.isNotEmpty) {
        await _flutterTts.setLanguage("es-ES");
        await _flutterTts.speak(esText);
      }
    } else {
      // 뒷면(한국어)
      final koText = current["meaning"] ?? "";
      if (koText.isNotEmpty) {
        await _flutterTts.setLanguage("ko-KR");
        await _flutterTts.speak(koText);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("플래시카드 학습")),
        body: const Center(child: Text("학습할 카드가 없습니다.")),
      );
    }

    final currentCard = _cards[_currentIndex];
    final text = currentCard["text"] ?? "";
    final meaning = currentCard["meaning"] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("플래시카드 학습"),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _toggleMeaning,
        onHorizontalDragEnd: _handleSwipe,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 스와이프 힌트
              Row(
                children: [
                  if (_currentIndex > 0 || _repeatEnabled)
                    const Icon(Icons.arrow_left, size: 40, color: Colors.grey),
                  const Spacer(),
                  if (_currentIndex < _cards.length - 1 || _repeatEnabled)
                    const Icon(Icons.arrow_right, size: 40, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 20),

              // 앞면/뒷면 텍스트
              Text(
                text,
                style: const TextStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_showMeaning)
                Text(
                  meaning,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 40),
              Text(
                "카드 ${_currentIndex + 1} / ${_cards.length}",
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 40),

              // 하단 아이콘들 (자동넘김, 반복, 셔플, TTS)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_autoPlay ? Icons.pause_circle : Icons.play_circle, size: 40),
                    onPressed: _toggleAutoPlay,
                  ),
                  IconButton(
                    icon: Icon(_repeatEnabled ? Icons.repeat_on : Icons.repeat, size: 40),
                    onPressed: _toggleRepeat,
                  ),
                  IconButton(
                    icon: Icon(_shuffleEnabled ? Icons.shuffle_on : Icons.shuffle, size: 40),
                    onPressed: _toggleShuffle,
                  ),

                  // TTS On/Off
                  IconButton(
                    icon: Icon(
                      _ttsActive ? Icons.volume_up : Icons.volume_off,
                      size: 40,
                    ),
                    onPressed: _toggleTts,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
