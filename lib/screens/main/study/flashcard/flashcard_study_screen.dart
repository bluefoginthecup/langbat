import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:langarden_common/widgets/tts_controls.dart';
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
  bool get _ttsEnabled => !Platform.isMacOS;
  String _frontLanguage = "es-ES";
  String _backLanguage = "ko-KR";
  List<Map<String, String>> _availableVoices = [];
  Map<String, String>? _frontVoice;
  Map<String, String>? _backVoice;
  double _fontSize = 28.0;
  double _ttsSpeed = 0.5;

  Timer? _countdownTimer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.flashcards);
    if (!_ttsEnabled) {
      _initializeTTSSettings();
      return;
    }
    _flutterTts.setSpeechRate(_ttsSpeed);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
    _flutterTts.awaitSpeakCompletion(true);
    _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
    );
    _initializeTTSSettings();
  }

  Future<void> _initializeTTSSettings() async {
    await loadTTSSettingsLocally();
    await _loadAvailableVoices();
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("학습을 종료할까요?"),
        content: Text(
          _playCount > 0
              ? "지금까지 플래시카드 ${_playCount}장을 학습했어요.\n종료하면 포인트가 저장됩니다."
              : "현재 학습 화면을 닫습니다.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("종료"),
          ),
        ],
      ),
    );

    if (shouldExit != true) return false;

    await _stopPlaybackForExit();
    await _givePoints();
    return true;
  }

  Future<void> _stopPlaybackForExit() async {
    _isPlaying = false;
    _isPaused = false;
    _stopCountdown();
    if (_ttsEnabled) {
      await _flutterTts.stop();
      await AudioService.pause();
    }
  }

  @override
  void dispose() {
    _isPlaying = false;
    _isPaused = false;
    _stopCountdown();
    if (_ttsEnabled) {
      _flutterTts.stop();
    }
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
    final frontText = (currentCard["text"] ?? "") as String; // 스페인어
    final backText = (currentCard["meaning"] ?? "") as String; // 한국어
    final imageUrl = (currentCard["imageUrl"] ?? "") as String; // ✅ 단일 이미지
    final displayText = _showMeaning ? backText : frontText; // 텍스트만 전환
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isTablet = size.shortestSide >= 600;
    final hasImage = imageUrl.isNotEmpty;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 48,
          title: const Text("플래시카드 학습"),
          actions: [
            IconButton(
              tooltip: "첫 카드",
              icon: const Icon(Icons.first_page),
              onPressed: _goToFirstCard,
            ),
            IconButton(
              tooltip: "마지막 카드",
              icon: const Icon(Icons.last_page),
              onPressed: _goToLastCard,
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isLandscape ? 56 : 20,
              12,
              isLandscape ? 56 : 20,
              8,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _showMeaning = !_showMeaning),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _FlashcardContent(
                      text: displayText,
                      imageUrl: imageUrl,
                      hasImage: hasImage,
                      isLandscape: isLandscape,
                      isTablet: isTablet,
                      maxFontSize: _fontSize,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _NavButton(
                      icon: Icons.chevron_left,
                      onPressed: _currentIndex > 0 || _repeatEnabled
                          ? _goToPreviousCard
                          : null,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _NavButton(
                      icon: Icons.chevron_right,
                      onPressed:
                          _currentIndex < _cards.length - 1 || _repeatEnabled
                              ? _goToNextCard
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.zero,
          child: TTSControls(
            onToggleTTS: _toggleTTS,
            onChangeReadingMode: _changeReadingMode,
            onChangeSpeed: _changeSpeed,
            currentTtsSpeed: _ttsSpeed,
            currentFontSize: _fontSize,
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
            frontVoice: _frontVoice,
            backVoice: _backVoice,
            availableVoices: _availableVoices,
            onChangeFrontVoice: _changeFrontVoice,
            onChangeBackVoice: _changeBackVoice,
            remainingTime: _remainingTime,
          ),
        ),
      ),
    );
  }

  // === 아래 로직은 그대로 ===

  void _startTTS() async {
    if (_cards.isEmpty) return;
    if (!_ttsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("macOS에서는 현재 음성 재생을 비활성화했습니다.")),
      );
      return;
    }

    setState(() {
      _isPlaying = true;
      _isPaused = false;
      _remainingTime =
          _timerMinutes > 0 ? Duration(minutes: _timerMinutes) : null;
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

    if (!mounted) return;
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
    if (_ttsEnabled) {
      _flutterTts.stop();
    }
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
    await prefs.setString('frontVoiceName', _frontVoice?['name'] ?? '');
    await prefs.setString('frontVoiceLocale', _frontVoice?['locale'] ?? '');
    await prefs.setString('backVoiceName', _backVoice?['name'] ?? '');
    await prefs.setString('backVoiceLocale', _backVoice?['locale'] ?? '');
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

    if (_ttsEnabled) {
      _flutterTts.setSpeechRate(_ttsSpeed);
    }
  }

  Future<void> _loadAvailableVoices() async {
    if (!_ttsEnabled) return;
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is! List) return;

      final normalizedVoices = <Map<String, String>>[];
      final seen = <String>{};

      for (final rawVoice in voices) {
        if (rawVoice is! Map) continue;

        final name = rawVoice['name']?.toString() ?? '';
        final locale =
            (rawVoice['locale'] ?? rawVoice['language'])?.toString() ?? '';
        if (name.isEmpty || locale.isEmpty) continue;

        final key = '$name|$locale';
        if (seen.add(key)) {
          normalizedVoices.add({
            'name': name,
            'locale': locale,
          });
        }
      }

      normalizedVoices.sort((a, b) {
        final aLocale = a['locale'] ?? '';
        final bLocale = b['locale'] ?? '';
        final aName = a['name'] ?? '';
        final bName = b['name'] ?? '';
        final localeCompare = aLocale.compareTo(bLocale);
        return localeCompare == 0 ? aName.compareTo(bName) : localeCompare;
      });

      final prefs = await SharedPreferences.getInstance();
      final frontVoice = _findStoredVoice(
        normalizedVoices,
        prefs.getString('frontVoiceName'),
        prefs.getString('frontVoiceLocale'),
      );
      final backVoice = _findStoredVoice(
        normalizedVoices,
        prefs.getString('backVoiceName'),
        prefs.getString('backVoiceLocale'),
      );

      if (!mounted) return;
      setState(() {
        _availableVoices = normalizedVoices;
        _frontVoice = _voiceMatchesLanguage(frontVoice, _frontLanguage)
            ? frontVoice
            : null;
        _backVoice =
            _voiceMatchesLanguage(backVoice, _backLanguage) ? backVoice : null;
      });
    } catch (e) {
      debugPrint('Failed to load TTS voices: $e');
    }
  }

  Map<String, String>? _findStoredVoice(
    List<Map<String, String>> voices,
    String? name,
    String? locale,
  ) {
    if (name == null || name.isEmpty || locale == null || locale.isEmpty) {
      return null;
    }

    for (final voice in voices) {
      if (voice['name'] == name && voice['locale'] == locale) {
        return voice;
      }
    }
    return null;
  }

  bool _voiceMatchesLanguage(Map<String, String>? voice, String language) {
    if (voice == null) return false;
    final locale = voice['locale'] ?? '';
    final languagePrefix = language.split('-').first;
    return locale == language ||
        locale.startsWith('$languagePrefix-') ||
        locale.startsWith('${languagePrefix}_');
  }

  Future<void> _applyTtsVoice({
    required String language,
    required Map<String, String>? voice,
  }) async {
    if (!_ttsEnabled) return;
    if (_voiceMatchesLanguage(voice, language)) {
      await _flutterTts.setVoice(voice!);
    } else {
      await _flutterTts.setLanguage(language);
    }
  }

  void _changeReadingMode(String mode) {
    setState(() => _readingMode = mode);
    saveTTSSettingsLocally();
  }

  void _changeSpeed(double speed) {
    setState(() => _ttsSpeed = speed);
    if (_ttsEnabled) {
      _flutterTts.setSpeechRate(speed);
    }
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
        if (_ttsEnabled) {
          _flutterTts.stop();
        }
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
    setState(() {
      _frontLanguage = lang;
      if (!_voiceMatchesLanguage(_frontVoice, lang)) {
        _frontVoice = null;
      }
    });
    saveTTSSettingsLocally();
  }

  void _changeBackLanguage(String lang) {
    setState(() {
      _backLanguage = lang;
      if (!_voiceMatchesLanguage(_backVoice, lang)) {
        _backVoice = null;
      }
    });
    saveTTSSettingsLocally();
  }

  void _changeFrontVoice(Map<String, String>? voice) {
    setState(() => _frontVoice = voice);
    saveTTSSettingsLocally();
  }

  void _changeBackVoice(Map<String, String>? voice) {
    setState(() => _backVoice = voice);
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
    if (!_ttsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("macOS에서는 현재 음성 재생을 비활성화했습니다.")),
      );
      return;
    }
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
      if (!mounted) {
        timer.cancel();
        return;
      }
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
          await _applyTtsVoice(language: _frontLanguage, voice: _frontVoice);
          if (!mounted) return;
          setState(() => _showMeaning = false);
          await _flutterTts.speak(frontText);
          await Future.delayed(const Duration(milliseconds: 500));

          await _applyTtsVoice(language: _backLanguage, voice: _backVoice);
          if (!mounted) return;
          setState(() => _showMeaning = true);
          await _flutterTts.speak(backText);
        } else if (_readingMode == "뒤앞") {
          await _applyTtsVoice(language: _backLanguage, voice: _backVoice);
          if (!mounted) return;
          setState(() => _showMeaning = true);
          await _flutterTts.speak(backText);
          await Future.delayed(const Duration(milliseconds: 500));

          await _applyTtsVoice(language: _frontLanguage, voice: _frontVoice);
          if (!mounted) return;
          setState(() => _showMeaning = false);
          await _flutterTts.speak(frontText);
        } else if (_readingMode == "앞면만") {
          await _applyTtsVoice(language: _frontLanguage, voice: _frontVoice);
          if (!mounted) return;
          setState(() => _showMeaning = false);
          await _flutterTts.speak(frontText);
        } else if (_readingMode == "뒷면만") {
          await _applyTtsVoice(language: _backLanguage, voice: _backVoice);
          if (!mounted) return;
          setState(() => _showMeaning = true);
          await _flutterTts.speak(backText);
        }
      } catch (e) {
        debugPrint("Error in _playCard: $e");
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (!mounted || !_isPlaying) return;
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

class _FlashcardContent extends StatelessWidget {
  final String text;
  final String imageUrl;
  final bool hasImage;
  final bool isLandscape;
  final bool isTablet;
  final double maxFontSize;

  const _FlashcardContent({
    required this.text,
    required this.imageUrl,
    required this.hasImage,
    required this.isLandscape,
    required this.isTablet,
    required this.maxFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final textPane = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 56 : 36,
        vertical: 24,
      ),
      child: _ResponsiveCardText(
        text: text,
        maxFontSize: maxFontSize,
        minFontSize: isLandscape ? 18 : 20,
      ),
    );

    if (!hasImage) {
      return Center(child: textPane);
    }

    final imagePane = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 36 : 20,
        vertical: 12,
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (ctx, _) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (ctx, _, __) =>
                      const Icon(Icons.broken_image, size: 48),
                )
              : Image.file(
                  File(imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, _, __) =>
                      const Icon(Icons.broken_image, size: 48),
                ),
        ),
      ),
    );

    if (isLandscape) {
      return Row(
        children: [
          Expanded(flex: isTablet ? 5 : 4, child: imagePane),
          Expanded(flex: isTablet ? 4 : 5, child: textPane),
        ],
      );
    }

    return Column(
      children: [
        Expanded(flex: 4, child: imagePane),
        Expanded(flex: 5, child: textPane),
      ],
    );
  }
}

