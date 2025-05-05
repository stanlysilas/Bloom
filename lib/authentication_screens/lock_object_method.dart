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
  debugPrint("Can Authenticate: $canAuthenticate");
  if (canAuthenticate == true) {
    try {
      didAuthenticate = await auth.authenticate(
          localizedReason: localizedReason,
          options: const AuthenticationOptions(stickyAuth: true));
      debugPrint("Did Authenticate: $didAuthenticate");
      // ···
    } on PlatformException catch (e) {
      // ...
      if (e.code == 'NotAvailable') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Set a screen lock to the device and try again.')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Exception: ${e.code}')));
      }
    }
  }
  if (didAuthenticate) {
    return true;
  } else {
    return false;
  }
}
