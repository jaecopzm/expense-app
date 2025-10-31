import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecureStorage {
  static const String _premiumKey = 'premium_status';
  static const String _deviceIdKey = 'device_id';
  final _storage = const FlutterSecureStorage();

  Future<String> getDeviceId() async {
    // Try to get existing device ID
    String? deviceId = await _storage.read(key: _deviceIdKey);

    if (deviceId == null) {
      // Generate a unique device ID if none exists
      deviceId = _generateUniqueId();
      await _storage.write(key: _deviceIdKey, value: deviceId);
    }

    return deviceId;
  }

  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    final combined = timestamp + random;
    return sha256.convert(utf8.encode(combined)).toString();
  }

  Future<void> storePurchaseData(Map<String, dynamic> purchaseData) async {
    final deviceId = await getDeviceId();
    final verificationHash = _generateVerificationHash(purchaseData, deviceId);

    final secureData = {
      ...purchaseData,
      'deviceId': deviceId,
      'verificationHash': verificationHash,
    };

    await _storage.write(key: _premiumKey, value: json.encode(secureData));
  }

  String _generateVerificationHash(Map<String, dynamic> data, String deviceId) {
    final content = json.encode(data) + deviceId + 'YOUR_APP_SECRET_KEY';
    return sha256.convert(utf8.encode(content)).toString();
  }

  Future<bool> verifyPremiumStatus() async {
    try {
      final storedData = await _storage.read(key: _premiumKey);
      if (storedData == null) return false;

      final data = json.decode(storedData) as Map<String, dynamic>;
      final deviceId = await getDeviceId();

      // Verify device ID matches
      if (data['deviceId'] != deviceId) return false;

      // Verify hash
      final expectedHash = _generateVerificationHash(
        Map<String, dynamic>.from(data)..remove('verificationHash'),
        deviceId,
      );

      if (data['verificationHash'] != expectedHash) return false;

      // Check if subscription is still valid
      final expiryDate = DateTime.parse(data['expiryDate']);
      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      return false;
    }
  }

  Future<void> clearPremiumStatus() async {
    await _storage.delete(key: _premiumKey);
  }
}
