import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final bloomSnackBars = BloomSnackBars();

  Future loginUser(String email, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> authenticateWithGoogle(BuildContext context) async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;

      if (user != null) {
        await addUserDetails(
          user.uid,
          user.email ?? "",
          user.displayName ?? user.email?.split('@').first ?? "User",
          user.photoURL ?? 'assets/profile_pictures/Profile_Picture_Male_1.png',
          false,
          user.photoURL != null,
        );
        return userCredential;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      bloomSnackBars.showAuthErrorSnackBar(context, e);
      return null;
    }
  }

  Future createUserWithEmailAndPassword(BuildContext context, String email,
      String password, String userName, String profilePicture) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        await addUserDetails(
            user.uid, user.email!, userName, profilePicture, true, false);
        return null;
      }
    } on FirebaseAuthException catch (e) {
      bloomSnackBars.showAuthErrorSnackBar(context, e);
      return e.code;
    }
  }

  Future<void> addUserDetails(
      String uid,
      String email,
      String userName,
      String? profilePicture,
      bool isEmailAndPassword,
      bool isImageNetwork) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'profilePicture': profilePicture,
      'userName': userName,
      'isEmailAndPassword': isEmailAndPassword,
      'isImageNetwork': isImageNetwork,
      'fcmToken': '',
      'eventsColorCode': Colors.amber.toHexString(),
      'tasksColorCode': Colors.blue.toHexString(),
      'entriesColorCode': Colors.green.toHexString(),
      'habitsColorCode': Colors.purple.toHexString(),
    });
  }
}
