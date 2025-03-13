import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:langarden_common/widgets/flashcard_controls.dart';
import 'package:langarden_common/widgets/flashcard_filter.dart';
import 'package:langarden_common/widgets/icon_button.dart'; // ✅ `AppIconButton`을 불러오기


class FlashcardStudyScreen extends StatefulWidget {
  final List<Map<String, String>> flashcards;

  const FlashcardStudyScreen({Key? key, required this.flashcards}) : super(key: key);

  @override
  _FlashcardStudyScreenState createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  int _currentIndex = 0;
  bool _showMeaning = false;
  late List<Map<String, String>> _cards;
  bool _autoPlay = false;
  bool _repeatEnabled = false;
  bool _shuffleEnabled = false;
  bool _ttsActive = false;
  bool _bothSidesAuto = false;
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _autoPlayTimer;
  final Duration _autoPlayInterval = const Duration(seconds: 2);


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
  }


  void _goToNextCard() {
    setState(() {
      if (_currentIndex < _cards.length - 1) {
        _currentIndex++;
        _showMeaning = false;
      } else if (_repeatEnabled) {
        _currentIndex = 0;
        _showMeaning = false;
      } else {
        _stopAutoPlay(); // ✅ 자동넘김 멈추기
      }
    });
  }

  void _goToPreviousCard() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
        _showMeaning = false;
      } else if (_repeatEnabled) {
        _currentIndex = _cards.length - 1;
        _showMeaning = false;
      }
    });
  }

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

  void _toggleRepeat() {
    setState(() {
      _repeatEnabled = !_repeatEnabled;
    });
  }

  void _toggleShuffle() {
    setState(() {
      _shuffleEnabled = !_shuffleEnabled;
      _cards.shuffle();
      _currentIndex = 0;
    });
  }

  void _toggleTts() {
    setState(() {
      _ttsActive = !_ttsActive;
    });
  }

  void _toggleBothSidesAuto() {
    setState(() {
      _bothSidesAuto = !_bothSidesAuto;
    });
  }

  /// ✅ 탭하면 앞/뒤(정답) 전환하는 함수 추가
  void _toggleMeaning() {
    setState(() {
      _showMeaning = !_showMeaning; // 🔹 앞/뒤 토글
    });
  }


  void _openFilterModal() async {
    await showModalBottomSheet(
      context: context,
      builder: (_) =>
          FlashcardFilter(
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
      _currentIndex = 0; // 🔹 맨 처음 카드로 이동
      _showMeaning = false;
    });
  }

  void _goToLastCard() {
    setState(() {
      _currentIndex = _cards.length - 1; // 🔹 맨 끝 카드로 이동
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
          // 🔹 좌우 화살표 버튼 추가 (맨 처음 / 이전 / 다음 / 맨 끝)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppIconButton(
                icon: Icons.first_page, // ⏭ 맨 끝 카드 버튼
                onPressed: _goToFirstCard,
              ),
              AppIconButton(
                icon: Icons.arrow_back,
                onPressed: _currentIndex > 0 || _repeatEnabled ? _goToPreviousCard : null,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      currentCard["text"] ?? "",
                      style: const TextStyle(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (_showMeaning)
                      Text(
                        currentCard["meaning"] ?? "",
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              AppIconButton(
                icon: Icons.arrow_forward,
                onPressed: _currentIndex < _cards.length - 1 || _repeatEnabled ? _goToNextCard : null,
              ),
              AppIconButton(
                icon: Icons.last_page, // ⏭ 맨 끝 카드 버튼
                onPressed: _goToLastCard,
              ),
            ],
          ),

          const SizedBox(height: 40),
          Text("카드 ${_currentIndex + 1} / ${_cards.length}",
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 40),

          // 🔹 하단 컨트롤바 (자동넘김, 반복, 셔플, TTS, 양면 읽기)
          FlashcardControls(
            autoPlay: _autoPlay,
            repeatEnabled: _repeatEnabled,
            shuffleEnabled: _shuffleEnabled,
            ttsActive: _ttsActive,
            bothSidesAuto: _bothSidesAuto,
            onToggleAutoPlay: _toggleAutoPlay,
            onToggleRepeat: _toggleRepeat,
            onToggleShuffle: _toggleShuffle,
            onToggleTts: _toggleTts,
            onToggleBothSidesAuto: _toggleBothSidesAuto,
            onOpenFilter: _openFilterModal,
          ),
        ],
      ),
    );
  }
}