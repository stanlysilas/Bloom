import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:bloom/core/utils/validator.dart';
import 'package:bloom/core/widgets/bloom_buttons.dart';
import 'package:bloom/features/auth/authenticate_user.dart';
import 'package:bloom/features/auth/widgets/auth_footer.dart';
import 'package:bloom/features/auth/widgets/auth_google_button.dart';
import 'package:bloom/features/auth/widgets/auth_submit_button.dart';
import 'package:bloom/features/auth/widgets/auth_text_field.dart';
import 'package:bloom/features/auth/widgets/signup_greeting.dart';
import 'package:bloom/features/profile/widgets/profile_pic.dart';
import 'package:bloom/core/responsive/dimensions.dart';
import 'package:bloom/services/firebase/auth_service.dart';
import 'package:bloom/services/link_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final confirmPasswordFocusNode = FocusNode();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool acceptPrivacyPolicy = false;
  final bloomSnackBars = BloomSnackBars();
  String? selectedProfilePicture;
  dynamic authResult;
  final authService = AuthService();
  final linkService = LinkService();
  final validator = Validator();

  void togglePassword() {
    setState(() => obscurePassword = !obscurePassword);
  }

  void toggleConfirmPassword() {
    setState(() => obscureConfirmPassword = !obscureConfirmPassword);
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
              )),
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
                        SizedBox(
                          height: 52,
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(100),
                                onTap: () async {
                                  final selectedPicture =
                                      await showDialog<String>(
                                    context: context,
                                    builder: (_) =>
                                        const ProfilePictureDialog(),
                                  );

                                  if (selectedPicture != null) {
                                    setState(() {
                                      selectedProfilePicture = selectedPicture;
                                    });
                                  }
                                },
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.asset(
                                        selectedProfilePicture ??
                                            'assets/profile_pictures/Profile_Picture_Male_1.png',
                                        scale: 10,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Icon(
                                        Icons.edit_rounded,
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SignupGreeting()
                            ],
                          ),
                        ),
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
                            icon: obscurePassword
                                ? Icon(Icons.remove_red_eye_rounded)
                                : Icon(Icons.close_rounded),
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
                            icon: obscurePassword
                                ? Icon(Icons.remove_red_eye_rounded)
                                : Icon(Icons.close_rounded),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Checkbox(
                                value: acceptPrivacyPolicy,
                                onChanged: (newValue) => setState(() {
                                  acceptPrivacyPolicy = newValue!;
                                }),
                              ),
                              Row(
                                children: [
                                  const Text('I agree to the '),
                                  InkWell(
                                    onTap: () async {
                                      await linkService.openPrivacyPolicy();
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
                        AuthSubmitButton(
                            onSubmit: () async {
                              final passwordsMatch = validator.isPasswordSame(
                                  passwordController.text,
                                  confirmPasswordController.text);
                              if (passwordsMatch) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final showHome =
                                    prefs.getBool('showHome') ?? false;
                                try {
                                  if (emailController.text.isNotEmpty &&
                                      passwordController.text.isNotEmpty &&
                                      acceptPrivacyPolicy == true) {
                                    authResult = await authService
                                        .createUserWithEmailAndPassword(
                                            context,
                                            emailController.text.trim(),
                                            passwordController.text.trim(),
                                            userNameController.text.trim(),
                                            selectedProfilePicture ??
                                                'assets/profile_pictures/Profile_Picture_Male_1.png');
                                    if (authResult == null) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AuthenticateUser(
                                            showHome: showHome,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    bloomSnackBars.showGenericErrorSnackBar(
                                        context,
                                        'Please fill the form and accept the Privacy Policy to create an account.');
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
                            message: 'Signup with Email'),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16.0),
                                child: Divider(),
                              ),
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
                                if (acceptPrivacyPolicy == true) {
                                  await authService
                                      .authenticateWithGoogle(context);

                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => AuthenticateUser(
                                        showHome: showHome,
                                      ),
                                    ),
                                  );
                                } else if (acceptPrivacyPolicy == false) {
                                  bloomSnackBars.showGenericErrorSnackBar(
                                      context,
                                      'Accept the Privacy Policy to create an account.');
                                } else {
                                  bloomSnackBars.showGenericErrorSnackBar(
                                      context,
                                      'There was an error trying to create an account.');
                                }
                              } on FirebaseAuthException catch (e) {
                                bloomSnackBars.showAuthErrorSnackBar(
                                    context, e);
                              }
                            },
                            message: 'Signup with Google'),
                        const AuthFooter(
                            authFooterLinkType: AuthFooterLinkType.login,
                            message: 'Already have an account?',
                            linkText: 'Login'),
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
