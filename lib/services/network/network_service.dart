import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  bool _isOnline = true;
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _controller.stream;

  Future<bool> checkConnection() async {
    if (kIsWeb) return true;

    try {
      final response = await http.head(
        Uri.parse('https://clients3.google.com/generate_204'),
      );

      final online = response.statusCode == 204;

      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(_isOnline);
      }

      return online;
    } catch (_) {
      if (_isOnline) {
        _isOnline = false;
        _controller.add(false);
      }
      return false;
    }
  }

  void showOfflineBanner(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentMaterialBanner();

    messenger.showMaterialBanner(
      MaterialBanner(
        elevation: 0,
        minActionBarHeight: 32,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        content: const Text(
          "You're offline. Some features may not work.",
          style: TextStyle(color: Colors.white),
        ),
        leading: const Icon(Icons.signal_wifi_off, color: Colors.white),
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text('DISMISS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void dispose() {
    _controller.close();
  }
}
