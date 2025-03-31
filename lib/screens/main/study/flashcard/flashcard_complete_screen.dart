import 'package:flutter/material.dart';
import '/screens/main/home/home_screen.dart';

class FlashcardSessionCompleteScreen extends StatelessWidget {

  const FlashcardSessionCompleteScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("홈으로"),
          onPressed: () {
            print('홈버튼 눌림');
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
          },
        ),
      ),
    );
  }
}
