import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreRefs {
  FirestoreRefs._();

  static User get _user {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      throw StateError('User not logged in (currentUser == null)');
    }
    return u;
  }

  static String get uid => _user.uid;

  static DocumentReference<Map<String, dynamic>> userDoc() =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  static CollectionReference<Map<String, dynamic>> carts() =>
      userDoc().collection('cart');

  static CollectionReference<Map<String, dynamic>> lists() =>
      userDoc().collection('lists');

  static CollectionReference<Map<String, dynamic>> customLists() =>
      userDoc().collection('custom_lists');

  static const createdAt = 'createdAt';
}
