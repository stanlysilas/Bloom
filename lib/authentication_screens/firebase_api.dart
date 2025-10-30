import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseAPI {
  // Create an instance for firebase firestore
  final firestore = FirebaseFirestore.instance;
  // Get user instance
  final user = FirebaseAuth.instance.currentUser;
  // Create an instance of Firebase Messaging
  final firebaseMessaging = FirebaseMessaging.instance;
  // Function to initialise notifications
  Future<void> initNotifications() async {
    // Create an instance for firebase firestore
    final firestore = FirebaseFirestore.instance;
    // Get user instance
    final user = FirebaseAuth.instance.currentUser;
    // Create an instance of Firebase Messaging
    final firebaseMessaging = FirebaseMessaging.instance;
    // Fetch the FCM token for the device
    final fcmToken = await firebaseMessaging.getToken();
    // Store the FCMToken in the user's database
    firestore.collection('users').doc(user?.uid).set({
      'fcmToken': fcmToken,
    }, SetOptions(merge: true));
  }
}
