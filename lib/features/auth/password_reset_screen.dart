import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:bloom/core/responsive/dimensions.dart';
import 'package:bloom/features/auth/widgets/auth_submit_button.dart';
import 'package:bloom/features/auth/widgets/auth_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordResetScreen extends StatelessWidget {
  PasswordResetScreen({
    super.key,
  });

  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();
  final bloomSnackBars = BloomSnackBars();

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
          spacing: 14,
          children: [
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
            const SizedBox(height: 24),
            AuthSubmitButton(
                onSubmit: () async {
                  // Logic to send password reset link to the entered email
                  try {
                    if (emailController.text.trim().isNotEmpty) {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: emailController.text.trim());
                      // Clear the email field and send a snackbar for acknowledgement
                      emailController.clear();
                      bloomSnackBars.showSuccessSnackBar(
                          'Password reset link has been sent to the above email address');
                    } else {
                      bloomSnackBars.showGenericErrorSnackBar(
                          context, 'Enter your registered email address!');
                    }
                  } on FirebaseAuthException catch (e) {
                    bloomSnackBars.showAuthErrorSnackBar(context, e);
                  }
                },
                message: 'Get link'),
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
