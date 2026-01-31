import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class BloomPinService {
  static const int _defaultIterations = 150000;
  static const int _saltLengthBytes = 16;
  static const int _keyLengthBytes = 32; // 256-bit

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BloomPinService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> _pinDoc() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user');

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('security')
        .doc('bloomPin');
  }

  /// Secure random salt
  List<int> _generateSaltBytes() {
    final rnd = Random.secure();
    return List<int>.generate(
      _saltLengthBytes,
      (_) => rnd.nextInt(256),
    );
  }

  /// PBKDF2 hash
  Future<List<int>> _deriveHashBytes({
    required String pin,
    required List<int> salt,
    required int iterations,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: _keyLengthBytes * 8,
    );

    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );

    return secretKey.extractBytes();
  }

  /// Set or update PIN
  Future<void> setPin(String pin) async {
    if (!RegExp(r'^\d{4,12}$').hasMatch(pin)) {
      throw ArgumentError('PIN must be 4–12 digits');
    }

    final saltBytes = _generateSaltBytes();
    final hashBytes = await _deriveHashBytes(
      pin: pin,
      salt: saltBytes,
      iterations: _defaultIterations,
    );

    final doc = _pinDoc();
    final snap = await doc.get();

    await doc.set({
      'pinHash': base64Encode(hashBytes),
      'salt': base64Encode(saltBytes),
      'iterations': _defaultIterations,
      'algorithm': 'PBKDF2-HMAC-SHA256',
      'enabled': true,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!snap.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final snap = await _pinDoc().get();
    if (!snap.exists) return false;

    final data = snap.data()!;
    if (data['enabled'] != true) return false;

    final salt = base64Decode(data['salt']);
    final storedHash = base64Decode(data['pinHash']);
    final iterations = data['iterations'] as int;

    final derivedHash = await _deriveHashBytes(
      pin: pin,
      salt: salt,
      iterations: iterations,
    );

    return _constantTimeEquals(storedHash, derivedHash);
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  /// Disable PIN
  Future<void> clearPin() async {
    await _pinDoc().set({
      'enabled': false,
      'pinHash': null,
      'salt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Check PIN status
  Future<bool> isPinEnabled() async {
    final snap = await _pinDoc().get();
    return snap.exists && snap.data()?['enabled'] == true;
  }

  /// Check if the platform is Web or other
  bool isWeb() {
    final isWeb = kIsWeb;
    return isWeb;
  }

  /// Display the Privacy PIN screen directly if it's web
  // Future<bool> authenticateWithPIN(BuildContext context) async {
  //   if (kIsWeb) {
  //     // Display the Privacy PIN Screen here and return the value
  //     final authenticated = await Navigator.push<bool>(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => PasswordEntryScreen(mode: PinMode.verify, )));
  //     if (authenticated == true) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } else {}
  // }
}
