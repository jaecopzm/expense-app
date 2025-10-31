import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for secure storage
  static const String _pinKey = 'user_pin';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _autoLockTimeKey = 'auto_lock_time';
  static const String _isSetupCompleteKey = 'auth_setup_complete';
  static const String _lastActiveTimeKey = 'last_active_time';

  // Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access WizeBudge',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  // Set up PIN
  Future<bool> setupPin(String pin) async {
    try {
      final hashedPin = _hashPin(pin);
      await _secureStorage.write(key: _pinKey, value: hashedPin);
      await _secureStorage.write(key: _isSetupCompleteKey, value: 'true');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Verify PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: _pinKey);
      if (storedPin == null) return false;
      
      final hashedPin = _hashPin(pin);
      return hashedPin == storedPin;
    } catch (e) {
      return false;
    }
  }

  // Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey, 
      value: enabled.toString(),
    );
  }

  // Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  // Set auto-lock time (in minutes)
  Future<void> setAutoLockTime(int minutes) async {
    await _secureStorage.write(
      key: _autoLockTimeKey, 
      value: minutes.toString(),
    );
  }

  // Get auto-lock time
  Future<int> getAutoLockTime() async {
    final value = await _secureStorage.read(key: _autoLockTimeKey);
    return int.tryParse(value ?? '5') ?? 5; // Default 5 minutes
  }

  // Check if authentication is set up
  Future<bool> isAuthSetupComplete() async {
    final value = await _secureStorage.read(key: _isSetupCompleteKey);
    return value == 'true';
  }

  // Update last active time
  Future<void> updateLastActiveTime() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    await _secureStorage.write(key: _lastActiveTimeKey, value: now);
  }

  // Check if app should be locked based on inactivity
  Future<bool> shouldLockApp() async {
    final lastActiveStr = await _secureStorage.read(key: _lastActiveTimeKey);
    if (lastActiveStr == null) return true;

    final lastActive = DateTime.fromMillisecondsSinceEpoch(
      int.parse(lastActiveStr),
    );
    final autoLockMinutes = await getAutoLockTime();
    final lockThreshold = Duration(minutes: autoLockMinutes);
    
    return DateTime.now().difference(lastActive) > lockThreshold;
  }

  // Perform full authentication (biometric or PIN)
  Future<AuthResult> authenticate() async {
    try {
      // Check if biometric is available and enabled
      final biometricAvailable = await isBiometricAvailable();
      final biometricEnabled = await isBiometricEnabled();

      if (biometricAvailable && biometricEnabled) {
        final biometricResult = await authenticateWithBiometrics();
        if (biometricResult) {
          await updateLastActiveTime();
          return AuthResult.success();
        }
        // If biometric fails, fall back to PIN
        return AuthResult.biometricFailed();
      }

      // If biometric not available/enabled, require PIN
      return AuthResult.pinRequired();
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  // Reset authentication (for logout or reset)
  Future<void> resetAuth() async {
    await _secureStorage.deleteAll();
  }

  // Hash PIN for secure storage
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin + 'wizebudge_salt'); // Add app-specific salt
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

// Authentication result class
class AuthResult {
  final bool isSuccess;
  final AuthResultType type;
  final String? error;

  AuthResult._(this.isSuccess, this.type, this.error);

  factory AuthResult.success() => AuthResult._(true, AuthResultType.success, null);
  factory AuthResult.biometricFailed() => AuthResult._(false, AuthResultType.biometricFailed, null);
  factory AuthResult.pinRequired() => AuthResult._(false, AuthResultType.pinRequired, null);
  factory AuthResult.error(String error) => AuthResult._(false, AuthResultType.error, error);
}

enum AuthResultType {
  success,
  biometricFailed,
  pinRequired,
  error,
}