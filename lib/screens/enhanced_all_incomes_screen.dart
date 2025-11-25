import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/income_provider.dart';
import '../widgets/income_card.dart';
import '../widgets/enhanced_inputs.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/enhanced_cards.dart';
import '../theme/app_theme_enhanced.dart';

class EnhancedAllIncomesScreen extends StatefulWidget {
  const EnhancedAllIncomesScreen({super.key});

  @override
  State<EnhancedAllIncomesScreen> createState() =>
      _EnhancedAllIncomesScreenState();
}

class _EnhancedAllIncomesScreenState extends State<EnhancedAllIncomesScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'date'; // date, amount, category
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Salary',
    'Freelance',
    'Investment',
    'Business',
    'Gift',
    'Bonus',
    'Rental',
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
      Provider.of<IncomeProvider>(context, listen: false).fetchIncomes();
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
    final provider = Provider.of<IncomeProvider>(context);

    // Filter incomes
    var filteredIncomes = provider.incomes.where((income) {
      final matchesSearch =
          income.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          income.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (income.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      final matchesCategory =
          _selectedCategory == 'All' || income.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Sort incomes
    if (_sortBy == 'amount') {
      filteredIncomes.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_sortBy == 'category') {
      filteredIncomes.sort((a, b) => a.category.compareTo(b.category));
    } else {
      filteredIncomes.sort((a, b) => b.date.compareTo(a.date));
    }

    // Group by category for category view
    final Map<String, List> groupedIncomes = {};
    for (var income in filteredIncomes) {
      if (!groupedIncomes.containsKey(income.category)) {
        groupedIncomes[income.category] = [];
      }
      groupedIncomes[income.category]!.add(income);
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
                  gradient: AppThemeEnhanced.successGradient,
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
                                'All Incomes',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                '${filteredIncomes.length} transactions',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Total Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppThemeEnhanced.spaceMd,
                            vertical: AppThemeEnhanced.spaceSm,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppThemeEnhanced.radiusFull,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: AppThemeEnhanced.spaceXs),
                              AnimatedCounter(
                                value: provider.totalIncome,
                                prefix: '\$',
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppThemeEnhanced.spaceSm),
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
                      hint: 'Search incomes...',
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
                                        ? AppThemeEnhanced.success
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
                    gradient: AppThemeEnhanced.successGradient,
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
                    key: const ValueKey('incomes_list_view'),
                    child: _buildListView(filteredIncomes),
                  ),
                  KeyedSubtree(
                    key: const ValueKey('incomes_category_view'),
                    child: _buildCategoryView(groupedIncomes),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List filteredIncomes) {
    if (filteredIncomes.isEmpty) {
      return const Center(
        child: EnhancedEmptyState(
          title: 'No incomes found',
          subtitle: 'Try adjusting your search or filters',
          icon: Icons.search_off,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<IncomeProvider>(
          context,
          listen: false,
        ).fetchIncomes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeEnhanced.spaceLg,
        ),
        itemCount: filteredIncomes.length,
        itemBuilder: (context, index) {
          return SlideInAnimation(
            delay: Duration(milliseconds: 300 + (index * 50)),
            child: IncomeCard(
              income: filteredIncomes[index],
              onDelete: () => _deleteIncome(filteredIncomes[index].id!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryView(Map<String, List> groupedIncomes) {
    if (groupedIncomes.isEmpty) {
      return const Center(
        child: EnhancedEmptyState(
          title: 'No incomes found',
          subtitle: 'Try adjusting your search or filters',
          icon: Icons.category_outlined,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<IncomeProvider>(
          context,
          listen: false,
        ).fetchIncomes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeEnhanced.spaceLg,
        ),
        itemCount: groupedIncomes.keys.length,
        itemBuilder: (context, index) {
          final category = groupedIncomes.keys.elementAt(index);
          final incomes = groupedIncomes[category]!;
          final totalAmount = incomes.fold<double>(
            0,
            (sum, income) => sum + income.amount,
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
                    gradient: AppThemeEnhanced.successGradient,
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
                              '${incomes.length} transactions',
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

                // Category Incomes
                ...incomes.map((income) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppThemeEnhanced.spaceXs,
                    ),
                    child: IncomeCard(
                      income: income,
                      onDelete: () => _deleteIncome(income.id!),
                    ),
                  );
                }),
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
                            ? AppThemeEnhanced.success.withOpacity(0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                          AppThemeEnhanced.radiusLg,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppThemeEnhanced.success
                              : Theme.of(context).dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option['icon'],
                            color: isSelected
                                ? AppThemeEnhanced.success
                                : Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: AppThemeEnhanced.spaceMd),
                          Text(
                            option['label'],
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: isSelected
                                      ? AppThemeEnhanced.success
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
                              color: AppThemeEnhanced.success,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppThemeEnhanced.spaceLg),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteIncome(int id) async {
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
            Text('Delete Income'),
          ],
        ),
        content: const Text('Are you sure you want to delete this income?'),
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
      await Provider.of<IncomeProvider>(
        context,
        listen: false,
      ).deleteIncome(id);
    }
  }

  IconData _getCategoryIcon(String category) {
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
