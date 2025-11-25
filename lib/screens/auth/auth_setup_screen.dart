import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme_enhanced.dart';

class AuthSetupScreen extends StatefulWidget {
  const AuthSetupScreen({super.key});

  @override
  State<AuthSetupScreen> createState() => _AuthSetupScreenState();
}

class _AuthSetupScreenState extends State<AuthSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _pin = '';
  String _confirmPin = '';
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _biometricAvailable = await authProvider.isBiometricAvailable();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _buildWelcomePage(),
            _buildPinSetupPage(),
            if (_biometricAvailable) _buildBiometricPage(),
            _buildCompletePage(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Container(
      decoration: BoxDecoration(gradient: AppThemeEnhanced.primaryGradient),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.shield_rounded,
              size: 72,
              color: AppThemeEnhanced.primaryLight,
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Secure Your\nFinancial Data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Set up a PIN to protect your finances.\nYour data stays private and secure.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppThemeEnhanced.primaryLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Set Up PIN',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _skipSetup(),
            child: Text(
              'Skip for now',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinSetupPage() {
    final isConfirming = _pin.length == 4;
    final currentPin = isConfirming ? _confirmPin : _pin;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          Icon(
            isConfirming ? Icons.check_circle_outline : Icons.lock_outline,
            size: 64,
            color: AppThemeEnhanced.primaryLight,
          ),
          const SizedBox(height: 32),
          Text(
            isConfirming ? 'Confirm Your PIN' : 'Create a PIN',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppThemeEnhanced.neutral900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isConfirming
                ? 'Enter your PIN again to confirm'
                : 'Choose a 4-digit PIN to secure your app',
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white60
                  : AppThemeEnhanced.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < currentPin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: isFilled ? 20 : 16,
                height: isFilled ? 20 : 16,
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppThemeEnhanced.primaryLight
                      : Colors.transparent,
                  border: Border.all(
                    color: AppThemeEnhanced.primaryLight,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          const Spacer(),
          // Number pad
          _buildNumberPad(isConfirming),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNumberPad(bool isConfirming) {
    return Column(
      children: [
        for (var row = 0; row < 4; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var col = 0; col < 3; col++)
                  _buildNumberButton(row, col, isConfirming),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNumberButton(int row, int col, bool isConfirming) {
    String? label;
    IconData? icon;
    VoidCallback? onTap;

    if (row < 3) {
      final number = row * 3 + col + 1;
      label = number.toString();
      onTap = () => _onNumberTap(number.toString(), isConfirming);
    } else {
      if (col == 0) {
        return const SizedBox(width: 80, height: 64);
      } else if (col == 1) {
        label = '0';
        onTap = () => _onNumberTap('0', isConfirming);
      } else {
        icon = Icons.backspace_outlined;
        onTap = () => _onBackspace(isConfirming);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppThemeEnhanced.neutral800
              : AppThemeEnhanced.neutral100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppThemeEnhanced.neutral900,
                  ),
                )
              : Icon(
                  icon,
                  size: 24,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : AppThemeEnhanced.neutral600,
                ),
        ),
      ),
    );
  }

  void _onNumberTap(String number, bool isConfirming) {
    HapticFeedback.lightImpact();
    setState(() {
      if (isConfirming) {
        if (_confirmPin.length < 4) _confirmPin += number;
        if (_confirmPin.length == 4) _validatePin();
      } else {
        if (_pin.length < 4) _pin += number;
      }
    });
  }

  void _onBackspace(bool isConfirming) {
    HapticFeedback.lightImpact();
    setState(() {
      if (isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  Future<void> _validatePin() async {
    if (_pin == _confirmPin) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.setupPin(_pin);
      if (success && mounted) {
        if (_biometricAvailable) {
          _nextPage();
        } else {
          _pageController.jumpToPage(_biometricAvailable ? 3 : 2);
        }
      }
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PINs do not match. Try again.'),
          backgroundColor: AppThemeEnhanced.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      setState(() {
        _confirmPin = '';
      });
    }
  }

  Widget _buildBiometricPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppThemeEnhanced.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fingerprint,
              size: 72,
              color: AppThemeEnhanced.success,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Enable Biometrics?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppThemeEnhanced.neutral900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Use fingerprint or face recognition\nfor faster, secure access',
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white60
                  : AppThemeEnhanced.neutral500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                await authProvider.setBiometricEnabled(true);
                _biometricEnabled = true;
                _nextPage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeEnhanced.success,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Enable Biometrics',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _nextPage,
            child: Text(
              'Skip',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white60
                    : AppThemeEnhanced.neutral500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletePage() {
    return Container(
      decoration: BoxDecoration(gradient: AppThemeEnhanced.successGradient),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 72,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'You\'re All Set!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _biometricEnabled
                ? 'Your app is secured with PIN and biometrics'
                : 'Your app is secured with a PIN',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/main');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppThemeEnhanced.success,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Start Using WizeBudge',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _skipSetup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Set a default PIN for skip (user can change later)
    await authProvider.setupPin('0000');
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }
}
