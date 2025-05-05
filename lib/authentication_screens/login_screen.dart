import 'dart:io';

import 'package:bloom/authentication_screens/authenticateuser.dart';
import 'package:bloom/authentication_screens/password_reset.dart';
import 'package:bloom/authentication_screens/signup_screen.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscureText = true;
  bool loading = false;
  bool googleLoading = false;

  // Accessing user Uid
  final userId = FirebaseAuth.instance.currentUser?.uid;

  // Toggle password show to true/false
  void togglePassword() {
    setState(() {
      // Toggle password visibility
      obscureText = !obscureText;
    });
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
        ),
        body: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width > mobileWidth ? 80 : 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message
                      SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Display the logo/icon of the app here
                            Image.asset(
                              'assets/icons/default_app_icon_light.png',
                              scale: 20,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Text(
                                    ' did you miss the way you ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Bloomed?',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      // Email field heading
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Email',
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      // Email text field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: MyTextfield(
                          controller: emailController,
                          hintText: 'bloomproductive@gmail.com',
                          textInputType: TextInputType.emailAddress,
                          obscureText: false,
                          autoFocus: false,
                          suffixIcon: Icon(
                            Icons.email_outlined,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      // Password field heading
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Password',
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      // Password text field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: MyTextfield(
                          controller: passwordController,
                          hintText: 'password@1234',
                          textInputType: TextInputType.visiblePassword,
                          obscureText: obscureText,
                          autoFocus: false,
                          maxLines: 1,
                          suffixIcon: IconButton(
                            onPressed: togglePassword,
                            icon: obscureText
                                ? Icon(
                                    Iconsax.eye_slash,
                                    color: Theme.of(context).iconTheme.color,
                                  )
                                : Icon(
                                    Iconsax.eye,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                          ),
                        ),
                      ),
                      // Forgot password?
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.0,
                          right: 15.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () async {
                                // forgot password recovery process
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PasswordReset()));
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Login button
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.0,
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: InkWell(
                          mouseCursor: SystemMouseCursors.click,
                          borderRadius: BorderRadius.circular(1000),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final showHome = prefs.getBool('showHome') ?? false;
                            // login process
                            try {
                              if (emailController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    content: Text(
                                      'Enter valid email address!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  loading = true;
                                });
                                await AuthService().loginUser(
                                    emailController.text.trim(),
                                    passwordController.text.trim());
                                // Show login confirmation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    content: Text(
                                      'Succesfully logged in as: ${emailController.text}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ),
                                );
                                // Login successful, navigate to HomeScreen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AuthenticateUser(
                                      showHome: showHome,
                                    ),
                                  ),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              // Handle login errors (display error message)
                              if (e.code == 'invalid-email') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    content: Text(
                                      'Enter valid email address!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ),
                                );
                                setState(() {
                                  loading = false;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    content: Text(
                                      'There was an error trying to login. ${e.toString()}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ),
                                );
                                setState(() {
                                  loading = false;
                                });
                              }
                            }
                          },
                          child: Container(
                            width: double.maxFinite,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: loading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      ),
                      // ---- OR ---- block
                      kIsWeb || Platform.isWindows
                          ? const SizedBox()
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Divider(
                                      height: 40,
                                    ),
                                  ),
                                ),
                                Text(
                                  'OR',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700]),
                                ),
                                const Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Divider(
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      // Google login
                      Builder(
                        builder: (context) => kIsWeb || Platform.isWindows
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 15.0,
                                  left: 10.0,
                                  right: 10.0,
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final showHome =
                                        prefs.getBool('showHome') ?? false;
                                    try {
                                      setState(() {
                                        googleLoading = true;
                                      });
                                      // Google login process
                                      final userCredential =
                                          await AuthService().signUpWithGoogle();
      
                                      if (userCredential != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            margin: const EdgeInsets.all(6),
                                            behavior: SnackBarBehavior.floating,
                                            showCloseIcon: true,
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            content: Text(
                                              'Succesfully logged in as: ${userCredential.user!.displayName ?? userCredential.user!.email}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                              ),
                                            ),
                                          ),
                                        );
                                        // Login successful, navigate to HomeScreen
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AuthenticateUser(
                                              showHome: showHome,
                                            ),
                                          ),
                                        );
                                      } else {
                                        // Login failed (or any other error)
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            margin: const EdgeInsets.all(6),
                                            behavior: SnackBarBehavior.floating,
                                            showCloseIcon: true,
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            content: Text(
                                              'There was an error trying to login.',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                              ),
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          googleLoading = false;
                                        });
                                      }
                                    } on FirebaseException catch (e) {
                                      // Handle login errors (display error message)
                                      if (e.code == 'invalid-email') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            margin: const EdgeInsets.all(6),
                                            behavior: SnackBarBehavior.floating,
                                            showCloseIcon: true,
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            content: Text(
                                              'Enter valid email address!',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                              ),
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          googleLoading = false;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            margin: const EdgeInsets.all(6),
                                            behavior: SnackBarBehavior.floating,
                                            showCloseIcon: true,
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            content: Text(
                                              'There was an error trying to login. ${e.toString()}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                              ),
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          googleLoading = false;
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1000),
                                        color: Theme.of(context).primaryColor),
                                    alignment: Alignment.center,
                                    child: googleLoading
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                              ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Spacer(),
                                              Image.asset(
                                                'assets/auth_images/google_logo.png',
                                                scale: 22,
                                              ),
                                              const Spacer(
                                                flex: 2,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(18.0),
                                                child: Text(
                                                  'Login with Google',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium
                                                        ?.color,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(
                                                flex: 4,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Display logo of bloom if width is greater than mobileWidth
            MediaQuery.of(context).size.width > mobileWidth
                ? Expanded(
                    child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/icons/bloom_app_icon_light.png',
                        fit: BoxFit.cover,
                        scale: 1,
                      ),
                    ),
                  ))
                : const SizedBox(),
          ],
        ),
        bottomNavigationBar: // Link to signup
            Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              // Signup page link
              InkWell(
                onTap: () {
                  // go to signup page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                child: Text(
                  'Create one from here.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).primaryColor,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
