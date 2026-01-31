import 'package:bloom/authentication_screens/bloom_pin_service.dart';
import 'package:bloom/authentication_screens/password_entry_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

Future<bool> authenticate(String localizedReason, BuildContext context) async {
  bool didAuthenticate = false;
  bool? isPinEnabled = await BloomPinService().isPinEnabled();
  if (kIsWeb) {
    // Try authenticating with the Privacy PIN screen directly if Web
    final bool? authenticated;
    // First check if the PIN service is already enabled or not
    if (isPinEnabled) {
      // verify normally if already set
      authenticated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => PasswordEntryScreen(
            mode: PinMode.verify,
            message: localizedReason,
          ),
        ),
      );
    } else {
      // Set Privacy PIN if not set
      authenticated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => PasswordEntryScreen(
            mode: PinMode.set,
            message: 'Set your Privacy PIN to authenticate with all objects',
          ),
        ),
      );
    }
    // Return the auth state
    if (authenticated == true) {
      return true;
    } else {
      return false;
    }
  } else {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    // If not web then authenticate normally
    if (canAuthenticate == true) {
      try {
        didAuthenticate =
            await auth.authenticate(localizedReason: localizedReason);
        // ···
      } on PlatformException catch (e) {
        // ...
        if (e.code == 'NotAvailable') {
          final authenticated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => PasswordEntryScreen(
                mode: PinMode.verify,
                message: localizedReason,
              ),
            ),
          );
          if (authenticated == true) {
            return true;
          } else {
            return false;
          }
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     margin: const EdgeInsets.all(6),
          //     behavior: SnackBarBehavior.floating,
          //     showCloseIcon: true,
          //     shape:
          //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //     content: Text('Set a screen lock to the device and try again.'),
          //   ),
          // );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              margin: const EdgeInsets.all(6),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Text('Exception: ${e.code}'),
            ),
          );
        }
      } on LocalAuthException catch (e) {
        if (e.code == LocalAuthExceptionCode.noCredentialsSet) {
          if (isPinEnabled == true) {
            final authenticated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => PasswordEntryScreen(
                  mode: PinMode.verify,
                  message: localizedReason,
                ),
              ),
            );
            if (authenticated == true) {
              return true;
            } else {
              return false;
            }
          } else {
            final authenticated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => const PasswordEntryScreen(
                  mode: PinMode.set,
                  message:
                      'Set your Privacy PIN to authenticate with all objects',
                ),
              ),
            );
            if (authenticated == true) {
              return true;
            } else {
              return false;
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              margin: const EdgeInsets.all(6),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Text(
                  'There was an error trying to authenticate. Please try later.'),
            ),
          );
        }
      }
    } else {
      return false;
    }
  }
  if (didAuthenticate) {
    return true;
  } else {
    return false;
  }
}
