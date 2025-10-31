import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme_enhanced.dart';
import '../../widgets/animated_widgets.dart';

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _buildWelcomePage(),
            _buildPinSetupPage(),
            _buildBiometricSetupPage(),
            _buildCompletePage(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Container(
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                (AppThemeEnhanced.spaceLg * 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideInAnimation(
                child: Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(AppThemeEnhanced.space2xl),
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
                    child: Icon(
                      Icons.security,
                      size: 80,
                      color: AppThemeEnhanced.primaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppThemeEnhanced.space3xl),
              SlideInAnimation(
                delay: const Duration(milliseconds: 200),
                child: const Text(
                  'Secure Your\nFinancial Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppThemeEnhanced.spaceLg),
              SlideInAnimation(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Set up authentication to keep your\nfinancial information safe and secure.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppThemeEnhanced.space3xl),
              SlideInAnimation(
                delay: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppThemeEnhanced.spaceLg),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _nextPage(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppThemeEnhanced.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusFull),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinSetupPage() {
    return Container(
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeEnhanced.spaceLg,
          vertical: AppThemeEnhanced.spaceMd,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                (AppThemeEnhanced.spaceMd * 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: AppThemeEnhanced.space2xl),
                  SlideInAnimation(
                    child: Text(
                      _pin.isEmpty ? 'Create Your PIN' : 'Confirm Your PIN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceMd),
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      _pin.isEmpty
                          ? 'Choose a 4-digit PIN to secure your app'
                          : 'Enter your PIN again to confirm',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: _buildPinDisplay(_pin.isEmpty ? _pin : _confirmPin),
                  ),
                  const SizedBox(height: AppThemeEnhanced.space2xl),
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 600),
                    child: _buildNumericKeypad(),
                  ),
                ],
              ),
              const SizedBox(height: AppThemeEnhanced.spaceMd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricSetupPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemeEnhanced.info,
            AppThemeEnhanced.info.withOpacity(0.8),
            AppThemeEnhanced.primaryLight,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                (AppThemeEnhanced.spaceLg * 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideInAnimation(
                child: Container(
                  padding: const EdgeInsets.all(AppThemeEnhanced.space2xl),
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
                  child: Icon(
                    Icons.fingerprint,
                    size: 80,
                    color: AppThemeEnhanced.info,
                  ),
                ),
              ),
              const SizedBox(height: AppThemeEnhanced.space3xl),
              SlideInAnimation(
                delay: const Duration(milliseconds: 200),
                child: const Text(
                  'Biometric\nAuthentication',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppThemeEnhanced.spaceLg),
              SlideInAnimation(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Use your fingerprint or face recognition\nfor quick and secure access.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppThemeEnhanced.space3xl),
              SlideInAnimation(
                delay: const Duration(milliseconds: 600),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return FutureBuilder<bool>(
                      future: authProvider.isBiometricAvailable(),
                      builder: (context, snapshot) {
                        final isAvailable = snapshot.data ?? false;

                        if (!isAvailable) {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'Biometric authentication is not available on this device.',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: AppThemeEnhanced.spaceLg),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppThemeEnhanced.spaceLg),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () => _nextPage(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppThemeEnhanced.info,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusFull),
                                      ),
                                      elevation: 8,
                                      shadowColor: Colors.black.withOpacity(0.3),
                                    ),
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppThemeEnhanced.spaceMd),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: SwitchListTile(
                                title: Text(
                                  'Enable Biometric Authentication',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Use fingerprint or face recognition',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                value: _biometricEnabled,
                                onChanged: (value) {
                                  setState(() => _biometricEnabled = value);
                                },
                                activeColor: Colors.white,
                                activeTrackColor: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: AppThemeEnhanced.spaceLg),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppThemeEnhanced.spaceLg),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () => _nextPage(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppThemeEnhanced.info,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusFull),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.black.withOpacity(0.3),
                                  ),
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletePage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemeEnhanced.success,
            AppThemeEnhanced.success.withOpacity(0.8),
            AppThemeEnhanced.primaryLight,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                (AppThemeEnhanced.spaceLg * 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideInAnimation(
                child: Container(
                  padding: const EdgeInsets.all(AppThemeEnhanced.space2xl),
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
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppThemeEnhanced.success,
                  ),
                ),
              ),
              const SizedBox(height: AppThemeEnhanced.space3xl),
              SlideInAnimation(
                delay: const Duration(milliseconds: 200),
                child: const Text(
                  'Setup Complete!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppThemeEnhanced.spaceLg),
              SlideInAnimation(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Your financial data is now secure.\nYou can change these settings anytime in the app.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppThemeEnhanced.space3xl),
              SlideInAnimation(
                delay: const Duration(milliseconds: 600),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppThemeEnhanced.spaceLg),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _completeSetup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppThemeEnhanced.success,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusFull),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: authProvider.isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: AppThemeEnhanced.success,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Start Using WizeBudge',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDisplay(String pin) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppThemeEnhanced.space2xl,
        vertical: AppThemeEnhanced.spaceLg,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusFull),
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
              color: index < pin.length
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
    );
  }

  Widget _buildNumericKeypad() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.symmetric(horizontal: AppThemeEnhanced.spaceLg),
        children: [
          ...List.generate(9, (index) {
            final number = (index + 1).toString();
            return _buildKeypadButton(number);
          }),
          const SizedBox(), // Empty space
          _buildKeypadButton('0'),
          _buildKeypadButton('⌫', isBackspace: true),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String text, {bool isBackspace = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: text.isEmpty ? null : () => _onKeypadTap(text, isBackspace),
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

  void _onKeypadTap(String value, bool isBackspace) {
    setState(() {
      if (isBackspace) {
        if (_pin.isEmpty) {
          if (_confirmPin.isNotEmpty) {
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          }
        } else {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else {
        if (_pin.length < 4) {
          _pin += value;
          if (_pin.length == 4) {
            // PIN entered, now ask for confirmation
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {});
            });
          }
        } else if (_confirmPin.length < 4) {
          _confirmPin += value;
          if (_confirmPin.length == 4) {
            _validatePin();
          }
        }
      }
    });
  }

  void _validatePin() {
    if (_pin == _confirmPin) {
      // PINs match, proceed to next page
      Future.delayed(const Duration(milliseconds: 500), () {
        _nextPage();
      });
    } else {
      // PINs don't match, reset
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _pin = '';
        _confirmPin = '';
      });
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSetup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Set up PIN
    final success = await authProvider.setupPin(_pin);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to set up authentication. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Set biometric preference
    await authProvider.setBiometricEnabled(_biometricEnabled);

    // Setup complete, navigate to main app
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }
}
