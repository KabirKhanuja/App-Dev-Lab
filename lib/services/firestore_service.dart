import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> upsertUserProfile({required User user, String? name}) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    await userDoc.set({
      'email': user.email,
      'name': (name == null || name.trim().isEmpty)
          ? (user.email?.split('@').first ?? 'User')
          : name.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
