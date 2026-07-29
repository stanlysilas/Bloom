import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:bloom/services/permissions/bloom_pin_service.dart';
import 'package:bloom/features/auth/pin_entry_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

Future<bool> authenticate(String localizedReason, BuildContext context) async {
  final bool isPinEnabled = await BloomPinService().isPinEnabled();
  final bloomSnackBars = BloomSnackBars();

  Future<bool> openPinFlow(PinMode mode, String message) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PinEntryScreen(
          mode: mode,
          message: message,
        ),
      ),
    );
    return result == true;
  }

  if (kIsWeb) {
    return openPinFlow(
      isPinEnabled ? PinMode.verify : PinMode.set,
      isPinEnabled
          ? localizedReason
          : 'Set your Privacy PIN to authenticate with all objects',
    );
  }

  final LocalAuthentication auth = LocalAuthentication();
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  final bool canAuthenticate =
      canAuthenticateWithBiometrics || await auth.isDeviceSupported();

  if (!canAuthenticate) return false;

  try {
    final bool didAuthenticate =
        await auth.authenticate(localizedReason: localizedReason);
    if (didAuthenticate) return true;
  } on PlatformException catch (e) {
    if (e.code == 'NotAvailable') {
      return openPinFlow(PinMode.verify, localizedReason);
    } else {
      bloomSnackBars.showGenericErrorSnackBar(
          context, 'Exception occured: ${e.code}');
    }
  } on LocalAuthException catch (e) {
    if (e.code == LocalAuthExceptionCode.noCredentialsSet) {
      return openPinFlow(
        isPinEnabled ? PinMode.verify : PinMode.set,
        isPinEnabled
            ? localizedReason
            : 'Set your Privacy PIN to authenticate with all objects',
      );
    } else {
      bloomSnackBars.showGenericErrorSnackBar(context,
          'There was an error trying to authenticate. Please try later.');
    }
  }

  return false;
}
