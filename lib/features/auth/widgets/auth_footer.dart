import 'package:bloom/features/auth/login_screen.dart';
import 'package:bloom/features/auth/signup_screen.dart';
import 'package:flutter/material.dart';

enum AuthFooterLinkType { login, signup }

class AuthFooter extends StatelessWidget {
  final String message;
  final String linkText;
  final AuthFooterLinkType authFooterLinkType;
  const AuthFooter(
      {super.key,
      required this.authFooterLinkType,
      required this.message,
      required this.linkText});

  @override
  Widget build(BuildContext context) {
    final Widget navigateTo = authFooterLinkType == AuthFooterLinkType.login
        ? const LoginScreen()
        : const SignupScreen();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
          ),
          const SizedBox(
            width: 2,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => navigateTo,
                ),
              );
            },
            child: Text(
              linkText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        ],
      ),
    );
  }
}
