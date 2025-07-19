import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordReset extends StatelessWidget {
  PasswordReset({
    super.key,
  });

  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset password'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal:
                MediaQuery.of(context).size.width > mobileWidth ? 180 : 0),
        child: Column(
          children: [
            // Instructions text widget
            const Padding(
              padding: EdgeInsets.all(14.0),
              child: Text(
                  "Enter your registered email and click on 'Get link' to get a password reset link."),
            ),
            // Email text field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: MyTextfield(
                controller: emailController,
                focusNode: emailFocusNode,
                hintText: 'bloomproductive@gmail.com',
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
                    if (emailController.text.trim().isNotEmpty) {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: emailController.text.trim());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          showCloseIcon: true,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                            'Enter your registered email address!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      );
                    }
                  } on FirebaseException catch (e) {
                    if (e.code == 'invalid-email') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          showCloseIcon: true,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                            'Invalid email address.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      );
                    } else if (e.code == 'user-not-found') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          showCloseIcon: true,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                            'This email is not registered.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(1000)),
                  child: Text(
                    'Get link',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
