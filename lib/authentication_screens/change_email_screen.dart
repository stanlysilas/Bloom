import 'package:bloom/components/mytextfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangeEmailScreen extends StatelessWidget {
  ChangeEmailScreen({
    super.key,
  });

  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Email',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Instructions text widget
          const Padding(
            padding: EdgeInsets.all(14.0),
            child: Text(
                "Enter your registered email and click on 'Get link' to get an email change link."),
          ),
          // Email text field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: MyTextfield(
              controller: emailController,
              focusNode: emailFocusNode,
              hintText: 'Enter your registered email',
              obscureText: false,
              autoFocus: false,
              textInputType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          // Submit / Get link button
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: InkWell(
              onTap: () async {
                // Logic to send password reset link to the entered email
                try {
                  // FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential)
                  if (emailController.text.trim().isNotEmpty) {
                    await FirebaseAuth.instance.currentUser!
                        .verifyBeforeUpdateEmail(
                      emailController.text.trim(),
                    )
                        .then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email change link sent.'),
                        ),
                      );
                    }).catchError((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Failed to send email change link. Error code: $value'),
                        ),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter your registered email address!'),
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'invalid-email') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid email address.'),
                      ),
                    );
                  } else if (e.code == 'user-not-found') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This email is not registered.'),
                      ),
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Failed to send email change link. Error code: ${e.code}'),
                    ),
                  );
                }
              },
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  'Get link',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).scaffoldBackgroundColor),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
