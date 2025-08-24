import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:langarden_common/widgets/tts_controls.dart';
import 'package:langarden_common/widgets/icon_button.dart';
import 'package:audio_service/audio_service.dart';
import 'package:langbat/services/point_service.dart';
import 'package:cached_network_image/cached_network_image.dart';


class FlashcardStudyScreen extends StatefulWidget {
  final List<Map<String, dynamic>> flashcards;

  const FlashcardStudyScreen({super.key, required this.flashcards});

  @override
  _FlashcardStudyScreenState createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  int _playCount = 0;
  int _currentIndex = 0;
  bool _showMeaning = false;
  late List<Map<String, dynamic>> _cards;
  final bool _repeatEnabled = false;
  bool _shuffleEnabled = false;
  String _readingMode = "앞뒤";
  int _repeatCount = 1;
  int _timerMinutes = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  final FlutterTts _flutterTts = FlutterTts();
  String _frontLanguage = "es-ES";
  String _backLanguage = "ko-KR";
  double _fontSize = 28.0;
  double _ttsSpeed = 0.5;

  Timer? _countdownTimer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.flashcards);
    _flutterTts.setSpeechRate(_ttsSpeed);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
    _flutterTts.awaitSpeakCompletion(true);
    _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
    );
    loadTTSSettingsLocally();
  }

  Future<bool> _onWillPop() async {
    await _givePoints();
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("학습을 종료할까요?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog(
                  content: const Text("좋아요, 더 열심히 해봐요! 🔥"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (!mounted) return;
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text("확인"),
                    ),
                  ],
                ),
              );
            },
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await Future.delayed(const Duration(milliseconds: 100)); // context 안정화 대기
              if (!mounted) return;
              await _givePoints();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text(
                      "지금까지 플래시카드 ${_playCount}장을 학습했어요!\n+${_playCount}점이 적립됩니다 🎁",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("확인"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text("종료"),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
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
    final frontText = (currentCard["text"] ?? "") as String;       // 스페인어
    final backText  = (currentCard["meaning"] ?? "") as String;    // 한국어
    final imageUrl  = (currentCard["imageUrl"] ?? "") as String;   // ✅ 단일 이미지
    final displayText = _showMeaning ? backText : frontText;       // 텍스트만 전환
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isTablet = size.shortestSide >= 600;
    final imgFlex  = (isTablet && isLandscape) ? 8 : 7;
    final textFlex = (isTablet && isLandscape) ? 2 : 3;



    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text("플래시카드 학습")),
        body: Column(
          children: [
            // ⬇️ Row가 화면 높이를 확실히 배분받도록 Expanded로 감싼다
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch, // ⬅️ 자식들에게 유한한 높이 제공
                children: [
                  // 좌측 네비 버튼 스택(원하면 폭 고정)
                  SizedBox(
                    width: 56,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIconButton(icon: Icons.first_page, onPressed: _goToFirstCard),
                        const SizedBox(height: 8),
                        AppIconButton(
                          icon: Icons.arrow_back,
                          onPressed: _currentIndex > 0 || _repeatEnabled ? _goToPreviousCard : null,
                        ),
                      ],
                    ),
                  ),

                  // 가운데: 카드 표시 영역
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showMeaning = !_showMeaning),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                    Expanded(
                    flex: imgFlex,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Center(
                        child: imageUrl.isEmpty
                            ? const SizedBox.shrink()
                            : FractionallySizedBox(
                          // 아이패드 가로에서 이미지 더 크게
                          widthFactor: (isTablet && isLandscape) ? 0.72 : 0.9,
                          child: AspectRatio(
                            aspectRatio: 1.5, // width / height = 6 / 4
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover, // 비율 유지하며 채우기(가벼운 중앙 크롭)
                                placeholder: (ctx, _) =>
                                const Center(child: CircularProgressIndicator()),
                                errorWidget: (ctx, _, __) =>
                                const Icon(Icons.broken_image, size: 48),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

// 텍스트 Expanded는 flex: textFlex 로
                  Expanded(
                    flex: textFlex,
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          displayText,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                      ),
                    ),
                  ),

                ],
                        ),
                      ),
                    ),
                  ),

                  // 우측 네비 버튼 스택
                  SizedBox(
                    width: 56,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIconButton(
                          icon: Icons.arrow_forward,
                          onPressed: _currentIndex < _cards.length - 1 || _repeatEnabled
                              ? _goToNextCard
                              : null,
                        ),
                        const SizedBox(height: 8),
                        AppIconButton(icon: Icons.last_page, onPressed: _goToLastCard),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Text("카드 ${_currentIndex + 1} / ${_cards.length}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
          ],
        ),

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 0, top: 10.0),
          child: TTSControls(
            onToggleTTS: _toggleTTS,
            onChangeReadingMode: _changeReadingMode,
            onChangeSpeed: _changeSpeed,
            currentTtsSpeed: _ttsSpeed,
            onChangeRepeat: _changeRepeat,
            onToggleShuffle: _toggleShuffle,
            onChangeTimer: _setTimer,
            onCardSliderChanged: _onCardSliderChanged,
            onChangeFrontLanguage: _changeFrontLanguage,
            onChangeBackLanguage: _changeBackLanguage,
            onFontSizeChanged: _changeFontSize,
            currentCardIndex: _currentIndex,
            totalCards: _cards.length,
            isPlaying: _isPlaying,
            isPaused: _isPaused,
            frontLanguage: _frontLanguage,
            backLanguage: _backLanguage,
            remainingTime: _remainingTime,
          ),
        ),
      ),
    );
  }

  // === 아래 로직은 그대로 ===

  void _startTTS() async {
    if (_cards.isEmpty) return;

    setState(() {
      _isPlaying = true;
      _isPaused = false;
      _remainingTime = _timerMinutes > 0 ? Duration(minutes: _timerMinutes) : null;
    });

    if (_remainingTime != null) _startCountdown();

    int index = _currentIndex;
    while (_isPlaying) {
      if (_isPaused) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      if (_remainingTime != null && _remainingTime!.inSeconds <= 0) break;

      await _playCard(index);
      index = (index + 1) % _cards.length;
    }

    await _flutterTts.stop();
    _stopCountdown();

    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _remainingTime = null;
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

  Future<void> saveTTSSettingsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('readingMode', _readingMode);
    await prefs.setDouble('ttsSpeed', _ttsSpeed);
    await prefs.setInt('repeatCount', _repeatCount);
    await prefs.setBool('shuffleEnabled', _shuffleEnabled);
    await prefs.setInt('timerMinutes', _timerMinutes);
    await prefs.setString('frontLanguage', _frontLanguage);
    await prefs.setString('backLanguage', _backLanguage);
    await prefs.setDouble('fontSize', _fontSize);
  }

  Future<void> loadTTSSettingsLocally() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _readingMode = prefs.getString('readingMode') ?? _readingMode;
      _repeatCount = prefs.getInt('repeatCount') ?? _repeatCount;
      _shuffleEnabled = prefs.getBool('shuffleEnabled') ?? _shuffleEnabled;
      _timerMinutes = prefs.getInt('timerMinutes') ?? _timerMinutes;
      _frontLanguage = prefs.getString('frontLanguage') ?? _frontLanguage;
      _backLanguage = prefs.getString('backLanguage') ?? _backLanguage;
      _fontSize = prefs.getDouble('fontSize') ?? _fontSize;
      _ttsSpeed = prefs.getDouble('ttsSpeed') ?? _ttsSpeed;
    });

    _flutterTts.setSpeechRate(_ttsSpeed);
  }

  void _changeReadingMode(String mode) {
    setState(() => _readingMode = mode);
    saveTTSSettingsLocally();
  }

  void _changeSpeed(double speed) {
    setState(() => _ttsSpeed = speed);
    _flutterTts.setSpeechRate(speed);
    saveTTSSettingsLocally();
  }

  void _changeRepeat(int count) {
    setState(() => _repeatCount = count);
    saveTTSSettingsLocally();
  }

  void _toggleShuffle(bool enabled) {
    setState(() {
      _shuffleEnabled = enabled;
      if (enabled) {
        _cards.shuffle();
        _currentIndex = 0;
      }
    });
    saveTTSSettingsLocally();
  }

  void _setTimer(int minutes) {
    setState(() {
      _timerMinutes = minutes;
      if (_isPlaying || _isPaused) {
        _isPlaying = false;
        _isPaused = false;
        _flutterTts.stop();
        _stopCountdown();
        _remainingTime = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("타이머가 변경되어 재생이 중단되었습니다. 다시 재생해주세요.")),
        );
      }
    });
    saveTTSSettingsLocally();
  }

  void _changeFrontLanguage(String lang) {
    setState(() => _frontLanguage = lang);
    saveTTSSettingsLocally();
  }

  void _changeBackLanguage(String lang) {
    setState(() => _backLanguage = lang);
    saveTTSSettingsLocally();
  }

  void _changeFontSize(double newSize) {
    setState(() => _fontSize = newSize);
    saveTTSSettingsLocally();
  }

  void _onCardSliderChanged(int index) {
    setState(() => _currentIndex = index);
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

  void _goToPreviousCard() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else if (_repeatEnabled) {
        _currentIndex = _cards.length - 1;
      }
    });
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

  void _toggleTTS() {
    if (_isPlaying) {
      AudioService.pause();
      _pauseTTS();
    } else if (_isPaused) {
      AudioService.play();
      _resumeTTS();
    } else {
      AudioService.play();
      _startTTS();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == null || _remainingTime!.inSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isPlaying = false;
          _isPaused = false;
          _remainingTime = null;
        });
      } else {
        setState(() {
          _remainingTime = _remainingTime! - const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  Future<void> _playCard(int index) async {
    if (!mounted) return;
    if (index < 0 || index >= _cards.length) return;
    if (mounted) setState(() => _currentIndex = index);

    for (int i = 0; i < _repeatCount; i++) {
      if (!_isPlaying || _isPaused) break;

      try {
        final frontText = _cards[index]["text"] ?? "";
        final backText = _cards[index]["meaning"] ?? "";

        if (_readingMode == "앞뒤") {
          await _flutterTts.setLanguage(_frontLanguage);
          if (!mounted) return;
          setState(() => _showMeaning = false);
          await _flutterTts.speak(frontText);
          await Future.delayed(const Duration(milliseconds: 500));

          await _flutterTts.setLanguage(_backLanguage);
          if (!mounted) return;
          setState(() => _showMeaning = true);
          await _flutterTts.speak(backText);
        } else if (_readingMode == "뒤앞") {
          await _flutterTts.setLanguage(_backLanguage);
          if (!mounted) return;
          setState(() => _showMeaning = true);
          await _flutterTts.speak(backText);
          await Future.delayed(const Duration(milliseconds: 500));

          await _flutterTts.setLanguage(_frontLanguage);
          if (!mounted) return;
          setState(() => _showMeaning = false);
          await _flutterTts.speak(frontText);
        } else if (_readingMode == "앞면만") {
          await _flutterTts.setLanguage(_frontLanguage);
          if (!mounted) return;
          setState(() => _showMeaning = false);
          await _flutterTts.speak(frontText);
        } else if (_readingMode == "뒷면만") {
          await _flutterTts.setLanguage(_backLanguage);
          if (!mounted) return;
          setState(() => _showMeaning = true);
          await _flutterTts.speak(backText);
        }
      } catch (e) {
        debugPrint("Error in _playCard: $e");
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }
    _playCount++;

    if (_currentIndex == _cards.length - 1) {
      await _givePoints();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("학습 완료!"),
            content: const Text("모든 카드를 학습했어요."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("확인"),
              ),
            ],
          ),
        );
      }
      return;
    }
  }

  Future<void> _givePoints() async {
    if (_playCount == 0) return;
    await PointService.addPoint(
      type: '플래시카드 학습',
      amount: _playCount,
      description: '플래시카드 $_playCount장 학습',
    );
    _playCount = 0;
  }
}
