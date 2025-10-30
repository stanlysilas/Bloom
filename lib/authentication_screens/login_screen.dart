import 'package:bloom/authentication_screens/authenticateuser.dart';
import 'package:bloom/authentication_screens/password_reset.dart';
import 'package:bloom/authentication_screens/signup_screen.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool loading = false;
  bool googleLoading = false;

  // Accessing user Uid
  final userId = FirebaseAuth.instance.currentUser?.uid;

  /// Toggle password show to true/false
  void togglePassword() {
    setState(() {
      // Toggle password visibility
      obscurePassword = !obscurePassword;
    });
  }

  /// Toggle confirm password show to true/false
  void toggleConfirmPassword() {
    setState(() {
      // Toggle password visibility
      obscureConfirmPassword = !obscureConfirmPassword;
    });
  }

  /// Check if the password and confirm passord are same
  bool isPasswordSameCheck() {
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Row(
        children: [
          // Display logo of bloom if width is greater than mobileWidth
          if (MediaQuery.of(context).size.width > mobileWidth)
            Expanded(
                child: Container(
              color: Theme.of(context).colorScheme.onInverseSurface,
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Image.asset(
                  'assets/icons/default_app_icon.png',
                  fit: BoxFit.contain,
                  scale: 1,
                ),
              ),
            )),
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
                    SizedBox(
                      height: 30,
                    ),
                    // Welcome message
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Display the logo/icon of the app here
                          Container(
                            width: 95,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/default_app_icon.png',
                                  scale: 20,
                                ),
                                Text(
                                  'Bloom',
                                  style: TextStyle(
                                      fontFamily: 'ClashGrotesk', fontSize: 16),
                                )
                              ],
                            ),
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
                                      fontWeight: FontWeight.bold),
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
                    const SizedBox(
                      height: 14,
                    ),
                    // Confirm password field heading
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Confirm password',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    // Confirm password text field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: MyTextfield(
                        controller: confirmPasswordController,
                        focusNode: confirmPasswordFocusNode,
                        hintText: 'password@1234',
                        textInputType: TextInputType.visiblePassword,
                        obscureText: obscureConfirmPassword,
                        autoFocus: false,
                        maxLines: 1,
                        suffixIcon: IconButton(
                          onPressed: toggleConfirmPassword,
                          icon: obscureConfirmPassword
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
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          if (isPasswordSameCheck()) {
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
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'Enter valid email address!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'Succesfully logged in as: ${emailController.text}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'Enter valid email address!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                                setState(() {
                                  loading = false;
                                });
                              } else if (e.code == 'user-disabled') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'The user corresponding to the entered email address has been disabled.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                                setState(() {
                                  loading = false;
                                });
                              } else if (e.code == 'user-not-found') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'The user corresponding to the entered email address was not found.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                                setState(() {
                                  loading = false;
                                });
                              } else if (e.code == 'wrong-password') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'The password is invalid for the given email, or the account corresponding to the email does not have a password set.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                                setState(() {
                                  loading = false;
                                });
                              } else if (e.code == 'network-request-failed') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      "There was a network request error, for example the user doesn't have internet connection.",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                                setState(() {
                                  loading = false;
                                });
                              } else if (e.code == 'invalid-credential') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      "The entered login email address or the password are invalid.",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'There was an error trying to login. ${e.toString()}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                                setState(() {
                                  loading = false;
                                });
                              }
                            }
                          } else {
                            // If both passwords don't match then warn user
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                margin: const EdgeInsets.all(6),
                                behavior: SnackBarBehavior.floating,
                                showCloseIcon: true,
                                backgroundColor: Colors.red.withAlpha(180),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content: Text(
                                  'Password and confirm password fields must be the same',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: double.maxFinite,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: loading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    year2023: false,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ),
                    // ---- OR ---- block
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16.0),
                              child: Divider()),
                        ),
                        Text(
                          'Or',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700]),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16.0),
                            child: Divider(),
                          ),
                        ),
                      ],
                    ),
                    // Google login
                    Builder(
                      builder: (context) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 15.0,
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final showHome = prefs.getBool('showHome') ?? false;
                            try {
                              setState(() {
                                googleLoading = true;
                              });
                              // Google login process
                              final userCredential =
                                  await AuthService().signUpWithGoogle();

                              if (userCredential != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'Succesfully logged in as: ${userCredential.user!.displayName ?? userCredential.user!.email}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                              } else {
                                // Login failed (or any other error)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'There was an error trying to login. $userCredential',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'Enter valid email address!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                                setState(() {
                                  googleLoading = false;
                                });
                              }
                              if (e.code == 'invalid-credential') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'The provided email or password is incorrect',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                                setState(() {
                                  googleLoading = false;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                      'There was an error trying to login. ${e.message}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            alignment: Alignment.center,
                            child: googleLoading
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        year2023: false,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        padding: const EdgeInsets.all(18.0),
                                        child: Text(
                                          'Login with Google',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 18),
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
                    // Go to SignUp screen
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
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
                              'Signup',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
