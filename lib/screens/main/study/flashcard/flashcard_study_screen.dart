import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final List<Map<String, String>> flashcards;

  const FlashcardStudyScreen({Key? key, required this.flashcards}) : super(key: key);

  @override
  _FlashcardStudyScreenState createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  // 카드 목록
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

  // 일반 TTS on/off (수동 재생할 때만 쓸 수도 있고,
  // 여기서는 _bothSidesAuto가 꺼져 있을 때 탭/스와이프 시 TTS 가능하도록 남겨두거나,
  // 예시에서는 그냥 보여주기용 변수를 둠)
  bool _ttsActive = false;

  // **양면 자동 읽기** 모드
  bool _bothSidesAuto = false;

  final FlutterTts _flutterTts = FlutterTts();
  // 0 = 앞면(스페인어), 1 = 뒷면(한국어)
  int _readingSide = 0;

  @override
  void initState() {
    super.initState();
    _originalCards = List.from(widget.flashcards);
    _cards = List.from(widget.flashcards);

    // TTS 기본 설정
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    // TTS 읽기 완료 콜백
    // 이게 핵심! 한 면을 다 읽으면 -> 다음 면/카드로 자동 진행
    _flutterTts.setCompletionHandler(_onTtsCompleted);
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  // TTS 한 면 읽기 완료 시
  Future<void> _onTtsCompleted() async {
    // 양면 자동 읽기 모드가 켜져 있어야 동작
    if (!_bothSidesAuto) return;

    // readingSide == 0 -> 방금 스페인어 읽음 → 뒷면으로 뒤집고 한국어 읽기
    // readingSide == 1 -> 방금 한국어 읽음 → 다음 카드로 이동
    if (_readingSide == 0) {
      setState(() {
        _showMeaning = true; // 뒷면 표시
      });
      _readingSide = 1;
      // 바로 한국어 읽기 시작
      await _speakCurrentSide();
    } else {
      // readingSide == 1: 방금 한국어 읽음 → 다음 카드
      _goToNextCard(); // 다음 카드로 이동, 이 안에서 _readingSide=0으로 초기화
    }
  }

  // 한 면 읽기 (readingSide 보고 스페인어인지 한국어인지 결정)
  Future<void> _speakCurrentSide() async {
    // 혹시 중간에 TTS가 꺼졌으면 중단
    if (!_bothSidesAuto) return;

    // 현재 카드
    final current = _cards[_currentIndex];
    if (_readingSide == 0) {
      // 앞면 (스페인어)
      final esText = current["text"] ?? "";
      if (esText.isNotEmpty) {
        await _flutterTts.setLanguage("es-ES");
        await _flutterTts.speak(esText);
      } else {
        // 스페인어가 비어있으면 곧바로 completion flow로 넘어가도록
        _onTtsCompleted();
      }
    } else {
      // 뒷면 (한국어)
      final koText = current["meaning"] ?? "";
      if (koText.isNotEmpty) {
        await _flutterTts.setLanguage("ko-KR");
        await _flutterTts.speak(koText);
      } else {
        _onTtsCompleted();
      }
    }
  }

  // 다음 카드
  void _goToNextCard() {
    setState(() {
      if (_currentIndex < _cards.length - 1) {
        _currentIndex++;
        _showMeaning = false;
      } else {
        // 마지막 카드
        if (_repeatEnabled && _cards.isNotEmpty) {
          _currentIndex = 0;
          _showMeaning = false;
        } else {
          _stopAutoPlay();
        }
      }
      _readingSide = 0;
    });
    // 양면자동모드 -> 새 카드의 앞면 읽기
    if (_bothSidesAuto) {
      _speakCurrentSide();
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
      _readingSide = 0;
    });
    if (_bothSidesAuto) {
      _speakCurrentSide();
    }
  }

  // 탭 -> 앞뒤 토글 (수동 모드)
  // 양면자동모드가 켜져 있지 않을 때만 의미 있음
  // (원하면 양면 모드 중 탭은 무시해도 됨)
  void _toggleMeaning() {
    if (_bothSidesAuto) {
      // 양면자동모드일 때는 탭으로는 뒤집지 않는 편이 자연스러울 수도.
      // 여기서는 그냥 무시:
      return;
    }
    setState(() {
      _showMeaning = !_showMeaning;
    });
    if (_ttsActive) {
      _speakOneShot();
    }
  }

  // 스와이프 -> 이전/다음
  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    if (details.primaryVelocity! < 0) {
      _goToNextCard();
    } else if (details.primaryVelocity! > 0) {
      _goToPreviousCard();
    }
  }

  // 수동 TTS (양면 자동아님) -> 앞/뒤 하나만 읽기
  Future<void> _speakOneShot() async {
    await _flutterTts.stop();
    final current = _cards[_currentIndex];
    if (!_showMeaning) {
      // 스페인어
      final esText = current["text"] ?? "";
      if (esText.isNotEmpty) {
        await _flutterTts.setLanguage("es-ES");
        await _flutterTts.speak(esText);
      }
    } else {
      // 한국어
      final koText = current["meaning"] ?? "";
      if (koText.isNotEmpty) {
        await _flutterTts.setLanguage("ko-KR");
        await _flutterTts.speak(koText);
      }
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
      _readingSide = 0;
    });
    // 양면모드면 새 카드 읽기
    if (_bothSidesAuto) {
      _speakCurrentSide();
    }
  }

  // 일반 TTS on/off (수동 재생)
  void _toggleTtsActive() {
    setState(() {
      _ttsActive = !_ttsActive;
    });
    if (!_ttsActive) {
      _flutterTts.stop();
    }
  }

  // 양면자동모드 on/off
  void _toggleBothSidesAuto() async {
    setState(() {
      _bothSidesAuto = !_bothSidesAuto;
      _readingSide = 0;
    });
    if (!_bothSidesAuto) {
      // 모드 꺼졌으면 TTS 중단
      await _flutterTts.stop();
    } else {
      // 모드 켜면 현재 카드 앞면부터 읽기 시작
      if (_cards.isNotEmpty) {
        _showMeaning = false;
        await _speakCurrentSide();
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

              // 앞면/뒷면
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

              // 하단 아이콘 모음
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  // 자동넘김
                  IconButton(
                    icon: Icon(_autoPlay ? Icons.pause_circle : Icons.play_circle, size: 40),
                    onPressed: _toggleAutoPlay,
                  ),
                  // 반복
                  IconButton(
                    icon: Icon(_repeatEnabled ? Icons.repeat_on : Icons.repeat, size: 40),
                    onPressed: _toggleRepeat,
                  ),
                  // 셔플
                  IconButton(
                    icon: Icon(_shuffleEnabled ? Icons.shuffle_on : Icons.shuffle, size: 40),
                    onPressed: _toggleShuffle,
                  ),
                  // 일반 TTS 수동 on/off
                  IconButton(
                    icon: Icon(_ttsActive ? Icons.volume_up : Icons.volume_off, size: 40),
                    onPressed: _toggleTtsActive,
                  ),
                  // **양면 자동읽기** on/off
                  IconButton(
                    icon: Icon(_bothSidesAuto ? Icons.swap_horiz : Icons.swap_horizontal_circle, size: 40),
                    tooltip: _bothSidesAuto ? "양면 자동읽기: ON" : "양면 자동읽기: OFF",
                    onPressed: _toggleBothSidesAuto,
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
