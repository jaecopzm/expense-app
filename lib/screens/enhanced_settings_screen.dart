import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme_enhanced.dart';

import '../widgets/animated_widgets.dart';
import '../utils/db_helper.dart';
import 'recurring_transactions_screen.dart';

class EnhancedSettingsScreen extends StatelessWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Enhanced Header
            SliverToBoxAdapter(
              child: SlideInAnimation(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings ⚙️',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppThemeEnhanced.spaceXs),
                      Text(
                        'Customize your experience',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Settings Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemeEnhanced.spaceLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Statistics Card
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                        decoration: BoxDecoration(
                          gradient: AppThemeEnhanced.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            AppThemeEnhanced.radiusXl,
                          ),
                          boxShadow: AppThemeEnhanced.shadowMd,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(
                                    AppThemeEnhanced.spaceSm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                      AppThemeEnhanced.radiusMd,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.analytics,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppThemeEnhanced.spaceMd),
                                Text(
                                  'Your Statistics',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppThemeEnhanced.spaceLg),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Expenses',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppThemeEnhanced.spaceXs,
                                      ),
                                      AnimatedCounter(
                                        value: expenseProvider.expenses.length
                                            .toDouble(),
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Incomes',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppThemeEnhanced.spaceXs,
                                      ),
                                      AnimatedCounter(
                                        value: incomeProvider.incomes.length
                                            .toDouble(),
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceLg),

                    // Preferences Section
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Preferences',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.8),
                            ),
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceMd),

                    // Dark Mode Toggle
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 400),
                      child: _buildSettingsCard(
                        context,
                        icon: themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        iconColor: AppThemeEnhanced.warning,
                        title: 'Dark Mode',
                        subtitle: themeProvider.isDarkMode
                            ? 'Dark theme enabled'
                            : 'Light theme enabled',
                        trailing: Switch.adaptive(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) => themeProvider.toggleTheme(),
                          activeColor: AppThemeEnhanced.primaryLight,
                        ),
                        onTap: () => themeProvider.toggleTheme(),
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceSm),

                    // Recurring Transactions
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 500),
                      child: _buildSettingsCard(
                        context,
                        icon: Icons.repeat,
                        iconColor: AppThemeEnhanced.info,
                        title: 'Recurring Transactions',
                        subtitle: 'Manage automatic transactions',
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RecurringTransactionsScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceLg),

                    // Security Section
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 550),
                      child: Text(
                        'Security & Privacy',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceMd),

                    // Authentication Settings (Coming Soon)
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 575),
                      child: _buildSettingsCard(
                        context,
                        icon: Icons.security,
                        iconColor: AppThemeEnhanced.success,
                        title: 'Security Settings',
                        subtitle: 'Authentication features coming soon',
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Security settings coming soon!'),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceLg),

                    // Data Management Section
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 600),
                      child: Text(
                        'Data Management',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.8),
                            ),
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceMd),

                    // Export Data
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 700),
                      child: _buildSettingsCard(
                        context,
                        icon: Icons.download,
                        iconColor: AppThemeEnhanced.success,
                        title: 'Export Data',
                        subtitle: 'Download your financial data',
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _exportData(context),
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceSm),

                    // Database Maintenance
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 800),
                      child: _buildSettingsCard(
                        context,
                        icon: Icons.storage,
                        iconColor: AppThemeEnhanced.info,
                        title: 'Database Maintenance',
                        subtitle: 'Optimize app performance',
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _optimizeDatabase(context),
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceSm),

                    // Clear All Data
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 900),
                      child: _buildSettingsCard(
                        context,
                        icon: Icons.delete_forever,
                        iconColor: AppThemeEnhanced.error,
                        title: 'Clear All Data',
                        subtitle: 'Delete all expenses and incomes',
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showClearDataDialog(context),
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceLg),

                    // About Section
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 1000),
                      child: Text(
                        'About',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.8),
                            ),
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceMd),

                    // App Version
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 1100),
                      child: _buildSettingsCard(
                        context,
                        icon: Icons.info_outline,
                        iconColor: AppThemeEnhanced.neutral500,
                        title: 'WizeBudge',
                        subtitle: 'Version 2.0.0 - Enhanced Edition',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppThemeEnhanced.spaceSm,
                            vertical: AppThemeEnhanced.spaceXs,
                          ),
                          decoration: BoxDecoration(
                            color: AppThemeEnhanced.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppThemeEnhanced.radiusXs,
                            ),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: AppThemeEnhanced.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppThemeEnhanced.space3xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return BounceAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
          boxShadow: AppThemeEnhanced.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppThemeEnhanced.spaceSm),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppThemeEnhanced.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceXs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppThemeEnhanced.spaceMd),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      await DBHelper.exportAllData();
      // TODO: Implement actual file export
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Data exported successfully!'),
              ],
            ),
            backgroundColor: AppThemeEnhanced.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppThemeEnhanced.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
            ),
          ),
        );
      }
    }
  }

  Future<void> _optimizeDatabase(BuildContext context) async {
    try {
      await DBHelper.vacuumDatabase();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Database optimized successfully!'),
              ],
            ),
            backgroundColor: AppThemeEnhanced.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Optimization failed: $e'),
            backgroundColor: AppThemeEnhanced.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your expenses and incomes. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeEnhanced.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _clearAllData(context);
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    try {
      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );
      final incomeProvider = Provider.of<IncomeProvider>(
        context,
        listen: false,
      );

      // Clear all expenses
      for (final expense in expenseProvider.expenses) {
        await expenseProvider.deleteExpense(expense.id!);
      }

      // Clear all incomes
      for (final income in incomeProvider.incomes) {
        await incomeProvider.deleteIncome(income.id!);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('All data cleared successfully!'),
              ],
            ),
            backgroundColor: AppThemeEnhanced.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: $e'),
            backgroundColor: AppThemeEnhanced.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
            ),
          ),
        );
      }
    }
  }
}

