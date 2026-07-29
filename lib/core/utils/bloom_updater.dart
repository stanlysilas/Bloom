import 'dart:io';
import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:bloom/services/permissions/storage_permission.dart';
import 'package:flutter/material.dart';
import 'package:app_installer/app_installer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class BloomUpdater {
  static final bloomSnackBars = BloomSnackBars();

  static const String apkUrl =
      'https://github.com/stanlysilas/Bloom/releases/latest/download/Bloom.apk';

  static Future<void> downloadAndInstallApk(BuildContext context) async {
    try {
      if (!Platform.isAndroid) return;

      final bool status = await StoragePermission.init();
      if (status != true) {
        await StoragePermission.init();
        return;
      }

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/bloom-latest.apk';
      final file = File(filePath);

      final request =
          await http.Client().send(http.Request('GET', Uri.parse(apkUrl)));
      final total = request.contentLength ?? 0;
      int received = 0;
      final sink = file.openWrite();

      double progress = 0.0;
      StateSetter? dialogSetState;
      bool dialogMounted = true;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              dialogSetState = setState;
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  dialogMounted = false;
                  return;
                },
                child: AlertDialog(
                  icon: const Icon(Icons.download),
                  title: const Text('Downloading Update'),
                  titleTextStyle:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          'Please wait while Bloom downloads the update.'),
                      const SizedBox(height: 20),
                      const Text(
                          'NOTE: DO NOT CLOSE THE APP OR MINIMIZE IT WHILE DOWNLOADING!.'),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: progress,
                        year2023: false,
                        stopIndicatorColor: Colors.transparent,
                      ),
                      const SizedBox(height: 10),
                      Text('${(progress * 100).toStringAsFixed(0)}%'),
                    ],
                  ),
                  contentTextStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            },
          );
        },
      );

      await for (final chunk in request.stream) {
        received += chunk.length;
        sink.add(chunk);

        if (total != 0) {
          progress = received / total;
          if (dialogMounted && dialogSetState != null) {
            dialogSetState!(() {});
          }
        }
      }

      await sink.close();

      if (dialogMounted &&
          Navigator.of(context, rootNavigator: true).canPop()) {
        dialogMounted = false;
        Navigator.of(context, rootNavigator: true).pop();
      }

      AppInstaller.installApk(filePath);

      bloomSnackBars.showSuccessSnackBar(
          'Downloaded update. Please install to continue.');
    } catch (e) {
      debugPrint('Update failed: $e');
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      bloomSnackBars.showGenericErrorSnackBar(
          context, 'Failed to download update: $e');
    }
  }
}
