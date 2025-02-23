// lib/screens/main/home/home_screen.dart
import 'package:flutter/material.dart';

class MyListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My list')),
      body: Center(child: Text('내 리스트')),
    );
  }
}
