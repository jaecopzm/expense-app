import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../theme/app_theme_enhanced.dart';
import '../widgets/enhanced_cards.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/enhanced_navigation.dart';

class EnhancedInsightsScreenNew extends StatefulWidget {
  const EnhancedInsightsScreenNew({super.key});

  @override
  State<EnhancedInsightsScreenNew> createState() =>
      _EnhancedInsightsScreenNewState();
}

class _EnhancedInsightsScreenNewState extends State<EnhancedInsightsScreenNew>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses();
      Provider.of<IncomeProvider>(context, listen: false).fetchIncomes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, double> _getCategoryTotals(List items, String type) {
    final Map<String, double> totals = {};
    for (var item in items) {
      totals[item.category] = (totals[item.category] ?? 0) + item.amount;
    }
    return totals;
  }

  Map<String, double> _getMonthlyTrend(List items, int months) {
    final Map<String, double> trend = {};
    final now = DateTime.now();

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('MMM').format(month);
      trend[key] = 0.0;
    }

    for (var item in items) {
      final monthKey = DateFormat('MMM').format(item.date);
      if (trend.containsKey(monthKey)) {
        trend[monthKey] = (trend[monthKey] ?? 0) + item.amount;
      }
    }

    return trend;
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);

    final expenseCategoryTotals = _getCategoryTotals(
      expenseProvider.expenses,
      'expense',
    );
    final incomeCategoryTotals = _getCategoryTotals(
      incomeProvider.incomes,
      'income',
    );
    final netBalance = incomeProvider.totalIncome - expenseProvider.totalSpent;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            SlideInAnimation(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights 📊',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: AppThemeEnhanced.spaceXs),
                    Text(
                      'Analyze your financial health',
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

            // Enhanced Tab Bar
            SlideInAnimation(
              delay: const Duration(milliseconds: 200),
              child: EnhancedTabBar(
                controller: _tabController,
                tabs: const ['Overview', 'Categories', 'Trends'],
              ),
            ),

            const SizedBox(height: AppThemeEnhanced.spaceLg),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  KeyedSubtree(
                    key: const ValueKey('overview_tab'),
                    child: _buildOverviewTab(
                      expenseProvider,
                      incomeProvider,
                      netBalance,
                    ),
                  ),
                  KeyedSubtree(
                    key: const ValueKey('categories_tab'),
                    child: _buildCategoriesTab(
                      expenseCategoryTotals,
                      incomeCategoryTotals,
                    ),
                  ),
                  KeyedSubtree(
                    key: const ValueKey('trends_tab'),
                    child: _buildTrendsTab(expenseProvider, incomeProvider),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    ExpenseProvider expenseProvider,
    IncomeProvider incomeProvider,
    double netBalance,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppThemeEnhanced.spaceLg),
      child: Column(
        children: [
          // Summary Cards
          SlideInAnimation(
            delay: const Duration(milliseconds: 300),
            child: Row(
              children: [
                Expanded(
                  child: EnhancedStatCard(
                    title: 'Total Income',
                    value: '\$${incomeProvider.totalIncome.toStringAsFixed(0)}',
                    icon: Icons.trending_up,
                    color: AppThemeEnhanced.success,
                    subtitle: 'This month',
                  ),
                ),
                const SizedBox(width: AppThemeEnhanced.spaceMd),
                Expanded(
                  child: EnhancedStatCard(
                    title: 'Total Expenses',
                    value: '\$${expenseProvider.totalSpent.toStringAsFixed(0)}',
                    icon: Icons.trending_down,
                    color: AppThemeEnhanced.error,
                    subtitle: 'This month',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppThemeEnhanced.spaceLg),

          // Net Balance Card
          SlideInAnimation(
            delay: const Duration(milliseconds: 400),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
              decoration: BoxDecoration(
                gradient: netBalance >= 0
                    ? AppThemeEnhanced.successGradient
                    : AppThemeEnhanced.errorGradient,
                borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
                boxShadow: AppThemeEnhanced.shadowMd,
              ),
              child: Column(
                children: [
                  Text(
                    'Net Balance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceSm),
                  AnimatedCounter(
                    value: netBalance,
                    prefix: '\$',
                    textStyle: Theme.of(context).textTheme.headlineLarge
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceSm),
                  Text(
                    netBalance >= 0
                        ? 'You\'re doing great! 🎉'
                        : 'Time to save more 💪',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppThemeEnhanced.spaceLg),

          // Quick Stats
          SlideInAnimation(
            delay: const Duration(milliseconds: 500),
            child: Row(
              children: [
                Expanded(
                  child: EnhancedStatCard(
                    title: 'Transactions',
                    value:
                        '${expenseProvider.expenses.length + incomeProvider.incomes.length}',
                    icon: Icons.receipt_long,
                    color: AppThemeEnhanced.info,
                    subtitle: 'Total',
                  ),
                ),
                const SizedBox(width: AppThemeEnhanced.spaceMd),
                Expanded(
                  child: EnhancedStatCard(
                    title: 'Avg. Expense',
                    value: expenseProvider.expenses.isNotEmpty
                        ? '\$${(expenseProvider.totalSpent / expenseProvider.expenses.length).toStringAsFixed(0)}'
                        : '\$0',
                    icon: Icons.analytics,
                    color: AppThemeEnhanced.warning,
                    subtitle: 'Per transaction',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppThemeEnhanced.space2xl),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(
    Map<String, double> expenseTotals,
    Map<String, double> incomeTotals,
  ) {
    if (expenseTotals.isEmpty && incomeTotals.isEmpty) {
      return const EnhancedEmptyState(
        title: 'No data available',
        subtitle: 'Add some transactions to see category insights',
        icon: Icons.pie_chart_outline,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppThemeEnhanced.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expense Categories
          if (expenseTotals.isNotEmpty) ...[
            SlideInAnimation(
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Expense Categories',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: AppThemeEnhanced.spaceMd),
            ...expenseTotals.entries.map((entry) {
              final percentage =
                  (entry.value / expenseTotals.values.reduce((a, b) => a + b)) *
                  100;
              return SlideInAnimation(
                delay: Duration(
                  milliseconds:
                      400 +
                      (expenseTotals.keys.toList().indexOf(entry.key) * 100),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppThemeEnhanced.spaceSm,
                  ),
                  child: EnhancedCategoryCard(
                    category: entry.key,
                    amount: entry.value,
                    percentage: percentage,
                    icon: _getCategoryIcon(entry.key),
                    onTap: () {
                      // Navigate to category details
                    },
                  ),
                ),
              );
            }).toList(),
          ],

          // Income Categories
          if (incomeTotals.isNotEmpty) ...[
            const SizedBox(height: AppThemeEnhanced.spaceLg),
            SlideInAnimation(
              delay: const Duration(milliseconds: 600),
              child: Text(
                'Income Categories',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: AppThemeEnhanced.spaceMd),
            ...incomeTotals.entries.map((entry) {
              final percentage =
                  (entry.value / incomeTotals.values.reduce((a, b) => a + b)) *
                  100;
              return SlideInAnimation(
                delay: Duration(
                  milliseconds:
                      700 +
                      (incomeTotals.keys.toList().indexOf(entry.key) * 100),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppThemeEnhanced.spaceSm,
                  ),
                  child: EnhancedCategoryCard(
                    category: entry.key,
                    amount: entry.value,
                    percentage: percentage,
                    icon: _getIncomeCategoryIcon(entry.key),
                    onTap: () {
                      // Navigate to category details
                    },
                  ),
                ),
              );
            }).toList(),
          ],

          const SizedBox(height: AppThemeEnhanced.space2xl),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(
    ExpenseProvider expenseProvider,
    IncomeProvider incomeProvider,
  ) {
    final expenseTrend = _getMonthlyTrend(expenseProvider.expenses, 6);
    final incomeTrend = _getMonthlyTrend(incomeProvider.incomes, 6);

    if (expenseTrend.values.every((v) => v == 0) &&
        incomeTrend.values.every((v) => v == 0)) {
      return const EnhancedEmptyState(
        title: 'No trend data',
        subtitle: 'Add transactions over multiple months to see trends',
        icon: Icons.show_chart,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppThemeEnhanced.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SlideInAnimation(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Monthly Trends',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: AppThemeEnhanced.spaceLg),

          // Chart Container
          SlideInAnimation(
            delay: const Duration(milliseconds: 400),
            child: Container(
              height: 300,
              padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
                boxShadow: AppThemeEnhanced.shadowSm,
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 500,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final months = expenseTrend.keys.toList();
                          if (value.toInt() < months.length) {
                            return Text(
                              months[value.toInt()],
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Expenses Line
                    LineChartBarData(
                      spots: expenseTrend.values.toList().asMap().entries.map((
                        e,
                      ) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          AppThemeEnhanced.error,
                          AppThemeEnhanced.error.withOpacity(0.3),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppThemeEnhanced.error.withOpacity(0.3),
                            AppThemeEnhanced.error.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Income Line
                    LineChartBarData(
                      spots: incomeTrend.values.toList().asMap().entries.map((
                        e,
                      ) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          AppThemeEnhanced.success,
                          AppThemeEnhanced.success.withOpacity(0.3),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppThemeEnhanced.success.withOpacity(0.3),
                            AppThemeEnhanced.success.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppThemeEnhanced.spaceLg),

          // Legend
          SlideInAnimation(
            delay: const Duration(milliseconds: 500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Expenses', AppThemeEnhanced.error),
                const SizedBox(width: AppThemeEnhanced.spaceLg),
                _buildLegendItem('Income', AppThemeEnhanced.success),
              ],
            ),
          ),

          const SizedBox(height: AppThemeEnhanced.space2xl),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXs),
          ),
        ),
        const SizedBox(width: AppThemeEnhanced.spaceSm),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  IconData _getIncomeCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Icons.work_rounded;
      case 'freelance':
        return Icons.laptop_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'business':
        return Icons.business_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'bonus':
        return Icons.star_rounded;
      case 'rental':
        return Icons.home_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }
}
