import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../widgets/enhanced_expense_card.dart';
import '../widgets/income_card.dart';
import '../widgets/enhanced_cards.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/skeleton_loader.dart';
import '../theme/app_theme_enhanced.dart';

import 'enhanced_all_expenses_screen.dart';
import 'enhanced_all_incomes_screen.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses();
      Provider.of<IncomeProvider>(context, listen: false).fetchIncomes();
    });
  }

  void _showSearch() {
    showSearch(context: context, delegate: ExpenseSearchDelegate());
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);
    final now = DateTime.now();
    final monthName = DateFormat('MMMM').format(now);
    final netBalance = incomeProvider.totalIncome - expenseProvider.totalSpent;

    final isLoading =
        expenseProvider.expenses.isEmpty && incomeProvider.incomes.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await expenseProvider.fetchExpenses();
            await incomeProvider.fetchIncomes();
          },
          child: CustomScrollView(
            slivers: [
              // Simple App Bar with Large Logo
              SliverAppBar(
                floating: false,
                pinned: true,
                backgroundColor: AppThemeEnhanced.primaryLight,
                elevation: 2,
                toolbarHeight: 80,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: AppThemeEnhanced.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Large Logo - No Text
                          Hero(
                            tag: 'app_logo',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/wizebudge-logo.png',
                                height: 45,
                                width: 120,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Action Buttons
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 26,
                            ),
                            onPressed: _showNotifications,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 26,
                            ),
                            onPressed: _showSearch,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Enhanced Balance Card
              SliverToBoxAdapter(
                child: SlideInAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppThemeEnhanced.spaceLg,
                    ),
                    child: isLoading
                        ? const BalanceCardSkeleton()
                        : EnhancedBalanceCard(
                            balance: netBalance,
                            income: incomeProvider.totalIncome,
                            expenses: expenseProvider.totalSpent,
                            period: monthName,
                            onTap: () {
                              // Navigate to detailed balance view
                            },
                          ),
                  ),
                ),
              ),

              // Enhanced Quick Stats
              SliverToBoxAdapter(
                child: SlideInAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppThemeEnhanced.spaceLg,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: EnhancedStatCard(
                            title: 'Weekly Spent',
                            value:
                                '\$${_getWeeklyTotal(expenseProvider).toStringAsFixed(0)}',
                            icon: Icons.calendar_today,
                            color: AppThemeEnhanced.info,
                            subtitle: '+12% from last week',
                          ),
                        ),
                        const SizedBox(width: AppThemeEnhanced.spaceMd),
                        Expanded(
                          child: EnhancedStatCard(
                            title: 'Total Income',
                            value:
                                '\$${incomeProvider.totalIncome.toStringAsFixed(0)}',
                            icon: Icons.account_balance_wallet,
                            color: AppThemeEnhanced.success,
                            subtitle: 'This month',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Recent Incomes Header
              if (incomeProvider.incomes.isNotEmpty)
                SliverToBoxAdapter(
                  child: SlideInAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppThemeEnhanced.spaceLg,
                        AppThemeEnhanced.spaceLg,
                        AppThemeEnhanced.spaceLg,
                        AppThemeEnhanced.spaceMd,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Income',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EnhancedAllIncomesScreen(),
                                ),
                              );
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Recent Incomes List (show first 3)
              if (incomeProvider.incomes.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= 3 ||
                          index >= incomeProvider.incomes.length) {
                        return null;
                      }
                      return SlideInAnimation(
                        delay: Duration(milliseconds: 400 + (index * 100)),
                        child: IncomeCard(
                          income: incomeProvider.incomes[index],
                          onDelete: () => _deleteIncome(
                            context,
                            incomeProvider.incomes[index].id!,
                          ),
                        ),
                      );
                    },
                    childCount: incomeProvider.incomes.length > 3
                        ? 3
                        : incomeProvider.incomes.length,
                  ),
                ),

              // Recent Transactions Header
              SliverToBoxAdapter(
                child: SlideInAnimation(
                  delay: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppThemeEnhanced.spaceLg,
                      AppThemeEnhanced.spaceLg,
                      AppThemeEnhanced.spaceLg,
                      AppThemeEnhanced.spaceMd,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Expenses',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (expenseProvider.expenses.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EnhancedAllExpensesScreen(),
                                ),
                              );
                            },
                            child: const Text('See All'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Expenses List or Empty State
              expenseProvider.expenses.isEmpty && incomeProvider.incomes.isEmpty
                  ? SliverFillRemaining(
                      child: EnhancedEmptyState(
                        title: 'No expenses yet',
                        subtitle:
                            'Tap the + button below to add\nyour first expense',
                        icon: Icons.receipt_long_outlined,
                        buttonText: 'Add Expense',
                        onButtonPressed: () {
                          // TODO: Show add expense sheet
                        },
                      ),
                    )
                  : expenseProvider.expenses.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                        child: Center(
                          child: Text(
                            'No expenses yet',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= 5 ||
                              index >= expenseProvider.expenses.length) {
                            return null;
                          }
                          return SlideInAnimation(
                            delay: Duration(milliseconds: 600 + (index * 100)),
                            child: EnhancedExpenseCard(
                              expense: expenseProvider.expenses[index],
                              onDelete: () => _deleteExpense(
                                context,
                                expenseProvider.expenses[index].id!,
                              ),
                            ),
                          );
                        },
                        childCount: expenseProvider.expenses.length > 5
                            ? 5
                            : expenseProvider.expenses.length,
                      ),
                    ),

              // Bottom Padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  double _getWeeklyTotal(ExpenseProvider provider) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return provider.expenses
        .where((e) => e.date.isAfter(weekAgo))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> _deleteExpense(BuildContext context, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).deleteExpense(id);
    }
  }

  Future<void> _deleteIncome(BuildContext context, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Income'),
        content: const Text('Are you sure you want to delete this income?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<IncomeProvider>(
        context,
        listen: false,
      ).deleteIncome(id);
    }
  }
}

