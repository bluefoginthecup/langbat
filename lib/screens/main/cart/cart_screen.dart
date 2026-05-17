import 'package:flutter/material.dart';

import '../my_list/flashcard_set_list_screen.dart';
import '../my_list/sentence_list_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _replaceWith(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('리스트 바구니'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '장바구니는 로컬 저장 구조로 전환 중입니다.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '현재는 문장리스트에서 항목을 선택해 바로 로컬 플래시카드 세트를 만들 수 있습니다. 이 화면에서는 더 이상 Firestore 장바구니를 읽거나 비우지 않습니다.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () =>
                        _replaceWith(context, const SentenceListScreen()),
                    icon: const Icon(Icons.format_quote),
                    label: const Text('문장리스트로 이동'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _replaceWith(context, const FlashcardSetListScreen()),
                    icon: const Icon(Icons.style_outlined),
                    label: const Text('플래시카드 세트 보기'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
