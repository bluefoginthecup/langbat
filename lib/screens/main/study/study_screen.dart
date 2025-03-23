// lib/screens/main/home/home_screen.dart
import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Study')),
      body: Center(child: Text('학습')),
    );
  }
}
