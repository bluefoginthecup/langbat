import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:langarden_common/widgets/flashcard_controls.dart';
import 'package:langarden_common/widgets/flashcard_filter.dart';
import 'package:langarden_common/widgets/icon_button.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final List<Map<String, String>> flashcards;

  const FlashcardStudyScreen({Key? key, required this.flashcards})
      : super(key: key);

  @override
  _FlashcardStudyScreenState createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  int _currentIndex = 0;
  bool _showMeaning = false;
  late List<Map<String, String>> _cards;
  bool _repeatEnabled = false;
  bool _shuffleEnabled = false;
  String _readingMode = "앞면만";

  // TTS 관련 변수
  int _repeatCount = 1;
  int _timerMinutes = 0; // 전체 재생 시간(분); 0이면 무제한
  bool _isPlaying = false;
  bool _isPaused = false;
  DateTime? _playbackStartTime;
  Duration _remainingPlaybackDuration = Duration.zero;

  final FlutterTts _flutterTts = FlutterTts();

  Set<String> _selectedPersons = {};
  Set<String> _selectedTenses = {};
  Set<String> _selectedExamples = {};

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
    print("DEBUG => 읽기 모드 변경: $mode");
    setState(() {
      _readingMode = mode;
    });
  }

  void _changeSpeed(double speed) {
    print("DEBUG => TTS 속도 변경: ${speed}x");
    _flutterTts.setSpeechRate(speed);
  }

  void _changeRepeat(int count) {
    print("DEBUG => 반복 횟수 변경: $count");
    setState(() {
      _repeatCount = count;
    });
  }

  void _toggleShuffle(bool enabled) {
    print("DEBUG => 셔플 모드: ${enabled ? 'ON' : 'OFF'}");
    setState(() {
      _shuffleEnabled = enabled;
      if (_shuffleEnabled) {
        _cards.shuffle();
        _currentIndex = 0;
      }
    });
  }

  void _setTimer(int minutes) {
    print("DEBUG => 총 재생 시간 설정: $minutes 분");
    setState(() {
      _timerMinutes = minutes;
    });
  }

  void _onCardSliderChanged(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  // 재생/일시정지 토글 함수
  void _toggleTTS() {
    if (_isPlaying) {
      _pauseTTS();
    } else if (_isPaused) {
      _resumeTTS();
    } else {
      _startTTS();
    }
  }

  // 한 카드에 대해 TTS를 수행하는 함수
  Future<void> _playCard(int index) async {
    setState(() {
      _currentIndex = index;
    });
    for (int i = 0; i < _repeatCount; i++) {
      if (!_isPlaying || _isPaused) break;
      if (_readingMode == "앞면만") {
        setState(() {
          _showMeaning = false;
        });
        await _flutterTts.speak(_cards[index]["text"]!);
      } else if (_readingMode == "뒷면만") {
        setState(() {
          _showMeaning = true;
        });
        await _flutterTts.speak(_cards[index]["meaning"]!);
      } else if (_readingMode == "앞뒤 번갈아 읽기") {
        setState(() {
          _showMeaning = false;
        });
        await _flutterTts.speak(_cards[index]["text"]!);
        await Future.delayed(Duration(milliseconds: 500));
        setState(() {
          _showMeaning = true;
        });
        await _flutterTts.speak(_cards[index]["meaning"]!);
        await Future.delayed(Duration(milliseconds: 700));
      }
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  // 전체 재생 시간 동안 카드들을 순차적으로 읽음
  void _startTTS() async {
    if (_cards.isEmpty) return;
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });
    Duration totalDuration = _timerMinutes > 0
        ? Duration(minutes: _timerMinutes)
        : Duration(hours: 9999);
    DateTime playbackStart = DateTime.now();

    int index = _currentIndex;
    while (_isPlaying) {
      if (_isPaused) {
        await Future.delayed(Duration(milliseconds: 200));
        continue;
      }
      if (DateTime.now().difference(playbackStart) >= totalDuration) break;
      await _playCard(index);
      index = (index + 1) % _cards.length;
    }
    _flutterTts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
    print("DEBUG => TTS 재생 종료");
  }

  void _pauseTTS() {
    if (!_isPlaying) return;
    setState(() {
      _isPaused = true;
      _isPlaying = false;
    });
    _flutterTts.stop();
    if (_playbackStartTime != null) {
      Duration elapsed = DateTime.now().difference(_playbackStartTime!);
      _remainingPlaybackDuration = _remainingPlaybackDuration - elapsed;
    }
    print("DEBUG => TTS 일시정지");
  }

  void _resumeTTS() {
    if (!_isPaused) return;
    setState(() {
      _isPaused = false;
      _isPlaying = true;
    });
    _startTTS();
    print("DEBUG => TTS 재개");
  }

  void _openFilterModal() async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => FlashcardFilter(
        selectedPersons: _selectedPersons,
        selectedTenses: _selectedTenses,
        selectedExamples: _selectedExamples,
        onFilterChanged: (persons, tenses, examples) {
          setState(() {
            _selectedPersons = persons;
            _selectedTenses = tenses;
            _selectedExamples = examples;
          });
        },
      ),
    );
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
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("플래시카드 학습")),
        body: const Center(child: Text("학습할 카드가 없습니다.")),
      );
    }

    final currentCard = _cards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("플래시카드 학습"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 좌우 이동 버튼
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
                      print("DEBUG => 카드 토글됨! _showMeaning: $_showMeaning");
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showMeaning
                            ? currentCard["meaning"]!
                            : currentCard["text"]!,
                        style: const TextStyle(fontSize: 28),
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
          Text(
            "카드 ${_currentIndex + 1} / ${_cards.length}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 40),
          // FlashcardControls 위젯 (슬라이더, 토글 아이콘 등)
          FlashcardControls(
            onToggleTTS: _toggleTTS,
            onChangeReadingMode: _changeReadingMode,
            onChangeSpeed: _changeSpeed,
            onChangeRepeat: _changeRepeat,
            onToggleShuffle: _toggleShuffle,
            onChangeTimer: _setTimer,
            onCardSliderChanged: _onCardSliderChanged,
            currentCardIndex: _currentIndex,
            totalCards: _cards.length,
            isPlaying: _isPlaying,
            isPaused: _isPaused,
          ),
        ],
      ),
    );
  }
}
