import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:langbat/features/photo_flashcards/data/eleven_labs_tts_service.dart';
import 'package:langbat/features/photo_flashcards/data/photo_flashcard_models.dart';
import 'package:langbat/features/photo_flashcards/data/photo_flashcard_repository.dart';
import 'package:langbat/features/photo_flashcards/presentation/widgets/photo_card_image.dart';

enum _TtsSide { front, back }

class PhotoStudyScreen extends StatefulWidget {
  const PhotoStudyScreen({
    super.key,
    required this.deckTitle,
    required this.cards,
  });

  final String deckTitle;
  final List<PhotoFlashcard> cards;

  @override
  State<PhotoStudyScreen> createState() => _PhotoStudyScreenState();
}

class _PhotoStudyScreenState extends State<PhotoStudyScreen> {
  final _tts = FlutterTts();
  final _audioPlayer = AudioPlayer();
  final _repo = PhotoFlashcardRepository();
  final _elevenLabs = const ElevenLabsTtsService();
  int _cardIndex = 0;
  int _stage = 0;
  bool _speaking = false;
  bool _generatingAudio = false;
  bool _autoPlay = false;
  bool _shuffleEnabled = false;
  bool _useElevenLabs = false;
  String _readingMode = '앞뒤';
  int _repeatCount = 1;
  double _ttsSpeed = 0.48;
  String _frontLanguage = 'es-ES';
  String _backLanguage = 'ko-KR';
  String _elevenLabsApiKey = '';
  String _elevenLabsFrontVoiceId = '';
  String _elevenLabsBackVoiceId = '';
  String _elevenLabsModelId = 'eleven_flash_v2_5';
  Map<String, String>? _frontVoice;
  Map<String, String>? _backVoice;
  List<Map<String, String>> _availableVoices = [];
  bool get _ttsEnabled => !Platform.isMacOS;

  PhotoFlashcard get _card => widget.cards[_cardIndex];

  @override
  void initState() {
    super.initState();
    _initializeTtsAndStart();
  }

  Future<void> _initializeTtsAndStart() async {
    await _configureTts();
    if (!mounted) return;
    if (_autoPlay) {
      await _runAutoPlay();
    } else {
      await _speakSpanish();
    }
  }

