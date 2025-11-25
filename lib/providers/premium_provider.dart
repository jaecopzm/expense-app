import 'package:flutter/material.dart';
import '../services/secure_storage.dart';

class PremiumProvider with ChangeNotifier {
  bool _isPremium = false;
  final SecureStorage _secureStorage = SecureStorage();
  String? _subscriptionType;
  DateTime? _expiryDate;

  PremiumProvider() {
    _loadPremiumStatus();
  }

  bool get isPremium => _isPremium;
  String? get subscriptionType => _subscriptionType;
  DateTime? get expiryDate => _expiryDate;

  Future<void> _loadPremiumStatus() async {
    _isPremium = await _secureStorage.verifyPremiumStatus();
    notifyListeners();
  }

  Future<void> processPurchase(String productId, String transactionId) async {
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

  Future<bool> canAccessFeature(String feature) async {
    return _isPremium;
  }

  bool canAccessAdvancedAnalytics() => _isPremium;
  bool canAccessAIInsights() => _isPremium;
  bool canExportData() => _isPremium;
  bool canCustomizeTheme() => _isPremium;
  bool canAccessFinancialGoals() => _isPremium;
  bool canAccessSmartCategories() => _isPremium;
  bool canAccessReceiptScanning() => _isPremium;
  bool canAccessBudgetTracking() => _isPremium;
}
