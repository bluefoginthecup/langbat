import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:langarden_common/widgets/tts_controls.dart';
import 'package:langarden_common/widgets/icon_button.dart';
import 'package:audio_service/audio_service.dart';


/// 변경됨: Firestore 데이터가 top-level에 "text"와 "meaning" 필드를 두고 있다고 가정
String getFrontDisplay(Map<String, dynamic> card) {
  // 변경됨: card["content"] 대신 card 자체의 "text"를 확인
  // 만약 여러 시제를 합쳐야 한다면, 별도 로직 추가
  if (card["text"] != null && card["text"].toString().isNotEmpty) {
    return card["text"].toString();
  }
  // 필요하다면 fallback으로 card["verb"] 등을 확인
  return "";
}

String getBackDisplay(Map<String, dynamic> card) {
  // 변경됨: card["content"] 대신 card 자체의 "meaning"을 확인
  if (card["meaning"] != null && card["meaning"].toString().isNotEmpty) {
    return card["meaning"].toString();
  }
  return "";
}

String capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : "";

class FlashcardStudyScreen extends StatefulWidget {
  final List<Map<String, dynamic>> flashcards;

  const FlashcardStudyScreen({super.key, required this.flashcards});

  @override
  _FlashcardStudyScreenState createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  double _fontSize = 28.0;
  int _currentIndex = 0;
  bool _showMeaning = false;
  late List<Map<String, dynamic>> _cards;
  final bool _repeatEnabled = false;
  bool _shuffleEnabled = false;
  String _readingMode = "앞뒤"; // "앞면만", "뒷면만", "앞뒤 번갈아 읽기"

  int _repeatCount = 1;
  int _timerMinutes = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  final FlutterTts _flutterTts = FlutterTts();