  Future<void> _configureTts() async {
    await _loadTtsSettings();
    if (!_ttsEnabled) return;
    await _tts.setLanguage(_frontLanguage);
    await _tts.setSpeechRate(_ttsSpeed);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
    );
    await _loadAvailableVoices();
  }

  @override
  void dispose() {
    _autoPlay = false;
    _audioPlayer.dispose();
    if (_ttsEnabled) {
      _tts.stop();
    }
    super.dispose();
  }

  Future<void> _speakSpanish() async {
    await _speak(
      side: _TtsSide.front,
      text: _card.spanishText,
      language: _frontLanguage,
      voice: _frontVoice,
    );
  }

  Future<void> _speakKorean() async {
    await _speak(
      side: _TtsSide.back,
      text: _card.koreanText,
      language: _backLanguage,
      voice: _backVoice,
    );
  }

  Future<void> _speak({
    required _TtsSide side,
    required String text,
    required String language,
    required Map<String, String>? voice,
  }) async {
    if (!_ttsEnabled) return;
    final spoken = text.trim();
    if (spoken.isEmpty || _speaking) return;
    setState(() => _speaking = true);
    try {
      for (var i = 0; i < _repeatCount; i += 1) {
        if (!mounted) return;
        final playedByElevenLabs = await _tryPlayElevenLabs(
          side: side,
          text: spoken,
        );
        if (!playedByElevenLabs) {
          await _applyTtsVoice(language: language, voice: voice);
          await _tts.setSpeechRate(_ttsSpeed);
          await _tts.speak(spoken);
        }
        if (i < _repeatCount - 1) {
          await Future.delayed(const Duration(milliseconds: 350));
        }
      }
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  Future<bool> _tryPlayElevenLabs({
    required _TtsSide side,
    required String text,
  }) async {
    if (!_useElevenLabs) return false;
    final apiKey = _elevenLabsApiKey.trim();
    final voiceId = side == _TtsSide.front
        ? _elevenLabsFrontVoiceId.trim()
        : _elevenLabsBackVoiceId.trim();
    if (apiKey.isEmpty || voiceId.isEmpty) return false;

    final card = _card;
    var relativePath =
        side == _TtsSide.front ? card.audioFrontPath : card.audioBackPath;
    var absolutePath = side == _TtsSide.front
        ? card.audioFrontAbsolutePath
        : card.audioBackAbsolutePath;

    try {
      if (absolutePath == null ||
          absolutePath.isEmpty ||
          !await File(absolutePath).exists()) {
        if (mounted) setState(() => _generatingAudio = true);
        final generated = await _elevenLabs.generateAndStore(
          apiKey: apiKey,
          voiceId: voiceId,
          modelId: _elevenLabsModelId,
          termId: card.termId,
          side: side == _TtsSide.front ? 'front' : 'back',
          text: text,
        );
        relativePath = generated.relativePath;
        absolutePath = generated.absolutePath;
        await _repo.updateCardAudioPath(
          termId: card.termId,
          front: side == _TtsSide.front,
          relativePath: relativePath,
        );
        final updatedCard = side == _TtsSide.front
            ? card.copyWith(
                audioFrontPath: relativePath,
                audioFrontAbsolutePath: absolutePath,
              )
            : card.copyWith(
                audioBackPath: relativePath,
                audioBackAbsolutePath: absolutePath,
              );
        widget.cards[_cardIndex] = updatedCard;
      }

      await _audioPlayer.setFilePath(absolutePath);
      await _audioPlayer.play();
      return true;
    } catch (e) {
      debugPrint('ElevenLabs playback failed, falling back to native TTS: $e');
      return false;
    } finally {
      if (mounted) setState(() => _generatingAudio = false);
    }
  }

  Future<void> _advance() async {
    if (_stage < 2) {
      setState(() => _stage += 1);
      if (_stage == 1) {
        await _speakSpanish();
      } else if (_stage == 2) {
        await _speakKorean();
      }
      return;
    }
    _nextCard();
  }

  void _previousCard() {
    if (_cardIndex == 0) return;
    setState(() {
      _cardIndex -= 1;
      _stage = 0;
    });
    _speakSpanish();
  }

  void _nextCard() {
    if (_cardIndex >= widget.cards.length - 1) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _cardIndex += 1;
      _stage = 0;
    });
    _speakSpanish();
  }

  Future<void> _replayCurrentStage() async {
    if (_stage == 2) {
      await _speakKorean();
    } else {
      await _speakSpanish();
    }
  }

  Future<void> _toggleAutoPlay() async {
    if (!_ttsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('macOS에서는 현재 음성 재생을 비활성화했습니다.')),
      );
      return;
    }
    setState(() => _autoPlay = !_autoPlay);
    await _saveTtsSettings();
    if (_autoPlay) {
      await _runAutoPlay();
    } else {
      await _audioPlayer.stop();
      await _tts.stop();
    }
  }

  Future<void> _runAutoPlay() async {
    while (mounted && _autoPlay) {
      setState(() => _stage = 0);
      await _playCurrentCardSequence();
      if (!mounted || !_autoPlay) return;
      if (_cardIndex >= widget.cards.length - 1) {
        setState(() => _autoPlay = false);
        return;
      }
      setState(() {
        _cardIndex += 1;
        _stage = 0;
      });
      await Future.delayed(const Duration(milliseconds: 450));
    }
  }

  Future<void> _playCurrentCardSequence() async {
    final mode = _readingMode;
    if (mode == '앞뒤' || mode == '앞면만') {
      await _speakSpanish();
      if (!mounted || !_autoPlay) return;
    }

    setState(() => _stage = 1);
    if (mode == '앞뒤') {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mode == '뒤앞') {
      await _speakKorean();
      if (!mounted || !_autoPlay) return;
      setState(() => _stage = 2);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _stage = 1);
      await _speakSpanish();
      return;
    }

    if (mode == '뒷면만') {
      setState(() => _stage = 2);
      await _speakKorean();
      return;
    }

    if (mode == '앞뒤') {
      setState(() => _stage = 2);
      await _speakKorean();
    }
  }

  Future<void> _loadTtsSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _readingMode = prefs.getString('photoTtsReadingMode') ??
          prefs.getString('readingMode') ??
          _readingMode;
      _repeatCount = prefs.getInt('photoTtsRepeatCount') ??
          prefs.getInt('repeatCount') ??
          _repeatCount;
      _shuffleEnabled = prefs.getBool('photoTtsShuffleEnabled') ??
          prefs.getBool('shuffleEnabled') ??
          _shuffleEnabled;
      _ttsSpeed = prefs.getDouble('photoTtsSpeed') ??
          prefs.getDouble('ttsSpeed') ??
          _ttsSpeed;
      _frontLanguage = prefs.getString('photoTtsFrontLanguage') ??
          prefs.getString('frontLanguage') ??
          _frontLanguage;
      _backLanguage = prefs.getString('photoTtsBackLanguage') ??
          prefs.getString('backLanguage') ??
          _backLanguage;
      _autoPlay = prefs.getBool('photoTtsAutoPlay') ?? _autoPlay;
      _useElevenLabs = prefs.getBool('photoTtsUseElevenLabs') ?? _useElevenLabs;
      _elevenLabsApiKey =
          prefs.getString('photoTtsElevenLabsApiKey') ?? _elevenLabsApiKey;
      _elevenLabsFrontVoiceId =
          prefs.getString('photoTtsElevenLabsFrontVoiceId') ??
              _elevenLabsFrontVoiceId;
      _elevenLabsBackVoiceId =
          prefs.getString('photoTtsElevenLabsBackVoiceId') ??
              _elevenLabsBackVoiceId;
      _elevenLabsModelId =
          prefs.getString('photoTtsElevenLabsModelId') ?? _elevenLabsModelId;
    });
  }

  Future<void> _saveTtsSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('photoTtsReadingMode', _readingMode);
    await prefs.setInt('photoTtsRepeatCount', _repeatCount);
    await prefs.setBool('photoTtsShuffleEnabled', _shuffleEnabled);
    await prefs.setDouble('photoTtsSpeed', _ttsSpeed);
    await prefs.setString('photoTtsFrontLanguage', _frontLanguage);
    await prefs.setString('photoTtsBackLanguage', _backLanguage);
    await prefs.setString('photoTtsFrontVoiceName', _frontVoice?['name'] ?? '');
    await prefs.setString(
        'photoTtsFrontVoiceLocale', _frontVoice?['locale'] ?? '');
    await prefs.setString('photoTtsBackVoiceName', _backVoice?['name'] ?? '');
    await prefs.setString(
        'photoTtsBackVoiceLocale', _backVoice?['locale'] ?? '');
    await prefs.setBool('photoTtsAutoPlay', _autoPlay);
    await prefs.setBool('photoTtsUseElevenLabs', _useElevenLabs);
    await prefs.setString('photoTtsElevenLabsApiKey', _elevenLabsApiKey);
    await prefs.setString(
      'photoTtsElevenLabsFrontVoiceId',
      _elevenLabsFrontVoiceId,
    );
    await prefs.setString(
      'photoTtsElevenLabsBackVoiceId',
      _elevenLabsBackVoiceId,
    );
    await prefs.setString('photoTtsElevenLabsModelId', _elevenLabsModelId);
  }

  Future<void> _loadAvailableVoices() async {
    if (!_ttsEnabled) return;
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;

      final normalizedVoices = <Map<String, String>>[];
      final seen = <String>{};
      for (final rawVoice in voices) {
        if (rawVoice is! Map) continue;
        final name = rawVoice['name']?.toString() ?? '';
        final locale =
            (rawVoice['locale'] ?? rawVoice['language'])?.toString() ?? '';
        if (name.isEmpty || locale.isEmpty) continue;
        if (seen.add('$name|$locale')) {
          normalizedVoices.add({'name': name, 'locale': locale});
        }
      }
      normalizedVoices.sort((a, b) {
        final localeCompare = (a['locale'] ?? '').compareTo(b['locale'] ?? '');
        return localeCompare == 0
            ? (a['name'] ?? '').compareTo(b['name'] ?? '')
            : localeCompare;
      });

      final prefs = await SharedPreferences.getInstance();
      final frontVoice = _findStoredVoice(
        normalizedVoices,
        prefs.getString('photoTtsFrontVoiceName') ??
            prefs.getString('frontVoiceName'),
        prefs.getString('photoTtsFrontVoiceLocale') ??
            prefs.getString('frontVoiceLocale'),
      );
      final backVoice = _findStoredVoice(
        normalizedVoices,
        prefs.getString('photoTtsBackVoiceName') ??
            prefs.getString('backVoiceName'),
        prefs.getString('photoTtsBackVoiceLocale') ??
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
      debugPrint('Failed to load photo TTS voices: $e');
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
      if (voice['name'] == name && voice['locale'] == locale) return voice;
    }
    return null;
  }

  bool _voiceMatchesLanguage(Map<String, String>? voice, String language) {
    if (voice == null) return false;
    final locale = voice['locale'] ?? '';
    final prefix = language.split('-').first;
    return locale == language ||
        locale.startsWith('$prefix-') ||
        locale.startsWith('${prefix}_');
  }

  Future<void> _applyTtsVoice({
    required String language,
    required Map<String, String>? voice,
  }) async {
    if (_voiceMatchesLanguage(voice, language)) {
      await _tts.setVoice(voice!);
    } else {
      await _tts.setLanguage(language);
    }
  }

  void _shuffleCardsIfNeeded(bool enabled) {
    setState(() {
      _shuffleEnabled = enabled;
      if (enabled) {
        widget.cards.shuffle();
        _cardIndex = 0;
        _stage = 0;
      }
    });
    _saveTtsSettings();
  }

  List<Map<String, String>> _voicesForLanguage(String language) {
    final voices = _availableVoices
        .where((voice) => _voiceMatchesLanguage(voice, language))
        .toList();
    voices.sort((a, b) {
      final localeCompare = (a['locale'] ?? '').compareTo(b['locale'] ?? '');
      return localeCompare == 0
          ? (a['name'] ?? '').compareTo(b['name'] ?? '')
          : localeCompare;
    });
    return voices;
  }

  String _voiceLabel(Map<String, String> voice) {
    final name = voice['name'] ?? 'Unknown';
    final locale = voice['locale'] ?? '';
    return locale.isEmpty ? name : '$name ($locale)';
  }

  Map<String, String>? _matchingVoice(
    Map<String, String>? selected,
    List<Map<String, String>> voices,
  ) {
    if (selected == null) return null;
    for (final voice in voices) {
      if (voice['name'] == selected['name'] &&
          voice['locale'] == selected['locale']) {
        return voice;
      }
    }
    return null;
  }

  Future<void> _showTtsSettingsSheet() async {
    final languages = {
      'Spanish': 'es-ES',
      'Korean': 'ko-KR',
      'English': 'en-US',
      'French': 'fr-FR',
      'German': 'de-DE',
    };
    final apiKeyController = TextEditingController(text: _elevenLabsApiKey);
    final frontVoiceIdController =
        TextEditingController(text: _elevenLabsFrontVoiceId);
    final backVoiceIdController =
        TextEditingController(text: _elevenLabsBackVoiceId);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void refresh(VoidCallback update) {
              setState(update);
              setSheetState(() {});
              _saveTtsSettings();
            }

            final frontVoices = _voicesForLanguage(_frontLanguage);
            final backVoices = _voicesForLanguage(_backLanguage);
            final frontVoiceValue = _matchingVoice(_frontVoice, frontVoices);
            final backVoiceValue = _matchingVoice(_backVoice, backVoices);

            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'TTS 설정',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('ElevenLabs 고품질 음성'),
                        subtitle: const Text('생성된 mp3는 로컬에 저장됩니다.'),
                        value: _useElevenLabs,
                        onChanged: !_ttsEnabled
                            ? null
                            : (value) {
                                refresh(() => _useElevenLabs = value);
                              },
                      ),
                      if (_useElevenLabs) ...[
                        TextField(
                          controller: apiKeyController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'ElevenLabs API Key',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _elevenLabsApiKey = value.trim();
                            _saveTtsSettings();
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: frontVoiceIdController,
                          decoration: const InputDecoration(
                            labelText: '스페인어 Voice ID',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _elevenLabsFrontVoiceId = value.trim();
                            _saveTtsSettings();
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: backVoiceIdController,
                          decoration: const InputDecoration(
                            labelText: '한국어 Voice ID',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _elevenLabsBackVoiceId = value.trim();
                            _saveTtsSettings();
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _elevenLabsModelId,
                          decoration: const InputDecoration(
                            labelText: 'ElevenLabs 모델',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'eleven_flash_v2_5',
                              child: Text('Flash v2.5'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'eleven_multilingual_v2',
                              child: Text('Multilingual v2'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            refresh(() => _elevenLabsModelId = value);
                          },
                        ),
                        const Divider(height: 28),
                      ],
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('자동 재생'),
                        value: _autoPlay,
                        onChanged: !_ttsEnabled
                            ? null
                            : (value) {
                                Navigator.pop(context);
                                _toggleAutoPlay();
                              },
                      ),
                      DropdownButtonFormField<String>(
                        value: _readingMode,
                        decoration: const InputDecoration(labelText: '읽기 모드'),
                        items: ['앞뒤', '뒤앞', '앞면만', '뒷면만']
                            .map((value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          refresh(() => _readingMode = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(child: Text('TTS 속도')),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _ttsSpeed <= 0.3
                                ? null
                                : () {
                                    final next =
                                        (_ttsSpeed - 0.1).clamp(0.3, 1.0);
                                    refresh(() => _ttsSpeed = next);
                                    if (_ttsEnabled) {
                                      _tts.setSpeechRate(next);
                                    }
                                  },
                          ),
                          Text('${_ttsSpeed.toStringAsFixed(1)}x'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _ttsSpeed >= 1.0
                                ? null
                                : () {
                                    final next =
                                        (_ttsSpeed + 0.1).clamp(0.3, 1.0);
                                    refresh(() => _ttsSpeed = next);
                                    if (_ttsEnabled) {
                                      _tts.setSpeechRate(next);
                                    }
                                  },
                          ),
                        ],
                      ),
                      DropdownButtonFormField<int>(
                        value: _repeatCount,
                        decoration: const InputDecoration(labelText: '반복 횟수'),
                        items: List.generate(10, (index) => index + 1)
                            .map((value) => DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value회'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          refresh(() => _repeatCount = value);
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('셔플'),
                        value: _shuffleEnabled,
                        onChanged: _shuffleCardsIfNeeded,
                      ),
                      const Divider(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _frontLanguage,
                              decoration:
                                  const InputDecoration(labelText: '앞면 언어'),
                              items: languages.entries
                                  .map((entry) => DropdownMenuItem<String>(
                                        value: entry.value,
                                        child: Text(entry.key),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                refresh(() {
                                  _frontLanguage = value;
                                  _frontVoice = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _backLanguage,
                              decoration:
                                  const InputDecoration(labelText: '뒷면 언어'),
                              items: languages.entries
                                  .map((entry) => DropdownMenuItem<String>(
                                        value: entry.value,
                                        child: Text(entry.key),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                refresh(() {
                                  _backLanguage = value;
                                  _backVoice = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Map<String, String>?>(
                        value: frontVoiceValue,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: '스페인어 음성'),
                        items: [
                          const DropdownMenuItem<Map<String, String>?>(
                            value: null,
                            child: Text('자동'),
                          ),
                          ...frontVoices.map(
                            (voice) => DropdownMenuItem<Map<String, String>?>(
                              value: voice,
                              child: Text(
                                _voiceLabel(voice),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: !_ttsEnabled
                            ? null
                            : (value) => refresh(() => _frontVoice = value),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Map<String, String>?>(
                        value: backVoiceValue,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: '한국어 음성'),
                        items: [
                          const DropdownMenuItem<Map<String, String>?>(
                            value: null,
                            child: Text('자동'),
                          ),
                          ...backVoices.map(
                            (voice) => DropdownMenuItem<Map<String, String>?>(
                              value: voice,
                              child: Text(
                                _voiceLabel(voice),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: !_ttsEnabled
                            ? null
                            : (value) => refresh(() => _backVoice = value),
                      ),
                      if (!_ttsEnabled) ...[
                        const SizedBox(height: 12),
                        Text(
                          'macOS에서는 현재 TTS를 비활성화했습니다. iOS에서는 설정이 적용됩니다.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    apiKeyController.dispose();
    frontVoiceIdController.dispose();
    backVoiceIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = _card;
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckTitle),
        actions: [
          IconButton(
            tooltip: 'TTS 설정',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showTtsSettingsSheet,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('${_cardIndex + 1} / ${widget.cards.length}'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isLandscape ? 48 : 18,
            12,
            isLandscape ? 48 : 18,
            16,
          ),
          child: Column(
            children: [
              Expanded(
                child: isLandscape
                    ? Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: _StudyImage(card: card),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 4,
                            child: _StagePanel(stage: _stage, card: card),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            flex: 6,
                            child: _StudyImage(card: card),
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            flex: 4,
                            child: _StagePanel(stage: _stage, card: card),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: '이전 카드',
                    onPressed: _cardIndex == 0 ? null : _previousCard,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: _generatingAudio
                        ? 'ElevenLabs 음성 생성 중'
                        : _stage == 2
                            ? '한국어 다시 듣기'
                            : '스페인어 다시 듣기',
                    onPressed: !_ttsEnabled || _speaking || _generatingAudio
                        ? null
                        : _replayCurrentStage,
                    icon: _generatingAudio
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(_speaking ? Icons.volume_up : Icons.hearing),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: _autoPlay ? '자동 재생 정지' : '자동 재생',
                    onPressed: _toggleAutoPlay,
                    icon: Icon(
                      _autoPlay ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _advance,
                    icon: Icon(_stage < 2
                        ? Icons.keyboard_arrow_down
                        : Icons.chevron_right),
                    label: Text(_stage < 2 ? '다음 단계' : '다음 카드'),
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

class _StudyImage extends StatelessWidget {
  const _StudyImage({required this.card});

  final PhotoFlashcard card;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: PhotoCardImage(
          path: card.imageAbsolutePath,
          fit: BoxFit.contain,
          borderRadius: 8,
          cacheWidth: 1400,
        ),
      ),
    );
  }
}

class _StagePanel extends StatelessWidget {
  const _StagePanel({
    required this.stage,
    required this.card,
  });

  final int stage;
  final PhotoFlashcard card;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String text;
    final IconData icon;

    if (stage == 0) {
      text = '듣고 사진을 보세요';
      icon = Icons.volume_up_outlined;
    } else if (stage == 1) {
      text = card.spanishText.trim().isEmpty ? '스페인어 문장 없음' : card.spanishText;
      icon = Icons.record_voice_over_outlined;
    } else {
      text = card.koreanText.trim().isEmpty ? '한국어 뜻 없음' : card.koreanText;
      icon = Icons.translate_outlined;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: stage == 0 ? 22 : 26,
                    height: 1.22,
                    letterSpacing: 0,
                    color: stage == 0
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
