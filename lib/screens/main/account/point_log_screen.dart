import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PointLogScreen extends StatelessWidget {
  const PointLogScreen({super.key});

  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('로그인 정보 없음')),
      );
    }

    final logRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pointLogs')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 내역'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: logRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data!.docs;

          if (logs.isEmpty) {
            return const Center(child: Text('포인트 내역이 없습니다.'));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index].data() as Map<String, dynamic>;
              final amount = log['amount'] ?? 0;
              final description = log['description'] ?? '';
              final timestamp = log['timestamp'] ?? '';

              return ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.green),
                title: Text('+${amount.toString()}점  |  $description'),
                subtitle: Text(formatDate(timestamp)),
              );
            },
          );
        },
      ),
    );
  }
}
