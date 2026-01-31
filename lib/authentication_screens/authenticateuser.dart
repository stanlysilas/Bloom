import "dart:async";

import "package:bloom/authentication_screens/signup_screen.dart";
import "package:bloom/components/show_updates_dialog.dart";
import "package:bloom/loading_animation.dart";
import "package:bloom/responsive/dimensions.dart";
import "package:bloom/responsive/mobile_body.dart";
import "package:bloom/screens/onboarding_screen.dart";
import "package:bloom/windows_components/custom_title_bar.dart";
import "package:bloom/windows_components/navigationrail.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_colorpicker/flutter_colorpicker.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

class AuthenticateUser extends StatefulWidget {
  final bool showHome;
  const AuthenticateUser({super.key, required this.showHome});

  @override
  State<AuthenticateUser> createState() => _AuthenticateUserState();
}

class _AuthenticateUserState extends State<AuthenticateUser> {
  late bool showHome;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    showHome = widget.showHome;
    // Check every 5 seconds only if its not web
    if (!kIsWeb) {
      _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        bool connected = await hasInternet();
        if (!connected) {
          _showBanner();
        } else {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        }
      });
    }
  }

  void _showBanner() {
    // Only show if one isn't already visible to avoid stacking
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        elevation: 0,
        minActionBarHeight: 32,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        content: Text('Not Connected to the Internet',
            style: TextStyle(color: Colors.white)),
        leading: Icon(Icons.signal_wifi_off, color: Colors.white),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: Text('DISMISS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final appData = await FirebaseFirestore.instance
        .collection('appData')
        .doc('appData')
        .get();

    if (!appData.exists) return;

    final buildNumberAndroid = appData.data()?['buildNumberAndroid'];
    final latestAndroidVersion = appData.data()?['latestAndroidVersion'];
    final updateCollectionId = "$latestAndroidVersion+$buildNumberAndroid";

    // Just check if there is ANY unseen update for this specific version
    final snapshot = await FirebaseFirestore.instance
        .collection('appData')
        .doc('update_dialog')
        .collection(updateCollectionId)
        .get();

    final seenIds = prefs.getStringList('seenUpdateIds') ?? [];
    final hasUnseen =
        snapshot.docs.any((doc) => !seenIds.contains(doc.data()['updateId']));

    if (hasUnseen) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => UpdatesDialog(updatesCollectionId: updateCollectionId),
      );
    }
  }

  Future<bool> hasInternet() async {
    try {
      if (kIsWeb) {
        return true;
      } else {
        // We use a HEAD request because it's lightweight (no body downloaded)
        final response = await http.head(Uri.parse('https://google.com'));
        return response.statusCode == 200;
      }
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(toolbarHeight: 0),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows)
            const Customtitlebar(),
          Expanded(
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // Handle errors (display error message)
                  return Center(
                      child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.black),
                  ));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while waiting for auth state
                  return const BreathingLoader();
                }
                final user = snapshot.data;

                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final prefs = await SharedPreferences.getInstance();
                  final bool showHome = prefs.getBool('showHome') ?? false;
                  if (showHome == true && user != null) {
                    // Call the dialog only after the user logs in and homescreen is shown and there is a user id
                    _checkForUpdates(
                        context); // Check for the Updates to call the dialog if necessary
                  }
                  // final notificationIDs =
                  //     await FirebaseAPI().getNotificationID();
                  // print(notificationIDs);
                  // NotificationService.checkNotificationIds();
                });

                if (user == null) {
                  // User is not logged in
                  return showHome
                      ? const SignupScreen()
                      : OnboardingScreen(onComplete: () async {
                          // Save `showHome` to true in SharedPreferences
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('showHome', true);

                          setState(() {
                            showHome = true;
                          });
                        });
                } else {
                  // User is logged in
                  return SafeArea(
                      child: MediaQuery.of(context).size.width < mobileWidth
                          ? const MobileBody()
                          : const Navigationrail());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AuthService {
  // Login user method
  Future loginUser(String email, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signUpWithGoogle() async {
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
        if (googleUser == null) return null; // User cancelled the flow

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

      // Check if user is null immediately
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
    } catch (e) {
      print("Sign-in failed: $e");
      return null;
    }
  }

  // Store the selected profile picture
  Future createUserWithEmailAndPassword(String email, String password,
      String userName, String profilePicture) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user; // Get the created user object

      if (user != null) {
        await addUserDetails(user.uid, user.email!, userName, profilePicture,
            true, false); // Pass user object
      }
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth errors (display error message)
      return e.code;
    }
  }

  // Add user details to database if they choose google (extracted for clarity)
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
