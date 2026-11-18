import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:bloom/core/utils/validator.dart';
import 'package:bloom/core/widgets/bloom_buttons.dart';
import 'package:bloom/features/auth/authenticate_user.dart';
import 'package:bloom/features/auth/password_reset_screen.dart';
import 'package:bloom/core/responsive/dimensions.dart';
import 'package:bloom/features/auth/widgets/auth_footer.dart';
import 'package:bloom/features/auth/widgets/auth_google_button.dart';
import 'package:bloom/features/auth/widgets/auth_submit_button.dart';
import 'package:bloom/features/auth/widgets/auth_text_field.dart';
import 'package:bloom/features/auth/widgets/login_greeting.dart';
import 'package:bloom/services/firebase/auth_service.dart';
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
  final authService = AuthService();
  final bloomSnackBars = BloomSnackBars();
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final validator = Validator();

  void togglePassword() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  void toggleConfirmPassword() {
    setState(() {
      obscureConfirmPassword = !obscureConfirmPassword;
    });
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
      body: SafeArea(
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width > mobileWidth)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Image.asset(
                      'assets/icons/default_app_icon_png.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width > mobileWidth
                        ? 550
                        : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 14,
                      children: [
                        const SizedBox(
                          height: 52,
                        ),
                        const LoginGreeting(),
                        AuthTextField(
                          title: 'Email',
                          controller: emailController,
                          focusNode: emailFocusNode,
                          textInputType: TextInputType.emailAddress,
                          hintText: 'bloomproductive@gmail.com',
                          obscureText: false,
                          autoFocus: true,
                          suffixIcon: Icon(
                            Icons.email_outlined,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        AuthTextField(
                          title: 'Password',
                          controller: passwordController,
                          focusNode: passwordFocusNode,
                          textInputType: TextInputType.visiblePassword,
                          obscureText: obscurePassword,
                          autoFocus: false,
                          suffixIcon: BloomIconButton(
                            onTap: togglePassword,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
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
                        AuthTextField(
                          title: 'Confirm Password',
                          controller: confirmPasswordController,
                          focusNode: confirmPasswordFocusNode,
                          textInputType: TextInputType.visiblePassword,
                          obscureText: obscureConfirmPassword,
                          autoFocus: false,
                          suffixIcon: BloomIconButton(
                            onTap: toggleConfirmPassword,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () async {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        PasswordResetScreen()));
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AuthSubmitButton(
                            onSubmit: () async {
                              if (validator.isPasswordSame(
                                  passwordController.text,
                                  confirmPasswordController.text)) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final showHome =
                                    prefs.getBool('showHome') ?? false;
                                try {
                                  if (emailController.text.isEmpty) {
                                    bloomSnackBars.showGenericErrorSnackBar(
                                        context, 'Enter valid email address!');
                                  } else {
                                    await authService.loginUser(
                                        emailController.text.trim(),
                                        passwordController.text.trim());

                                    bloomSnackBars.showSuccessSnackBar(
                                        "Succesfully logged in as: ${emailController.text}");

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
                                  bloomSnackBars.showAuthErrorSnackBar(
                                      context, e);
                                }
                              } else {
                                bloomSnackBars.showGenericErrorSnackBar(context,
                                    'Password and confirm password fields must be the same');
                              }
                            },
                            message: 'Login with Email'),
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
                        AuthGoogleButton(
                            onSubmit: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final showHome =
                                  prefs.getBool('showHome') ?? false;
                              try {
                                final authResult = await authService
                                    .authenticateWithGoogle(context);

                                if (authResult != null) {
                                  bloomSnackBars.showSuccessSnackBar(
                                      'Succesfully logged in as: ${authResult.user!.displayName ?? authResult.user!.email}');
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuthenticateUser(
                                        showHome: showHome,
                                      ),
                                    ),
                                  );
                                } else {
                                  bloomSnackBars.showGenericErrorSnackBar(
                                      context,
                                      'There was an error trying to login. $authResult');
                                }
                              } on FirebaseAuthException catch (e) {
                                bloomSnackBars.showAuthErrorSnackBar(
                                    context, e);
                              }
                            },
                            message: 'Login with Google'),
                        const AuthFooter(
                            authFooterLinkType: AuthFooterLinkType.signup,
                            message: "Don't have an account?",
                            linkText: 'Signup now'),
                        const SizedBox(height: 52)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
