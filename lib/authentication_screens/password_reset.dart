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
                MediaQuery.of(context).size.width > mobileWidth ? 250 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                borderRadius: BorderRadius.circular(100),
                onTap: () async {
                  // Logic to send password reset link to the entered email
                  try {
                    if (emailController.text.trim().isNotEmpty) {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: emailController.text.trim());
                      // Clear the email field and send a snackbar for acknowledgement
                      emailController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          showCloseIcon: true,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                            'Password reset link has been sent to the above email address',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      );
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
            ),
            // Some important information about the mail and password reset option that users should know about
            Text(
              'Steps:',
              style: TextStyle(fontSize: 24),
            ),
            Text('• Enter your registered email'),
            Text('• Click on Get link'),
            Text(
                '• An email with the password reset link will be sent to the entered email'),
            Text('• Click on the link and enter your new password and save'),
            Text(
                '• Come back and login again with your email and new password'),
            Text(
              'Important:',
              style: TextStyle(fontSize: 24),
            ),
            Text(
                '• If you do not see any email in you Primary inbox, please check the Spam folder'),
            Text('• The password reset link is absolutely safe to click on'),
          ],
        ),
      ),
    );
  }
}
