import 'dart:async';

import 'package:flutter/material.dart';

class AutoSaveController {
  Timer? _timer;

  void schedule(Duration delay, Future<void> Function() callback) {
    _timer?.cancel();

    _timer = Timer(delay, () async {
      debugPrint(
          "Calling the given function in schedule for autoSaveController");
      await callback();
    });
  }

  void cancel() {
    _timer?.cancel();
  }
}
