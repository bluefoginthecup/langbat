import 'package:flutter/material.dart';

class StudyMoreMenuSheet extends StatelessWidget {
  final String readingMode;
  final bool shuffleEnabled;
  final int repeatCount;
  final double ttsSpeed;
  final int timerMinutes;
  final String frontLanguage;
  final String backLanguage;
  final double fontSize;

  final Future<void> Function(BuildContext) onPickReadingMode;
  final void Function(bool) onToggleShuffle;
  final Future<void> Function(BuildContext) onPickRepeat;
  final Future<void> Function(BuildContext) onPickSpeed;
  final Future<void> Function(BuildContext) onPickTimer;
  final Future<void> Function(BuildContext) onPickLanguages;
  final Future<void> Function(BuildContext) onPickFontSize;
  final Future<void> Function(BuildContext)? onOpenCardSlider;

  const StudyMoreMenuSheet({
    super.key,
    required this.readingMode,
    required this.shuffleEnabled,
    required this.repeatCount,
    required this.ttsSpeed,
    required this.timerMinutes,
    required this.frontLanguage,
    required this.backLanguage,
    required this.fontSize,
    required this.onPickReadingMode,
    required this.onToggleShuffle,
    required this.onPickRepeat,
    required this.onPickSpeed,
    required this.onPickTimer,
    required this.onPickLanguages,
    required this.onPickFontSize,
    this.onOpenCardSlider,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            height: 4, width: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Text('학습 옵션', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.swap_calls),
            title: const Text('읽기 모드'),
            subtitle: Text(readingMode),
            onTap: () => onPickReadingMode(context),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.shuffle),
            title: const Text('셔플'),
            value: shuffleEnabled,
            onChanged: onToggleShuffle,
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('반복'),
            subtitle: Text(repeatCount == 999 ? '무한' : '$repeatCount회'),
            onTap: () => onPickRepeat(context),
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('TTS 속도'),
            subtitle: Text('${ttsSpeed.toStringAsFixed(1)}x'),
            onTap: () => onPickSpeed(context),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('타이머'),
            subtitle: Text(timerMinutes == 0 ? '없음' : '${timerMinutes}분'),
            onTap: () => onPickTimer(context),
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('언어 (앞/뒤)'),
            subtitle: Text('앞: $frontLanguage / 뒤: $backLanguage'),
            onTap: () => onPickLanguages(context),
          ),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('글자 크기'),
            subtitle: Text('${fontSize.toStringAsFixed(0)} pt'),
            onTap: () => onPickFontSize(context),
          ),
          if (onOpenCardSlider != null)
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('카드 이동'),
              onTap: () => onOpenCardSlider!(context),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
