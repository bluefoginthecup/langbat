import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:langbat/features/photo_flashcards/data/photo_flashcard_models.dart';
import 'package:langbat/features/photo_flashcards/presentation/widgets/photo_card_image.dart';

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
  int _cardIndex = 0;
  int _stage = 0;
  bool _speaking = false;
  bool get _ttsEnabled => !Platform.isMacOS;

  PhotoFlashcard get _card => widget.cards[_cardIndex];

  @override
  void initState() {
    super.initState();
    _configureTts();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakSpanish());
  }

  Future<void> _configureTts() async {
    if (!_ttsEnabled) return;
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
    );
  }

  @override
  void dispose() {
    if (_ttsEnabled) {
      _tts.stop();
    }
    super.dispose();
  }

  Future<void> _speakSpanish() async {
    if (!_ttsEnabled) return;
    final text = _card.spanishText.trim();
    if (text.isEmpty || _speaking) return;
    setState(() => _speaking = true);
    try {
      await _tts.setLanguage('es-ES');
      await _tts.speak(text);
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  void _advance() {
    if (_stage < 2) {
      setState(() => _stage += 1);
      if (_stage == 1) _speakSpanish();
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

  @override
  Widget build(BuildContext context) {
    final card = _card;
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckTitle),
        actions: [
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
                    tooltip: '다시 듣기',
                    onPressed: !_ttsEnabled || _speaking ? null : _speakSpanish,
                    icon: Icon(_speaking ? Icons.volume_up : Icons.hearing),
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
