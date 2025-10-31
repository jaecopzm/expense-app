import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/enhanced_expense_card.dart';
import '../widgets/enhanced_inputs.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/enhanced_cards.dart';
import '../theme/app_theme_enhanced.dart';

class EnhancedAllExpensesScreen extends StatefulWidget {
  const EnhancedAllExpensesScreen({super.key});

  @override
  State<EnhancedAllExpensesScreen> createState() =>
      _EnhancedAllExpensesScreenState();
}

class _EnhancedAllExpensesScreenState extends State<EnhancedAllExpensesScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'date'; // date, amount, category
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {'value': 'date', 'label': 'Date', 'icon': Icons.calendar_today},
    {'value': 'amount', 'label': 'Amount', 'icon': Icons.attach_money},
    {'value': 'category', 'label': 'Category', 'icon': Icons.category},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    // Filter expenses
    var filteredExpenses = provider.expenses.where((expense) {
      final matchesSearch =
          expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          expense.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (expense.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      final matchesCategory =
          _selectedCategory == 'All' || expense.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Sort expenses
    if (_sortBy == 'amount') {
      filteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_sortBy == 'category') {
      filteredExpenses.sort((a, b) => a.category.compareTo(b.category));
    } else {
      filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
    }

    // Group by category for category view
    final Map<String, List> groupedExpenses = {};
    for (var expense in filteredExpenses) {
      if (!groupedExpenses.containsKey(expense.category)) {
        groupedExpenses[expense.category] = [];
      }
      groupedExpenses[expense.category]!.add(expense);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            SlideInAnimation(
              delay: const Duration(milliseconds: 100),
              child: Container(
                padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                decoration: BoxDecoration(
                  gradient: AppThemeEnhanced.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppThemeEnhanced.radius2xl),
                  ),
                ),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        BounceAnimation(
                          onTap: () => Navigator.pop(context),
                          child: Container(
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
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppThemeEnhanced.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Expenses',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                '${filteredExpenses.length} transactions',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Sort Button
                        BounceAnimation(
                          onTap: _showSortOptions,
                          child: Container(
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
                              Icons.sort,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceLg),

                    // Search Bar
                    EnhancedSearchBar(
                      hint: 'Search expenses...',
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      onClear: () {
                        setState(() => _searchQuery = '');
                      },
                    ),

                    const SizedBox(height: AppThemeEnhanced.spaceMd),

                    // Category Filter
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category;

                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == _categories.length - 1
                                  ? 0
                                  : AppThemeEnhanced.spaceSm,
                            ),
                            child: BounceAnimation(
                              onTap: () {
                                setState(() => _selectedCategory = category);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppThemeEnhanced.spaceMd,
                                  vertical: AppThemeEnhanced.spaceSm,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppThemeEnhanced.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppThemeEnhanced.primaryLight
                                        : Colors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 14,
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

            // Tab Bar
            SlideInAnimation(
              delay: const Duration(milliseconds: 200),
              child: Container(
                margin: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(
                    AppThemeEnhanced.radiusLg,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppThemeEnhanced.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      AppThemeEnhanced.radiusLg,
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list, size: 18),
                          SizedBox(width: 8),
                          Text('List View'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category, size: 18),
                          SizedBox(width: 8),
                          Text('By Category'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  KeyedSubtree(
                    key: const ValueKey('expenses_list_view'),
                    child: _buildListView(filteredExpenses),
                  ),
                  KeyedSubtree(
                    key: const ValueKey('expenses_category_view'),
                    child: _buildCategoryView(groupedExpenses),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List filteredExpenses) {
    if (filteredExpenses.isEmpty) {
      return const Center(
        child: EnhancedEmptyState(
          title: 'No expenses found',
          subtitle: 'Try adjusting your search or filters',
          icon: Icons.search_off,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<ExpenseProvider>(
          context,
          listen: false,
        ).fetchExpenses();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeEnhanced.spaceLg,
        ),
        itemCount: filteredExpenses.length,
        itemBuilder: (context, index) {
          return SlideInAnimation(
            delay: Duration(milliseconds: 300 + (index * 50)),
            child: EnhancedExpenseCard(
              expense: filteredExpenses[index],
              onDelete: () => _deleteExpense(filteredExpenses[index].id!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryView(Map<String, List> groupedExpenses) {
    if (groupedExpenses.isEmpty) {
      return const Center(
        child: EnhancedEmptyState(
          title: 'No expenses found',
          subtitle: 'Try adjusting your search or filters',
          icon: Icons.category_outlined,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<ExpenseProvider>(
          context,
          listen: false,
        ).fetchExpenses();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeEnhanced.spaceLg,
        ),
        itemCount: groupedExpenses.keys.length,
        itemBuilder: (context, index) {
          final category = groupedExpenses.keys.elementAt(index);
          final expenses = groupedExpenses[category]!;
          final totalAmount = expenses.fold<double>(
            0,
            (sum, expense) => sum + expense.amount,
          );

          return SlideInAnimation(
            delay: Duration(milliseconds: 300 + (index * 100)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Header
                Container(
                  margin: const EdgeInsets.only(
                    top: AppThemeEnhanced.spaceLg,
                    bottom: AppThemeEnhanced.spaceMd,
                  ),
                  padding: const EdgeInsets.all(AppThemeEnhanced.spaceMd),
                  decoration: BoxDecoration(
                    gradient: AppThemeEnhanced.getCategoryGradient(category),
                    borderRadius: BorderRadius.circular(
                      AppThemeEnhanced.radiusLg,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: AppThemeEnhanced.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '${expenses.length} transactions',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedCounter(
                        value: totalAmount,
                        prefix: '\$',
                        textStyle: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),

                // Category Expenses
                ...expenses.map((expense) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppThemeEnhanced.spaceXs,
                    ),
                    child: EnhancedExpenseCard(
                      expense: expense,
                      onDelete: () => _deleteExpense(expense.id!),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppThemeEnhanced.radius2xl),
            ),
          ),
          padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: AppThemeEnhanced.spaceMd),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppThemeEnhanced.neutral300,
                  borderRadius: BorderRadius.circular(
                    AppThemeEnhanced.radiusXs,
                  ),
                ),
              ),
              Text(
                'Sort By',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppThemeEnhanced.spaceLg),
              ..._sortOptions.map((option) {
                final isSelected = _sortBy == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppThemeEnhanced.spaceSm,
                  ),
                  child: BounceAnimation(
                    onTap: () {
                      setState(() => _sortBy = option['value']);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppThemeEnhanced.spaceMd),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppThemeEnhanced.primaryLight.withOpacity(0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                          AppThemeEnhanced.radiusLg,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppThemeEnhanced.primaryLight
                              : Theme.of(context).dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option['icon'],
                            color: isSelected
                                ? AppThemeEnhanced.primaryLight
                                : Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: AppThemeEnhanced.spaceMd),
                          Text(
                            option['label'],
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: isSelected
                                      ? AppThemeEnhanced.primaryLight
                                      : null,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppThemeEnhanced.primaryLight,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: AppThemeEnhanced.spaceLg),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteExpense(int id) async {
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
            Text('Delete Expense'),
          ],
        ),
        content: const Text('Are you sure you want to delete this expense?'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).deleteExpense(id);
    }
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
}
