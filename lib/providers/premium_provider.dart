import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../services/secure_storage.dart';

// DEVELOPMENT MODE: Premium features are enabled for all users
// To re-enable premium restrictions, change isPremium getter and all canAccess methods
// to return their original logic instead of hardcoded true values

class PremiumProvider with ChangeNotifier {
  bool _isPremium = true; // Set to true for development/testing
  final SecureStorage _secureStorage = SecureStorage();
  String? _subscriptionType;
  DateTime? _expiryDate;

  PremiumProvider() {
    _loadPremiumStatus();
  }

  bool get isPremium => true; // Always return true for development
  String? get subscriptionType => _subscriptionType;
  DateTime? get expiryDate => _expiryDate;

  Future<void> _loadPremiumStatus() async {
    _isPremium = await _secureStorage.verifyPremiumStatus();
    notifyListeners();
  }

  Future<void> processPurchase(String productId, String transactionId) async {
    // Determine subscription duration based on product
    final duration = productId.contains('yearly')
        ? const Duration(days: 365)
        : const Duration(days: 30);

    final purchaseData = {
      'productId': productId,
      'transactionId': transactionId,
      'purchaseDate': DateTime.now().toIso8601String(),
      'expiryDate': DateTime.now().add(duration).toIso8601String(),
      'subscriptionType': productId.contains('yearly') ? 'yearly' : 'monthly',
    };

    await _secureStorage.storePurchaseData(purchaseData);
    await _loadPremiumStatus();
  }

  Future<void> restorePurchases() async {
    await _loadPremiumStatus();
  }

  Future<String> getDeviceIdentifier() async {
    return _secureStorage.getDeviceId();
  }

  // Premium feature checks - always return true for development
  Future<bool> canAccessFeature(String feature) async {
    return true; // Always allow access during development
  }

  bool canAccessAdvancedAnalytics() => true; // Always true for development
  bool canAccessAIInsights() => true; // Always true for development
  bool canExportData() => true; // Always true for development
  bool canCustomizeTheme() => true; // Always true for development
  bool canAccessFinancialGoals() => true; // Always true for development
  bool canAccessSmartCategories() => true; // Always true for development
}
