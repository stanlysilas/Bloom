import 'package:bloom/core/ui/app_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BloomSnackBars {
  void showAuthErrorSnackBar(
      BuildContext context, FirebaseAuthException exception) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(6),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        closeIconColor: Theme.of(context).colorScheme.onError,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          exception.message ?? 'Exception occured while authenticating',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onError),
        ),
      ),
    );
  }

  void showGenericSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(6),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void showGenericErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(6),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        closeIconColor: Theme.of(context).colorScheme.onError,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          message,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onError),
        ),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    final context = navigatorKey.currentContext;

    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(6),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
