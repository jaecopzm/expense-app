import 'package:flutter/material.dart';
import '../theme/app_theme_enhanced.dart';
import 'animated_widgets.dart';

// Enhanced Balance Card
class EnhancedBalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expenses;
  final String period;
  final VoidCallback? onTap;

  const EnhancedBalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
    this.period = 'This Month',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final gradient = isPositive
        ? AppThemeEnhanced.successGradient
        : AppThemeEnhanced.errorGradient;

    return BounceAnimation(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppThemeEnhanced.spaceLg,
        ),
        padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppThemeEnhanced.radius2xl),
          boxShadow: AppThemeEnhanced.shadowLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Balance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppThemeEnhanced.spaceXs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppThemeEnhanced.spaceSm,
                        vertical: AppThemeEnhanced.spaceXs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppThemeEnhanced.radiusFull,
                        ),
                      ),
                      child: Text(
                        period,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(AppThemeEnhanced.spaceSm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AppThemeEnhanced.radiusMd,
                    ),
                  ),
                  child: Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppThemeEnhanced.spaceLg),

            // Balance Amount
            AnimatedCounter(
              value: balance,
              prefix: '\$',
              textStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: AppThemeEnhanced.spaceLg),

            // Income/Expense Breakdown
            Row(
              children: [
                Expanded(
                  child: _buildBreakdownItem(
                    context,
                    'Income',
                    income,
                    Icons.arrow_upward,
                    Colors.white.withOpacity(0.9),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppThemeEnhanced.spaceMd,
                  ),
                ),
                Expanded(
                  child: _buildBreakdownItem(
                    context,
                    'Expenses',
                    expenses,
                    Icons.arrow_downward,
                    Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: AppThemeEnhanced.spaceXs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppThemeEnhanced.spaceXs),
        AnimatedCounter(
          value: amount,
          prefix: '\$',
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// Enhanced Stat Card
class EnhancedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const EnhancedStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppThemeEnhanced.spaceSm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppThemeEnhanced.radiusSm,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppThemeEnhanced.spaceMd),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppThemeEnhanced.spaceXs),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppThemeEnhanced.spaceXs),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Enhanced Category Card
class EnhancedCategoryCard extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;
  final IconData icon;
  final VoidCallback? onTap;

  const EnhancedCategoryCard({
    super.key,
    required this.category,
    required this.amount,
    required this.percentage,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppThemeEnhanced.getCategoryColor(category);

    return BounceAnimation(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppThemeEnhanced.spaceLg,
          vertical: AppThemeEnhanced.spaceXs,
        ),
        padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
          border: Border.all(color: categoryColor.withValues(alpha: 0.2)),
          boxShadow: AppThemeEnhanced.shadowSm,
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppThemeEnhanced.getCategoryGradient(category),
                borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),

            const SizedBox(width: AppThemeEnhanced.spaceMd),

            // Category Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceXs),
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceXs),
                  // Progress Bar
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        AppThemeEnhanced.radiusXs,
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (percentage / 100).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(
                            AppThemeEnhanced.radiusXs,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppThemeEnhanced.spaceMd),

            // Percentage
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppThemeEnhanced.spaceXs),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Empty State Card
class EnhancedEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EnhancedEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
