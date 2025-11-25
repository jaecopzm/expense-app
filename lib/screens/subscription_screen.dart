import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/premium_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initStore();
  }

  Future<void> _initStore() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      setState(() {
        _isLoading = false;
        _isAvailable = false;
      });
      return;
    }

    const Set<String> kIds = {
      'spend_wise_premium_monthly',
      'spend_wise_premium_yearly',
    };
    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails(kIds);

    setState(() {
      _isLoading = false;
      _isAvailable = true;
      _products = response.productDetails;
    });
  }

  Future<void> _buySubscription(ProductDetails product) async {
    try {
      final premiumProvider = Provider.of<PremiumProvider>(
        context,
        listen: false,
      );

      // Get device identifier for purchase validation
      final deviceId = await premiumProvider.getDeviceIdentifier();

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: deviceId, // Associate purchase with device
      );

      // Start purchase
      final success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (success) {
        // Process the purchase in our secure storage
        await premiumProvider.processPurchase(
          product.id,
          DateTime.now().millisecondsSinceEpoch
              .toString(), // Local transaction ID
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium features activated!')),
        );

        Navigator.pop(context); // Close subscription screen
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: \${e.toString()}')),
      );
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final premiumProvider = Provider.of<PremiumProvider>(
        context,
        listen: false,
      );
      await premiumProvider.restorePurchases();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchases restored successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to restore purchases')),
      );
    }
  }

  Widget _buildSubscriptionCard(ProductDetails product) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(product.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(product.description, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              product.price,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _buySubscription(product),
              child: const Text('Subscribe'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Subscription')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isAvailable
          ? const Center(child: Text('Store not available'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Unlock Premium Features',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('✓ AI-Powered Insights'),
                          Text('✓ Advanced Analytics'),
                          Text('✓ Export Data to PDF'),
                          Text('✓ Custom Theme Options'),
                          Text('✓ Priority Support'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._products.map(_buildSubscriptionCard),
                ],
              ),
            ),
    );
  }
}
