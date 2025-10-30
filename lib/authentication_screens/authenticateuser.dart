import "package:bloom/authentication_screens/signup_screen.dart";
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
import "package:shared_preferences/shared_preferences.dart";

class AuthenticateUser extends StatefulWidget {
  final bool showHome;
  const AuthenticateUser({super.key, required this.showHome});

  @override
  State<AuthenticateUser> createState() => _AuthenticateUserState();
}

class _AuthenticateUserState extends State<AuthenticateUser> {
  late bool showHome;

  @override
  void initState() {
    super.initState();
    showHome = widget.showHome;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
      ),
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
                  return const Center(
                      child: CircularProgressIndicator(
                    year2023: false,
                  ));
                }
                final user = snapshot.data;

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
                      bottom: false,
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

  // Google signup & add user to database
  Future<UserCredential?> signUpWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        // Web login via popup
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);

        final user = userCredential.user!;
        await addUserDetails(
          user.uid,
          user.email!,
          user.displayName ?? user.email!.split('@').first,
          user.photoURL ?? 'assets/profile_pictures/Profile_Picture_Male_1.png',
          false,
          user.photoURL != null,
        );

        return userCredential;
      } else {
        // Native sign-in flow for mobile platforms
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        final user = userCredential.user!;
        await addUserDetails(
          user.uid,
          user.email!,
          user.displayName ?? user.email!.split('@').first,
          user.photoURL ?? 'assets/profile_pictures/Profile_Picture_Male_1.png',
          false,
          user.photoURL != null,
        );

        return userCredential;
      }
    } catch (e) {
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