class _ResponsiveCardText extends StatelessWidget {
  final String text;
  final double maxFontSize;
  final double minFontSize;

  const _ResponsiveCardText({
    required this.text,
    required this.maxFontSize,
    required this.minFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final fittedFontSize = _findLargestFittingFontSize(
          text: text,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          textDirection: textDirection,
        );
        final fitsAtMinimum = _textFits(
          fontSize: fittedFontSize,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          textDirection: textDirection,
        );
        final content = Text(
          text,
          textAlign: TextAlign.center,
          softWrap: true,
          style: TextStyle(
            fontSize: fittedFontSize,
            height: 1.18,
            letterSpacing: 0,
          ),
        );

        if (fitsAtMinimum) {
          return Center(child: content);
        }

        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: content,
          ),
        );
      },
    );
  }

  double _findLargestFittingFontSize({
    required String text,
    required double maxWidth,
    required double maxHeight,
    required TextDirection textDirection,
  }) {
    var low = minFontSize;
    var high = maxFontSize;

    for (var i = 0; i < 10; i++) {
      final mid = (low + high) / 2;
      if (_textFits(
        fontSize: mid,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        textDirection: textDirection,
      )) {
        low = mid;
      } else {
        high = mid;
      }
    }

    return low.clamp(minFontSize, maxFontSize);
  }

  bool _textFits({
    required double fontSize,
    required double maxWidth,
    required double maxHeight,
    required TextDirection textDirection,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, height: 1.18),
      ),
      textAlign: TextAlign.center,
      textDirection: textDirection,
    )..layout(maxWidth: maxWidth);

    return painter.width <= maxWidth && painter.height <= maxHeight;
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withAlpha(210),
      shape: const CircleBorder(),
      elevation: 1,
      child: IconButton(
        icon: Icon(icon),
        iconSize: 30,
        onPressed: onPressed,
      ),
    );
  }
}
