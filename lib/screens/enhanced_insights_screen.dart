import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';

class EnhancedInsightsScreen extends StatefulWidget {
  const EnhancedInsightsScreen({super.key});

  @override
  State<EnhancedInsightsScreen> createState() => _EnhancedInsightsScreenState();
}

class _EnhancedInsightsScreenState extends State<EnhancedInsightsScreen> with SingleTickerProviderStateMixin {
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
    
    final expenseCategoryTotals = _getCategoryTotals(expenseProvider.expenses, 'expense');
    final incomeCategoryTotals = _getCategoryTotals(incomeProvider.incomes, 'income');
    final netBalance = incomeProvider.totalIncome - expenseProvider.totalSpent;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insights 📊',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Analyze your financial health',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Expenses'),
                Tab(text: 'Income'),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(context, expenseProvider, incomeProvider, netBalance),
                  _buildExpensesTab(context, expenseProvider, expenseCategoryTotals),
                  _buildIncomeTab(context, incomeProvider, incomeCategoryTotals),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    ExpenseProvider expenseProvider,
    IncomeProvider incomeProvider,
    double netBalance,
  ) {
    if (expenseProvider.expenses.isEmpty && incomeProvider.incomes.isEmpty) {
      return _buildEmptyState(context);
    }

    final monthlyExpenses = _getMonthlyTrend(expenseProvider.expenses, 6);
    final monthlyIncome = _getMonthlyTrend(incomeProvider.incomes, 6);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Net Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  netBalance >= 0 ? Colors.green : Colors.red,
                  (netBalance >= 0 ? Colors.green : Colors.red).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (netBalance >= 0 ? Colors.green : Colors.red).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Net Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${netBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.white70, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          '\$${incomeProvider.totalIncome.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'Income',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white30,
                    ),
                    Column(
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.white70, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          '\$${expenseProvider.totalSpent.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'Expenses',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Savings Rate Card
          _buildSavingsRateCard(context, incomeProvider.totalIncome, expenseProvider.totalSpent),

          const SizedBox(height: 24),

          // Monthly Trend Chart
          Text(
            '6-Month Trend',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final months = monthlyExpenses.keys.toList();
                              if (value.toInt() < months.length) {
                                return Text(
                                  months[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: monthlyIncome.entries.toList().asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.value);
                          }).toList(),
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green.withOpacity(0.1),
                          ),
                        ),
                        LineChartBarData(
                          spots: monthlyExpenses.entries.toList().asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.value);
                          }).toList(),
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.red.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Income', Colors.green),
                    const SizedBox(width: 20),
                    _buildLegendItem('Expenses', Colors.red),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Stats
          _buildQuickStats(context, expenseProvider, incomeProvider),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(
    BuildContext context,
    ExpenseProvider provider,
    Map<String, double> categoryTotals,
  ) {
    if (provider.expenses.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expense Pie Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Expense Distribution',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: _buildPieChartSections(categoryTotals, 'expense'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Category Breakdown
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          ...(categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
            .map((entry) => _buildCategoryCard(
              context,
              entry.key,
              entry.value,
              provider.totalSpent,
              _getCategoryIcon(entry.key),
              _getExpenseCategoryColor(entry.key),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildIncomeTab(
    BuildContext context,
    IncomeProvider provider,
    Map<String, double> categoryTotals,
  ) {
    if (provider.incomes.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Income Pie Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Income Distribution',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: _buildPieChartSections(categoryTotals, 'income'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Category Breakdown
          Text(
            'Income Sources',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          ...(categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
            .map((entry) => _buildCategoryCard(
              context,
              entry.key,
              entry.value,
              provider.totalIncome,
              _getIncomeCategoryIcon(entry.key),
              Colors.green,
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildSavingsRateCard(BuildContext context, double income, double expenses) {
    final savingsRate = income > 0 ? ((income - expenses) / income * 100) : 0.0;
    final isPositive = savingsRate >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPositive ? Icons.savings : Icons.warning,
              color: isPositive ? Colors.green : Colors.red,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Savings Rate',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${savingsRate.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: (savingsRate / 100).clamp(0.0, 1.0),
              strokeWidth: 6,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(
                isPositive ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    ExpenseProvider expenseProvider,
    IncomeProvider incomeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatBox(
                context,
                'Avg Expense',
                expenseProvider.expenses.isEmpty
                    ? '\$0'
                    : '\$${(expenseProvider.totalSpent / expenseProvider.expenses.length).toStringAsFixed(0)}',
                Icons.trending_down,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatBox(
                context,
                'Avg Income',
                incomeProvider.incomes.isEmpty
                    ? '\$0'
                    : '\$${(incomeProvider.totalIncome / incomeProvider.incomes.length).toStringAsFixed(0)}',
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatBox(
                context,
                'Transactions',
                '${expenseProvider.expenses.length + incomeProvider.incomes.length}',
                Icons.receipt,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatBox(
                context,
                'Categories',
                '${_getCategoryTotals(expenseProvider.expenses, 'expense').length}',
                Icons.category,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String category,
    double amount,
    double total,
    IconData icon,
    Color color,
  ) {
    final percentage = (amount / total * 100);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}% of total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> categoryTotals, String type) {
    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);
    
    return categoryTotals.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = type == 'income' 
          ? Colors.green 
          : _getExpenseCategoryColor(entry.key);
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.insights_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No data yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add income and expenses to see insights',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
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
        return Icons.more_horiz_rounded;
    }
  }

  IconData _getIncomeCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'freelance':
        return Icons.work_rounded;
      case 'business':
        return Icons.business_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'bonus':
        return Icons.stars_rounded;
      case 'rental':
        return Icons.home_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  Color _getExpenseCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'bills':
        return Colors.red;
      case 'health':
        return Colors.teal;
      case 'education':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
