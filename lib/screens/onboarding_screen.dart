import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme_enhanced.dart';
import '../widgets/animated_widgets.dart';
import 'auth/auth_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.account_balance_wallet,
      title: 'Welcome to WizeBudge',
      description:
          'Your personal finance companion that helps you track expenses, manage income, and achieve your financial goals.',
      color: AppThemeEnhanced.primaryLight,
    ),
    OnboardingPage(
      icon: Icons.insights,
      title: 'Smart Insights',
      description:
          'Get AI-powered insights and analytics to understand your spending patterns and make better financial decisions.',
      color: AppThemeEnhanced.secondaryLight,
    ),
    OnboardingPage(
      icon: Icons.flag,
      title: 'Set Financial Goals',
      description:
          'Create and track your financial goals. Stay motivated as you watch your progress towards achieving them.',
      color: AppThemeEnhanced.success,
    ),
    OnboardingPage(
      icon: Icons.security,
      title: 'Secure & Private',
      description:
          'Your data is stored securely on your device. Use PIN or biometric authentication to keep your finances safe.',
      color: AppThemeEnhanced.info,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthWrapper(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppThemeEnhanced.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], index);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppThemeEnhanced.spaceLg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildIndicator(index),
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: AppThemeEnhanced.primaryButtonStyle(context).copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      _pages[_currentPage].color,
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppThemeEnhanced.space2xl),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              200, // Account for top/bottom UI elements
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            SlideInAnimation(
              delay: Duration(milliseconds: 100 * index),
              child: Container(
                padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                decoration: BoxDecoration(
                  color: page.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: 80,
                  color: page.color,
                ),
              ),
            ),

            const SizedBox(height: AppThemeEnhanced.space2xl),

            // Title
            SlideInAnimation(
              delay: Duration(milliseconds: 200 + (100 * index)),
              child: Text(
                page.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: page.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppThemeEnhanced.spaceLg),

            // Description
            SlideInAnimation(
              delay: Duration(milliseconds: 300 + (100 * index)),
              child: Text(
                page.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? _pages[_currentPage].color
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
