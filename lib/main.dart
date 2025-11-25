import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'providers/income_provider.dart';
import 'providers/recurring_transaction_provider.dart';
import 'providers/premium_provider.dart';
import 'providers/financial_goals_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/sync_provider.dart';
import 'services/notification_service.dart';
import 'services/template_service.dart';
import 'utils/db_helper.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme_enhanced.dart';
import 'screens/enhanced_dashboard_screen.dart';
import 'screens/enhanced_add_expense_screen.dart';
import 'screens/enhanced_add_income_screen.dart';
import 'screens/enhanced_insights_screen_new.dart';
import 'screens/enhanced_settings_screen.dart';
import 'screens/enhanced_financial_goals_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/receipt_scanner_screen.dart';
import 'screens/ai_insights_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/auth/firebase_auth_screen.dart';

import 'widgets/enhanced_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppThemeEnhanced.primaryLight,
      secondary: AppThemeEnhanced.secondaryLight,
      surface: Colors.white,
      error: AppThemeEnhanced.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppThemeEnhanced.neutral900,
    ),
    scaffoldBackgroundColor: AppThemeEnhanced.neutral50,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppThemeEnhanced.neutral900,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppThemeEnhanced.neutral900,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        color: AppThemeEnhanced.neutral900,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppThemeEnhanced.neutral900,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppThemeEnhanced.neutral900,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppThemeEnhanced.neutral900,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppThemeEnhanced.neutral700,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppThemeEnhanced.neutral600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: AppThemeEnhanced.elevationNone,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
      ),
      color: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      elevation: AppThemeEnhanced.elevationNone,
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: AppThemeEnhanced.neutral900,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppThemeEnhanced.neutral900,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeEnhanced.primaryLight,
        foregroundColor: Colors.white,
        elevation: AppThemeEnhanced.elevationNone,
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeEnhanced.spaceLg,
          vertical: AppThemeEnhanced.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppThemeEnhanced.neutral50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
        borderSide: BorderSide(color: AppThemeEnhanced.neutral200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
        borderSide: const BorderSide(
          color: AppThemeEnhanced.primaryLight,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppThemeEnhanced.spaceMd,
        vertical: AppThemeEnhanced.spaceMd,
      ),
    ),
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppThemeEnhanced.primaryDark,
      secondary: AppThemeEnhanced.secondaryDark,
      surface: AppThemeEnhanced.neutral800,
      error: AppThemeEnhanced.error,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: AppThemeEnhanced.neutral900,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: Colors.white,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppThemeEnhanced.neutral300,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppThemeEnhanced.neutral400,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: AppThemeEnhanced.elevationNone,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
      ),
      color: AppThemeEnhanced.neutral800,
    ),
    appBarTheme: AppBarTheme(
      elevation: AppThemeEnhanced.elevationNone,
      centerTitle: false,
      backgroundColor: AppThemeEnhanced.neutral900,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeEnhanced.primaryDark,
        foregroundColor: Colors.white,
        elevation: AppThemeEnhanced.elevationNone,
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeEnhanced.spaceLg,
          vertical: AppThemeEnhanced.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppThemeEnhanced.neutral800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
        borderSide: BorderSide(color: AppThemeEnhanced.neutral700, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
        borderSide: const BorderSide(
          color: AppThemeEnhanced.primaryDark,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppThemeEnhanced.spaceMd,
        vertical: AppThemeEnhanced.spaceMd,
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await DBHelper.initializeDatabase();
  runApp(const SpendWiseApp());
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
        ChangeNotifierProvider(create: (_) => RecurringTransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(create: (_) => FinancialGoalsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => TemplateService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'WizeBudge',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/main': (context) => const BottomNavWrapper(),
              '/receipt-scanner': (context) => const ReceiptScannerScreen(),
              '/ai-insights': (context) => const AIInsightsScreen(),
              '/budget': (context) => const BudgetScreen(),
              '/firebase-auth': (context) => const FirebaseAuthScreen(),
            },
          );
        },
      ),
    );
  }
}

class BottomNavWrapper extends StatefulWidget {
  const BottomNavWrapper({super.key});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;

  final List<Widget> _screens = const [
    EnhancedDashboardScreen(),
    EnhancedInsightsScreenNew(),
    EnhancedFinancialGoalsScreen(),
    EnhancedSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _showAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EnhancedAddExpenseScreen(),
    );
  }

  void _showAddIncomeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EnhancedAddIncomeScreen(),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Add Transaction',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_downward, color: Colors.red),
                ),
                title: const Text('Add Expense'),
                subtitle: const Text('Track your spending'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddExpenseSheet();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_upward, color: Colors.green),
                ),
                title: const Text('Add Income'),
                subtitle: const Text('Track your earnings'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddIncomeSheet();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
      floatingActionButton: EnhancedFAB(
        onPressed: _showAddOptions,
        icon: Icons.add,
        label: 'Add',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: EnhancedBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          _fabAnimationController.forward();
        },
        items: const [
          EnhancedNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
          ),
          EnhancedNavItem(
            icon: Icons.insights_outlined,
            selectedIcon: Icons.insights,
            label: 'Insights',
          ),
          EnhancedNavItem(
            icon: Icons.flag_outlined,
            selectedIcon: Icons.flag,
            label: 'Goals',
          ),
          EnhancedNavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