// Search Delegate for Expenses and Incomes
class ExpenseSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);

    final filteredExpenses = expenseProvider.expenses
        .where(
          (expense) =>
              expense.title.toLowerCase().contains(query.toLowerCase()) ||
              expense.category.toLowerCase().contains(query.toLowerCase()) ||
              (expense.note?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();

    final filteredIncomes = incomeProvider.incomes
        .where(
          (income) =>
              income.title.toLowerCase().contains(query.toLowerCase()) ||
              income.category.toLowerCase().contains(query.toLowerCase()) ||
              (income.note?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();

    if (filteredExpenses.isEmpty && filteredIncomes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (filteredExpenses.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Expenses (${filteredExpenses.length})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...filteredExpenses.map(
            (expense) => EnhancedExpenseCard(expense: expense, onDelete: () {}),
          ),
        ],
        if (filteredIncomes.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Incomes (${filteredIncomes.length})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...filteredIncomes.map(
            (income) => IncomeCard(income: income, onDelete: () {}),
          ),
        ],
      ],
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Search Tips',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const ListTile(
          leading: Icon(Icons.lightbulb_outline),
          title: Text('Search by description'),
          subtitle: Text('e.g., "coffee", "groceries", "salary"'),
        ),
        const ListTile(
          leading: Icon(Icons.category_outlined),
          title: Text('Search by category'),
          subtitle: Text('e.g., "food", "transport", "entertainment"'),
        ),
        const ListTile(
          leading: Icon(Icons.attach_money),
          title: Text('Search by amount'),
          subtitle: Text('e.g., "50", "100"'),
        ),
      ],
    );
  }
}

// Notification Bottom Sheet
class NotificationBottomSheet extends StatelessWidget {
  const NotificationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppThemeEnhanced.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Mark all as read
                  },
                  child: const Text('Mark all read'),
                ),
              ],
            ),
          ),

          // Notifications List
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildNotificationItem(
                  context,
                  'Budget Alert',
                  'You\'ve spent 80% of your monthly budget',
                  Icons.warning_amber,
                  AppThemeEnhanced.warning,
                  '2 hours ago',
                  true,
                ),
                _buildNotificationItem(
                  context,
                  'Income Added',
                  'Salary payment of \$3,500 has been recorded',
                  Icons.account_balance_wallet,
                  AppThemeEnhanced.success,
                  '1 day ago',
                  false,
                ),
                _buildNotificationItem(
                  context,
                  'Goal Achievement',
                  'Congratulations! You\'ve reached your savings goal',
                  Icons.celebration,
                  AppThemeEnhanced.info,
                  '3 days ago',
                  false,
                ),
                _buildNotificationItem(
                  context,
                  'Recurring Payment',
                  'Netflix subscription payment is due tomorrow',
                  Icons.subscriptions,
                  AppThemeEnhanced.primaryLight,
                  '1 week ago',
                  false,
                ),
              ],
            ),
          ),

          // Bottom padding
          const SizedBox(height: AppThemeEnhanced.spaceLg),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color color,
    String time,
    bool isUnread,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppThemeEnhanced.spaceLg,
        vertical: AppThemeEnhanced.spaceXs,
      ),
      padding: const EdgeInsets.all(AppThemeEnhanced.spaceMd),
      decoration: BoxDecoration(
        color: isUnread
            ? color.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
        border: isUnread
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppThemeEnhanced.spaceSm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppThemeEnhanced.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppThemeEnhanced.spaceXs),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppThemeEnhanced.spaceXs),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
