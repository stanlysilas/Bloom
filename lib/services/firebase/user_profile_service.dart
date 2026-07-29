import 'package:bloom/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<UserModel?> watchUser() {
    final uid = _auth.currentUser!.uid;
    if (uid.isEmpty) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return UserModel.fromFirestore(doc.id, data);
    });
  }

  Future<UserModel?> getUserDetails(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    final data = doc.data();
    if (data == null) return null;

    return UserModel.fromFirestore(doc.id, data);
  }
}
