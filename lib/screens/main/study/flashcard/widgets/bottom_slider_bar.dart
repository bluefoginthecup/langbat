import 'package:flutter/material.dart';

class BottomSliderBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final ValueChanged<int> onChanged;   // 최종 이동
  final ValueChanged<int>? onChanging; // 드래그 중 미리 보기(옵션)

  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const BottomSliderBar({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.onChanged,
    this.onChanging,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();

    return BottomAppBar(
      elevation: 6,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: currentIndex.toDouble(),
                    min: 0,
                    max: (total - 1).toDouble(),
                    divisions: total - 1,
                    label: '카드 ${currentIndex + 1}',
                    onChanged: (v) => onChanging?.call(v.round()),
                    onChangeEnd: (v) => onChanged(v.round()),
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
              const SizedBox(width: 8),
              Text('${currentIndex + 1}/$total', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