  // 사용자가 선택한 TTS 언어
  String _frontLanguage = "es-ES";
  String _backLanguage = "ko-KR";

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.flashcards);
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
    _flutterTts.awaitSpeakCompletion(true);
    _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
    );
  }

  void _goToNextCard() {
    setState(() {
      if (_currentIndex < _cards.length - 1) {
        _currentIndex++;
      } else if (_repeatEnabled) {
        _currentIndex = 0;
      }
    });
  }

  void _goToPreviousCard() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else if (_repeatEnabled) {
        _currentIndex = _cards.length - 1;
      }
    });
  }

  void _changeReadingMode(String mode) {
    setState(() {
      _readingMode = mode;
    });
  }

  void _changeSpeed(double speed) {
    _flutterTts.setSpeechRate(speed);
  }

  void _changeRepeat(int count) {
    setState(() {
      _repeatCount = count;
    });
  }

  void _toggleShuffle(bool enabled) {
    setState(() {
      _shuffleEnabled = enabled;
      if (_shuffleEnabled) {
        _cards.shuffle();
        _currentIndex = 0;
      }
    });
  }

  void _setTimer(int minutes) {
    setState(() {
      _timerMinutes = minutes;
    });
  }

  void _onCardSliderChanged(int newIndex) {
    debugPrint("DEBUG: _onCardSliderChanged 호출됨. newIndex: $newIndex");
    setState(() {
      _currentIndex = newIndex;
    });
  }

  void _changeFrontLanguage(String lang) {
    setState(() {
      _frontLanguage = lang;
    });
  }

  void _changeBackLanguage(String lang) {
    setState(() {
      _backLanguage = lang;
    });
  }


  void _toggleTTS() {
    debugPrint("DEBUG: _toggleTTS 호출됨. isPlaying: $_isPlaying, isPaused: $_isPaused");

    if (_isPlaying) {
      AudioService.pause();// 백그라운드 제어
      _pauseTTS();        // 기존 TTS 중지
    } else if (_isPaused) {
      AudioService.play();     // 백그라운드 제어
      _resumeTTS();       // 기존 TTS 재개
    } else {
      AudioService.play();     // 백그라운드 제어
      _startTTS();        // 기존 TTS 시작
    }
  }


  Future<void> _playCard(int index) async {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
    for (int i = 0; i < _repeatCount; i++) {
      if (!_isPlaying || _isPaused) break;

      try {
        final frontText = getFrontDisplay(_cards[index]);
        final backText = getBackDisplay(_cards[index]);

        if (_readingMode == "앞뒤") {
          await _flutterTts.setLanguage(_frontLanguage);
          setState(() => _showMeaning = false);
          await _flutterTts.speak(frontText);
          await Future.delayed(const Duration(milliseconds: 500));

          await _flutterTts.setLanguage(_backLanguage);
          setState(() => _showMeaning = true);
          await _flutterTts.speak(backText);

        } else if (_readingMode == "뒤앞") {
          await _flutterTts.setLanguage(_backLanguage);
          setState(() => _showMeaning = true);
          await _flutterTts.speak(backText);
          await Future.delayed(const Duration(milliseconds: 500));

          await _flutterTts.setLanguage(_frontLanguage);
          setState(() => _showMeaning = false);
          await _flutterTts.speak(frontText);

        } else if (_readingMode == "앞면만") {
          await _flutterTts.setLanguage(_frontLanguage);
          setState(() => _showMeaning = false);
          await _flutterTts.speak(frontText);

        } else if (_readingMode == "뒷면만") {
          await _flutterTts.setLanguage(_backLanguage);
          setState(() => _showMeaning = true);
          await _flutterTts.speak(backText);
        }
      } catch (e) {
        debugPrint("Error in _playCard: $e");
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void _startTTS() async {
    if (_cards.isEmpty) return;
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });
    Duration totalDuration = _timerMinutes > 0
        ? Duration(minutes: _timerMinutes)
        : const Duration(hours: 9999);
    DateTime playbackStart = DateTime.now();
    int index = _currentIndex;
    while (_isPlaying) {
      if (_isPaused) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }
      if (DateTime.now().difference(playbackStart) >= totalDuration) break;
      await _playCard(index);
      index = (index + 1) % _cards.length;
    }
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
  }

  void _pauseTTS() {
    if (!_isPlaying) return;
    setState(() {
      _isPaused = true;
      _isPlaying = false;
    });
    _flutterTts.stop();
  }

  void _resumeTTS() {
    if (!_isPaused) return;
    setState(() {
      _isPaused = false;
      _isPlaying = true;
    });
    _startTTS();
  }

  void _goToFirstCard() {
    setState(() {
      _currentIndex = 0;
      _showMeaning = false;
    });
  }

  void _goToLastCard() {
    setState(() {
      _currentIndex = _cards.length - 1;
      _showMeaning = false;
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
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

    // 변경됨: top-level "text"/"meaning" 필드를 사용
    String displayText = _showMeaning
        ? getBackDisplay(currentCard)
        : getFrontDisplay(currentCard);

    return Scaffold(
      appBar: AppBar(
        title: const Text("플래시카드 학습"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 상단 네비게이션
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppIconButton(
                icon: Icons.first_page,
                onPressed: _goToFirstCard,
              ),
              AppIconButton(
                icon: Icons.arrow_back,
                onPressed: _currentIndex > 0 || _repeatEnabled
                    ? _goToPreviousCard
                    : null,
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      _showMeaning = !_showMeaning;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayText,
                        style: TextStyle(fontSize: _fontSize),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              AppIconButton(
                icon: Icons.arrow_forward,
                onPressed: _currentIndex < _cards.length - 1 || _repeatEnabled
                    ? _goToNextCard
                    : null,
              ),
              AppIconButton(
                icon: Icons.last_page,
                onPressed: _goToLastCard,
              ),
            ],
          ),
          const SizedBox(height: 40),
          // 현재 카드 인덱스 표시
          Text(
            "카드 ${_currentIndex + 1} / ${_cards.length}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 40),
          // TTS 컨트롤 패널
          TTSControls(
            onToggleTTS: _toggleTTS,
            onChangeReadingMode: _changeReadingMode,
            onChangeSpeed: _changeSpeed,
            onChangeRepeat: _changeRepeat,
            onToggleShuffle: _toggleShuffle,
            onChangeTimer: _setTimer,
            onCardSliderChanged: _onCardSliderChanged,
            onChangeFrontLanguage: _changeFrontLanguage,
            onChangeBackLanguage: _changeBackLanguage,
            onFontSizeChanged: (newSize) {
              setState(() {
                _fontSize = newSize;
              });
            },
            currentCardIndex: _currentIndex,
            totalCards: _cards.length,
            isPlaying: _isPlaying,
            isPaused: _isPaused,
            frontLanguage: _frontLanguage,
            backLanguage: _backLanguage,
          ),
        ],
      ),
    );
  }
}

