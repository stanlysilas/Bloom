import 'dart:io';

import 'package:bloom/authentication_screens/authenticateuser.dart';
import 'package:bloom/authentication_screens/login_screen.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/components/profile_pic.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool acceptPrivacyPolicy = false;
  bool loading = false;
  bool googleLoading = false;
  String? selectedProfilePicture;
  final Uri privacyPolicyUri = Uri.parse(
      'https://bloomproductive.framer.website/privacy-policy');

  // Toggle password show to true/false
  void togglePassword() {
    setState(() {
      // Toggle password visibility
      obscurePassword = !obscurePassword;
    });
  }

  // Toggle confirmPassword show to true/false
  void toggleConfirmPassword() {
    setState(() {
      // Toggle password visibility
      obscureConfirmPassword = !obscureConfirmPassword;
    });
  }

  // Check if the password and confirm passord are same
  bool isPasswordSameCheck() {
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> launchPrivacyPolicyUrl() async {
    if (!await launchUrl(privacyPolicyUri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $privacyPolicyUri');
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.width > mobileWidth ? 30 : 0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () async {
                              final selectedPicture =
                                  await showAdaptiveDialog<String>(
                                context: context,
                                builder: (context) =>
                                    const ProfilePictureDialog(),
                              );
                              if (selectedPicture != null) {
                                setState(() {
                                  selectedProfilePicture = selectedPicture;
                                });
                              }
                            },
                            child: selectedProfilePicture != null
                                ? Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.asset(
                                          selectedProfilePicture!,
                                          scale: 10,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(Icons.edit,
                                            color: Theme.of(context)
                                                .primaryColorLight),
                                      ),
                                    ],
                                  )
                                : Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.asset(
                                          'assets/profile_pictures/Profile_Picture_Male_1.png',
                                          scale: 10,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4.0,
                                            bottom: 8.0,
                                            left: 4.0,
                                            right: 4.0),
                                        child: Icon(Icons.edit_rounded,
                                            color: Theme.of(context)
                                                .primaryColorLight),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // Welcome message
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'Signup ',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                const Text(
                                  'to start ',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                Text(
                                  'Blooming!',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
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
                        focusNode: emailFocusNode,
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
                    // const SizedBox(
                    //   height: 14,
                    // ),
                    // // Username field heading
                    // const Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 20.0),
                    //   child: Text(
                    //     'Username',
                    //     textAlign: TextAlign.left,
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    // // Username text field
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    //   child: MyTextfield(
                    //     controller: userNameController,
                    //     hintText: 'Bloom',
                    //     textInputType: TextInputType.emailAddress,
                    //     obscureText: false,
                    //     autoFocus: false,
                    //     suffixIcon: Icon(
                    //       Icons.person_outline_rounded,
                    //       color: Theme.of(context).iconTheme.color,
                    //     ),
                    //   ),
                    // ),
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
                        focusNode: passwordFocusNode,
                        hintText: 'password@1234',
                        textInputType: TextInputType.visiblePassword,
                        obscureText: obscurePassword,
                        autoFocus: false,
                        maxLines: 1,
                        suffixIcon: IconButton(
                          onPressed: togglePassword,
                          icon: obscurePassword
                              ? Icon(
                                  Icons.remove_red_eye_rounded,
                                  color: Theme.of(context).iconTheme.color,
                                )
                              : Icon(
                                  Icons.close_rounded,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                        ),
                      ),
                    ),
                    // const SizedBox(
                    //   height: 14,
                    // ),
                    // // Confirm password field heading
                    // const Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 20.0),
                    //   child: Text(
                    //     'Confirm password',
                    //     textAlign: TextAlign.left,
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    // // Confirm password text field
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    //   child: MyTextfield(
                    //     controller: confirmPasswordController,
                    //     hintText: 'password@1234',
                    //     textInputType: TextInputType.visiblePassword,
                    //     obscureText: obscureConfirmPassword,
                    //     autoFocus: false,
                    //     maxLines: 1,
                    //     suffixIcon: IconButton(
                    //       onPressed: toggleConfirmPassword,
                    //       icon: obscureConfirmPassword
                    //           ? Icon(
                    //               Iconsax.eye_slash,
                    //               color: Theme.of(context).iconTheme.color,
                    //             )
                    //           : Icon(
                    //               Iconsax.eye,
                    //               color: Theme.of(context).iconTheme.color,
                    //             ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(
                      height: 14,
                    ),
                    // Privacy policy accept button
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Checkbox(
                            value: acceptPrivacyPolicy,
                            onChanged: (newValue) => setState(() {
                              acceptPrivacyPolicy = newValue!;
                            }),
                            activeColor: Theme.of(context).primaryColor,
                            checkColor:
                                Theme.of(context).scaffoldBackgroundColor,
                          ),
                          Row(
                            children: [
                              const Text('I agree to the '),
                              InkWell(
                                onTap: () async {
                                  // Take user to privacy policy page
                                  await launchPrivacyPolicyUrl();
                                },
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 14.0),
                                child: Text(
                                    ' of Bloom and agree to share my Email for better experience.'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Signup button
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 14.0,
                        left: 10.0,
                        right: 10.0,
                      ),
                      child: InkWell(
                        mouseCursor: SystemMouseCursors.click,
                        borderRadius: BorderRadius.circular(100),
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final showHome = prefs.getBool('showHome') ?? false;
                          // signup process
                          try {
                            setState(() {
                              loading = true;
                            });
                            if (emailController.text.isNotEmpty &&
                                // userNameController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty &&
                                // isPasswordSameCheck() &&
                                acceptPrivacyPolicy == true) {
                              await AuthService().createUserWithEmailAndPassword(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                  userNameController.text.trim(),
                                  selectedProfilePicture ??
                                      'assets/profile_pictures/Profile_Picture_Male_1.png');
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => AuthenticateUser(
                                    showHome: showHome,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  margin: const EdgeInsets.all(6),
                                  behavior: SnackBarBehavior.floating,
                                  showCloseIcon: true,
                                  backgroundColor: Colors.red.withAlpha(180),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  content: Text(
                                    'Please fill the form and accept the Privacy Policy to create an account.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                              setState(() {
                                loading = false;
                              });
                            }
                          } on FirebaseAuthException catch (e) {
                            // Display error message
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
                                    'There was an error trying to create an account. ${e.toString()}',
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
                                    year2023: false,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                )
                              : Text(
                                  'Signup',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ),
                    // ---- OR ---- block
                    if (kIsWeb == false || Platform.isWindows == false)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16.0),
                            child: Divider(),
                          ),
                          Text(
                            'Or',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700]),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16.0),
                            child: Divider(),
                          ),
                        ],
                      ),
                    // Google signup
                    Builder(
                      builder: (context) => kIsWeb || Platform.isWindows
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(
                                bottom: 15.0,
                                left: 10.0,
                                right: 10.0,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(100),
                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final showHome =
                                        prefs.getBool('showHome') ?? false;
                                    //google signup process, create account only if the user accepts the privacy policy
                                    try {
                                      setState(() {
                                        googleLoading = true;
                                      });
                                      if (acceptPrivacyPolicy == true) {
                                        await AuthService().signUpWithGoogle();
                                        // Signup successful, navigate to HomeScreen
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AuthenticateUser(
                                              showHome: showHome,
                                            ),
                                          ),
                                        );
                                      } else if (acceptPrivacyPolicy == false) {
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
                                              'Accept the Privacy Policy to create an account.',
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
                                              'There was an error trying to create an account.',
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
                                    } on FirebaseAuthException catch (e) {
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
                                              'There was an error trying to create an account. ${e.toString()}',
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
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    alignment: Alignment.center,
                                    child: googleLoading
                                        ? Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: CircularProgressIndicator(
                                                year2023: false,
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
                                                scale: 25,
                                              ),
                                              const Spacer(
                                                flex: 2,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(18.0),
                                                child: Text(
                                                  'Signup with Google',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color,
                                                      fontSize: 16),
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
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: BorderRadius.circular(28)),
                    child: Image.asset(
                      'assets/icons/default_app_icon.png',
                      fit: BoxFit.contain,
                      scale: 1,
                    ),
                  ),
                ))
              : const SizedBox(),
        ],
      ),
      bottomNavigationBar:
          // Link to login
          SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account?',
              ),
              const SizedBox(
                width: 2,
              ),
              // Login page link
              InkWell(
                onTap: () {
                  // go to login page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    // color: Colors.blueGrey.shade200,
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
