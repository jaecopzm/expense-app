import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme_enhanced.dart';
import '../../widgets/animated_widgets.dart';

class AuthLockScreen extends StatefulWidget {
  const AuthLockScreen({super.key});

  @override
  State<AuthLockScreen> createState() => _AuthLockScreenState();
}

class _AuthLockScreenState extends State<AuthLockScreen>
    with TickerProviderStateMixin {
  String _enteredPin = '';
  bool _showBiometric = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAvailable = await authProvider.isBiometricAvailable();
    final isEnabled = await authProvider.isBiometricEnabled();

    setState(() {
      _showBiometric = isAvailable && isEnabled;
    });

    // Auto-trigger biometric if available and enabled
    if (_showBiometric) {
      _authenticateWithBiometric();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppThemeEnhanced.primaryLight,
              AppThemeEnhanced.primaryLight.withOpacity(0.8),
              AppThemeEnhanced.secondaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppThemeEnhanced.spaceLg,
              vertical: AppThemeEnhanced.spaceMd,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    (AppThemeEnhanced.spaceMd * 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeader(),
                  Column(
                    children: [
                      _buildPinDisplay(),
                      const SizedBox(height: AppThemeEnhanced.space2xl),
                      _buildNumericKeypad(),
                      const SizedBox(height: AppThemeEnhanced.spaceLg),
                      if (_showBiometric)
                        _buildBiometricButton()
                      else
                        _buildForgotPinButton(),
                    ],
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceMd),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideInAnimation(
      child: Column(
        children: [
          const SizedBox(height: AppThemeEnhanced.spaceMd),
          // Logo with modern design
          Hero(
            tag: 'app_logo',
            child: Container(
              padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/wizebudge-logo.png',
                width: 70,
                height: 70,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.account_balance_wallet,
                    color: AppThemeEnhanced.primaryLight,
                    size: 70,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppThemeEnhanced.spaceLg),
          const Text(
            'Welcome Back',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppThemeEnhanced.spaceXs),
          Text(
            'Enter your PIN to unlock',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinDisplay() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: SlideInAnimation(
            delay: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppThemeEnhanced.space2xl,
                vertical: AppThemeEnhanced.spaceLg,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(
                  AppThemeEnhanced.radiusFull,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length
                          ? Colors.white
                          : Colors.transparent,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumericKeypad() {
    return SlideInAnimation(
      delay: const Duration(milliseconds: 400),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          childAspectRatio: 1.1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.symmetric(
            horizontal: AppThemeEnhanced.spaceLg,
          ),
          children: [
            ...List.generate(9, (index) {
              final number = (index + 1).toString();
              return _buildKeypadButton(number);
            }),
            _buildKeypadButton('', isEmpty: true), // Empty space
            _buildKeypadButton('0'),
            _buildKeypadButton('⌫', isBackspace: true),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(
    String text, {
    bool isBackspace = false,
    bool isEmpty = false,
  }) {
    if (isEmpty) {
      return const SizedBox(); // Empty space for layout
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeypadTap(text, isBackspace),
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusFull),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isBackspace
                ? const Icon(
                    Icons.backspace_outlined,
                    color: Colors.white,
                    size: 24,
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return SlideInAnimation(
      delay: const Duration(milliseconds: 600),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _authenticateWithBiometric,
              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusFull),
              child: Container(
                padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.25),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppThemeEnhanced.spaceSm),
          Text(
            'Use biometric',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppThemeEnhanced.spaceMd),
          // Forgot PIN button at bottom
          TextButton(
            onPressed: _showResetDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppThemeEnhanced.spaceLg,
                vertical: AppThemeEnhanced.spaceSm,
              ),
            ),
            child: Text(
              'Forgot PIN?',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onKeypadTap(String value, bool isBackspace) {
    setState(() {
      if (isBackspace) {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      } else {
        if (_enteredPin.length < 4) {
          _enteredPin += value;
          if (_enteredPin.length == 4) {
            _verifyPin();
          }
        }
      }
    });
  }

  Future<void> _verifyPin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.authenticateWithPin(_enteredPin);

    if (!mounted) return;

    if (success) {
      // Authentication successful - navigate immediately
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      // Authentication failed - show error animation
      try {
        if (mounted) {
          await _shakeController.forward();
          if (mounted) {
            _shakeController.reset();
          }
        }
      } catch (e) {
        // Ignore animation errors if widget is disposed
      }

      if (mounted) {
        setState(() {
          _enteredPin = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid PIN. Please try again.'),
            backgroundColor: AppThemeEnhanced.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.authenticateWithBiometrics();

    if (success) {
      // Authentication successful
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } else {
      // Biometric failed, user can still use PIN
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Biometric authentication failed. Use your PIN.',
            ),
            backgroundColor: AppThemeEnhanced.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildForgotPinButton() {
    return SlideInAnimation(
      delay: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(height: AppThemeEnhanced.spaceMd),
          TextButton(
            onPressed: _showResetDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppThemeEnhanced.spaceLg,
                vertical: AppThemeEnhanced.spaceSm,
              ),
            ),
            child: Text(
              'Forgot PIN?',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Reset Authentication'),
          ],
        ),
        content: const Text(
          'This will reset your security settings and you will need to set up authentication again. All your financial data will remain safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();
              if (mounted) {
                Navigator.pop(context); // Close dialog
                // The AuthWrapper will automatically show setup screen
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeEnhanced.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
