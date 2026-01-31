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

  /// Function to initialise notifications
  Future<void> initNotifications() async {
    // Fetch the FCM token for the device
    final fcmToken = await firebaseMessaging.getToken();
    // Store the FCMToken in the user's database
    firestore.collection('users').doc(user?.uid).update({
      'fcmToken': fcmToken,
    });
  }

  /// Read the list of notification ID's stored in Firestore and retrieve them.
  /// Also check the cached list of ID's and remove or add old and new ID's respectively.
  // Future<List<int>> getNotificationID() async {
  //   // 1. Verify User is logged in
  //   final currentUser = FirebaseAuth.instance.currentUser;

  //   if (currentUser == null) {
  //     print('Error: No user is currently signed in.');
  //     return [];
  //   }

  //   try {
  //     // 2. Access doc using a verified UID
  //     final doc =
  //         await firestore.collection('users').doc(currentUser.uid).get();

  //     if (!doc.exists) {
  //       print(
  //           'User document for UID ${currentUser.uid} does not exist in Firestore.');
  //       // This is where you might want to call a "Create User Profile" function
  //       return [];
  //     }

  //     final data = doc.data();
  //     if (data == null || !data.containsKey('notificationIds')) {
  //       return [];
  //     }

  //     // 3. Safe casting for Web/Mobile
  //     final List<dynamic> rawList = data['notificationIds'] ?? [];
  //     return rawList.map((e) => int.parse(e.toString())).toList();
  //   } catch (e) {
  //     print('Firestore Error: $e');
  //     return [];
  //   }
  // }
}
