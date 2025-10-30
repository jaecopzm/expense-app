import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../theme/app_theme.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'date'; // date, amount, category

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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    
    // Filter expenses
    var filteredExpenses = provider.expenses.where((expense) {
      final matchesSearch = expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          expense.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || expense.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Sort expenses
    if (_sortBy == 'amount') {
      filteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_sortBy == 'category') {
      filteredExpenses.sort((a, b) => a.category.compareTo(b.category));
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Search
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'All Expenses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search expenses...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.sort),
                          onSelected: (value) => setState(() => _sortBy = value),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'date',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: _sortBy == 'date' ? AppTheme.primaryLight : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sort by Date',
                                    style: TextStyle(
                                      fontWeight: _sortBy == 'date' ? FontWeight.bold : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'amount',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 20,
                                    color: _sortBy == 'amount' ? AppTheme.primaryLight : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sort by Amount',
                                    style: TextStyle(
                                      fontWeight: _sortBy == 'amount' ? FontWeight.bold : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'category',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 20,
                                    color: _sortBy == 'category' ? AppTheme.primaryLight : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sort by Category',
                                    style: TextStyle(
                                      fontWeight: _sortBy == 'category' ? FontWeight.bold : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          final categoryColor = category == 'All'
                              ? AppTheme.primaryLight
                              : AppTheme.getCategoryColor(category);

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedCategory = category),
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              selectedColor: categoryColor.withOpacity(0.2),
                              checkmarkColor: categoryColor,
                              labelStyle: TextStyle(
                                color: isSelected ? categoryColor : null,
                                fontWeight: isSelected ? FontWeight.w600 : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Results Count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  '${filteredExpenses.length} expense${filteredExpenses.length != 1 ? 's' : ''} found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            // Expenses List
            filteredExpenses.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= filteredExpenses.length) return null;
                        return ExpenseCard(
                          expense: filteredExpenses[index],
                          onDelete: () => _deleteExpense(context, filteredExpenses[index].id!),
                        );
                      },
                      childCount: filteredExpenses.length,
                    ),
                  ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
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
      await Provider.of<ExpenseProvider>(context, listen: false).deleteExpense(id);
    }
  }
}
