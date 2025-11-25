import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../theme/app_theme_enhanced.dart';
import '../widgets/advanced_charts.dart';

class EnhancedInsightsScreenNew extends StatefulWidget {
  const EnhancedInsightsScreenNew({super.key});

  @override
  State<EnhancedInsightsScreenNew> createState() =>
      _EnhancedInsightsScreenNewState();
}

class _EnhancedInsightsScreenNewState extends State<EnhancedInsightsScreenNew> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses();
      Provider.of<IncomeProvider>(context, listen: false).fetchIncomes();
    });
  }

  double _calculateMonthTotal(List expenses, DateTime month) {
    return expenses
        .where((e) {
          final date = DateTime.parse(e['date']);
          return date.month == month.month && date.year == month.year;
        })
        .fold(0.0, (sum, e) => sum + e['amount']);
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);
    
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final thisMonthTotal = _calculateMonthTotal(
      expenseProvider.expenses.map((e) => {
        'date': e.date.toIso8601String(),
        'amount': e.amount,
        'category': e.category,
      }).toList(),
      now,
    );
    final lastMonthTotal = _calculateMonthTotal(
      expenseProvider.expenses.map((e) => {
        'date': e.date.toIso8601String(),
        'amount': e.amount,
        'category': e.category,
      }).toList(),
      lastMonth,
    );

    final expenseData = expenseProvider.expenses.map((e) => {
      'date': e.date.toIso8601String(),
      'amount': e.amount,
      'category': e.category,
      'title': e.title,
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights 📊',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Analyze your spending patterns',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Summary Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Income',
                        '\$${incomeProvider.totalIncome.toStringAsFixed(0)}',
                        Icons.arrow_upward,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Expenses',
                        '\$${expenseProvider.totalSpent.toStringAsFixed(0)}',
                        Icons.arrow_downward,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Net Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppThemeEnhanced.primaryLight,
                        AppThemeEnhanced.secondaryLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Net Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${(incomeProvider.totalIncome - expenseProvider.totalSpent).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Charts Section
            if (expenseData.isNotEmpty) ...[
              // Month Comparison
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ComparisonBarChart(
                    thisMonth: thisMonthTotal,
                    lastMonth: lastMonthTotal,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Category Breakdown
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CategoryPieChart(expenses: expenseData),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Spending Trend
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SpendingTrendChart(expenses: expenseData),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Top Categories
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTopCategories(expenseData),
                ),
              ),
            ] else
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insights_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data to analyze yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add some expenses to see insights',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories(List<Map<String, dynamic>> expenses) {
    final Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      final category = expense['category'];
      categoryTotals[category] = (categoryTotals[category] ?? 0) + expense['amount'];
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = sortedCategories.take(5).toList();

    if (topCategories.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Spending Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...topCategories.map((entry) {
              final percentage = (entry.value / categoryTotals.values.reduce((a, b) => a + b) * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '\$${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(
                          AppThemeEnhanced.primaryLight,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
