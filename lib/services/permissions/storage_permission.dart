import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class StoragePermission {
  // Check for storage permission based on the Android level of the device
  static Future<bool> init() async {
    bool? granted = false;
    final PermissionStatus status;
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (androidInfo.version.sdkInt > 30) {
        status = await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          granted = true;
        } else if (status.isDenied) {
          granted = false;
        }
      } else {
        status = await Permission.storage.request();
        if (status.isGranted) {
          granted = true;
        } else if (status.isDenied) {
          granted = false;
        }
      }
    } else {
      return true;
    }
    return granted;
  }
}
