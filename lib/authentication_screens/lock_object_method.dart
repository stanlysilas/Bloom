import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

Future<bool> checkForBiometrics(
    String localizedReason, BuildContext context) async {
  final LocalAuthentication auth = LocalAuthentication();
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  bool didAuthenticate = false;
  final bool canAuthenticate =
      canAuthenticateWithBiometrics || await auth.isDeviceSupported();
  if (canAuthenticate == true) {
    try {
      didAuthenticate =
          await auth.authenticate(localizedReason: localizedReason);
      // ···
    } on PlatformException catch (e) {
      // ...
      if (e.code == 'NotAvailable') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            margin: const EdgeInsets.all(6),
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            backgroundColor: Theme.of(context).primaryColor,
            closeIconColor: Theme.of(context).textTheme.bodyMedium?.color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
              'Set a screen lock to the device and try again.',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
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
            closeIconColor: Theme.of(context).textTheme.bodyMedium?.color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
              'Exception: ${e.code}',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
        );
      }
    }
  }
  if (didAuthenticate) {
    return true;
  } else {
    return false;
  }
}
