import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointService {
  static Future<void> addPoint({
    required int amount,
    required String type,
    required String description,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final logRef = userRef.collection('pointLogs').doc();
    final now = DateTime.now();

    await FirebaseFirestore.instance.runTransaction((txn) async {
      txn.update(userRef, {
        'points': FieldValue.increment(amount),
      });
      txn.set(logRef, {
        'timestamp': now.toIso8601String(),
        'amount': amount,
        'type': type,
        'description': description,
      });
    });
  }
}
