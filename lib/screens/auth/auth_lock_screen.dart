import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme_enhanced.dart';

class AuthLockScreen extends StatefulWidget {
  const AuthLockScreen({super.key});

  @override
  State<AuthLockScreen> createState() => _AuthLockScreenState();
}

class _AuthLockScreenState extends State<AuthLockScreen> {
  String _enteredPin = '';
  bool _showBiometric = false;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAvailable = await authProvider.isBiometricAvailable();
    final isEnabled = await authProvider.isBiometricEnabled();
    
    if (mounted) {
      setState(() => _showBiometric = isAvailable && isEnabled);
      if (_showBiometric) _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.authenticateWithBiometrics();
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() => _enteredPin += number);
      if (_enteredPin.length == 4) _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  Future<void> _verifyPin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isValid = await authProvider.authenticateWithPin(_enteredPin);
    
    if (mounted) {
      if (isValid) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        setState(() {
          _isShaking = true;
          _enteredPin = '';
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _isShaking = false);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN'), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppThemeEnhanced.primaryLight,
              AppThemeEnhanced.secondaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _buildHeader(),
                    const SizedBox(height: 60),
                    _buildPinDisplay(),
                    const SizedBox(height: 60),
                    _buildKeypad(),
                    if (_showBiometric) ...[
                      const SizedBox(height: 32),
                      _buildBiometricButton(),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            'assets/images/wizebudge-logo.png',
            width: 60,
            height: 60,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.account_balance_wallet,
              size: 60,
              color: AppThemeEnhanced.primaryLight,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome Back',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your PIN',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPinDisplay() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      transform: Matrix4.translationValues(_isShaking ? 10 : 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < _enteredPin.length ? Colors.white : Colors.transparent,
              border: Border.all(color: Colors.white, width: 2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKeypad() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: 20),
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: 20),
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: 20),
          _buildKeypadRow(['', '0', '⌫']),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((num) {
        if (num.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (num == '⌫') {
                _onBackspace();
              } else {
                _onNumberPressed(num);
              }
            },
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 1.5),
              ),
              child: Center(
                child: Text(
                  num,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBiometricButton() {
    return TextButton.icon(
      onPressed: _authenticateWithBiometric,
      icon: const Icon(Icons.fingerprint, color: Colors.white, size: 32),
      label: const Text(
        'Use Biometric',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
