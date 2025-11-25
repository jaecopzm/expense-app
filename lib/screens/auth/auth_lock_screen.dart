import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme_enhanced.dart';

class AuthLockScreen extends StatefulWidget {
  const AuthLockScreen({super.key});

  @override
  State<AuthLockScreen> createState() => _AuthLockScreenState();
}

class _AuthLockScreenState extends State<AuthLockScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _isError = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _biometricAvailable = await authProvider.isBiometricAvailable();
    _biometricEnabled = await authProvider.isBiometricEnabled();
    if (mounted) {
      setState(() {});
      if (_biometricAvailable && _biometricEnabled) {
        _authenticateWithBiometric();
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.authenticateWithBiometrics();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppThemeEnhanced.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppThemeEnhanced.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your PIN to continue',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white60 : AppThemeEnhanced.neutral500,
                ),
              ),
              const SizedBox(height: 48),
              // PIN dots with shake animation
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final shake = _shakeAnimation.value * 10;
                  return Transform.translate(
                    offset: Offset(
                      shake * ((_shakeAnimation.value * 10).toInt() % 2 == 0 ? 1 : -1),
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isFilled = index < _pin.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: isFilled ? 20 : 16,
                          height: isFilled ? 20 : 16,
                          decoration: BoxDecoration(
                            color: _isError
                                ? AppThemeEnhanced.error
                                : (isFilled
                                    ? AppThemeEnhanced.primaryLight
                                    : Colors.transparent),
                            border: Border.all(
                              color: _isError
                                  ? AppThemeEnhanced.error
                                  : AppThemeEnhanced.primaryLight,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
              const Spacer(),
              // Number pad
              _buildNumberPad(),
              const SizedBox(height: 24),
              // Biometric button
              if (_biometricAvailable && _biometricEnabled)
                TextButton.icon(
                  onPressed: _authenticateWithBiometric,
                  icon: Icon(
                    Icons.fingerprint,
                    color: AppThemeEnhanced.primaryLight,
                  ),
                  label: Text(
                    'Use Biometrics',
                    style: TextStyle(
                      color: AppThemeEnhanced.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        for (var row = 0; row < 4; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var col = 0; col < 3; col++) _buildNumberButton(row, col),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNumberButton(int row, int col) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String? label;
    IconData? icon;
    VoidCallback? onTap;

    if (row < 3) {
      final number = row * 3 + col + 1;
      label = number.toString();
      onTap = () => _onNumberTap(number.toString());
    } else {
      if (col == 0) {
        return const SizedBox(width: 80, height: 64);
      } else if (col == 1) {
        label = '0';
        onTap = () => _onNumberTap('0');
      } else {
        icon = Icons.backspace_outlined;
        onTap = _onBackspace;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark
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
                    color: isDark ? Colors.white : AppThemeEnhanced.neutral900,
                  ),
                )
              : Icon(
                  icon,
                  size: 24,
                  color: isDark ? Colors.white70 : AppThemeEnhanced.neutral600,
                ),
        ),
      ),
    );
  }

  void _onNumberTap(String number) {
    if (_pin.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin += number;
      _isError = false;
    });
    if (_pin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _isError = false;
    });
  }

  Future<void> _verifyPin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.authenticateWithPin(_pin);

    if (!success && mounted) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isError = true;
      });
      _shakeController.forward().then((_) {
        _shakeController.reset();
        setState(() {
          _pin = '';
        });
      });
    }
  }
}
