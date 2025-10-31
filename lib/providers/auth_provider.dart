import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isSetupComplete = false;
  String? _error;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isSetupComplete => _isSetupComplete;
  String? get error => _error;

  // Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _isSetupComplete = await _authService.isAuthSetupComplete();

      if (_isSetupComplete) {
        // Check if app should be locked due to inactivity
        final shouldLock = await _authService.shouldLockApp();
        _isAuthenticated = !shouldLock;
      } else {
        _isAuthenticated = true; // Allow access to setup
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Set up PIN authentication
  Future<bool> setupPin(String pin) async {
    _setLoading(true);
    try {
      final success = await _authService.setupPin(pin);
      if (success) {
        _isSetupComplete = true;
        _isAuthenticated = true;
        _clearError();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Authenticate with PIN
  Future<bool> authenticateWithPin(String pin) async {
    _setLoading(true);
    try {
      final success = await _authService.verifyPin(pin);
      if (success) {
        _isAuthenticated = true;
        await _authService.updateLastActiveTime();
        _clearError();
      } else {
        _setError('Invalid PIN');
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    _setLoading(true);
    try {
      final result = await _authService.authenticate();

      switch (result.type) {
        case AuthResultType.success:
          _isAuthenticated = true;
          _clearError();
          return true;
        case AuthResultType.biometricFailed:
          _setError('Biometric authentication failed');
          return false;
        case AuthResultType.pinRequired:
          _setError('PIN required');
          return false;
        case AuthResultType.error:
          _setError(result.error ?? 'Authentication error');
          return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check biometric availability
  Future<bool> isBiometricAvailable() async {
    return await _authService.isBiometricAvailable();
  }

  // Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _authService.setBiometricEnabled(enabled);
    notifyListeners();
  }

  // Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    return await _authService.isBiometricEnabled();
  }

  // Set auto-lock time
  Future<void> setAutoLockTime(int minutes) async {
    await _authService.setAutoLockTime(minutes);
    notifyListeners();
  }

  // Get auto-lock time
  Future<int> getAutoLockTime() async {
    return await _authService.getAutoLockTime();
  }

  // Lock the app
  void lockApp() {
    _isAuthenticated = false;
    notifyListeners();
  }

  // Logout and reset
  Future<void> logout() async {
    await _authService.resetAuth();
    _isAuthenticated = false;
    _isSetupComplete = false;
    _clearError();
    notifyListeners();
  }

  // Update activity (call this on user interaction)
  Future<void> updateActivity() async {
    if (_isAuthenticated) {
      await _authService.updateLastActiveTime();
    }
  }

  // Check if app should auto-lock
  Future<void> checkAutoLock() async {
    if (_isAuthenticated && _isSetupComplete) {
      final shouldLock = await _authService.shouldLockApp();
      if (shouldLock) {
        lockApp();
      }
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
