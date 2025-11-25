import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/budget_service.dart';
import '../providers/premium_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetService = BudgetService();
  final _categories = ['Food', 'Transportation', 'Shopping', 'Entertainment', 'Healthcare', 'Utilities', 'Other'];

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();
    
    if (!premium.isPremium) {
      return _buildPremiumRequired(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracking'),
      ),
      body: FutureBuilder<List<Budget>>(
        future: _budgetService.getAllBudgets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final budgets = snapshot.data ?? [];
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildOverviewCard(budgets),
              const SizedBox(height: 24),
              ..._categories.map((category) => _buildCategoryBudget(category)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBudgetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOverviewCard(List<Budget> budgets) {
    final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.amount);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Total Monthly Budget', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              '\$${totalBudget.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${budgets.length} categories tracked',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBudget(String category) {
    return FutureBuilder<BudgetStatus>(
      future: _budgetService.getBudgetStatus(category, BudgetPeriod.monthly),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.limit == 0) {
          return const SizedBox.shrink();
        }

        final status = snapshot.data!;
        final percentage = status.percentage.clamp(0, 100);
        
        Color progressColor = Colors.green;
        if (status.isOverBudget) {
          progressColor = Colors.red;
        } else if (status.isNearLimit) {
          progressColor = Colors.orange;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${status.spent.toStringAsFixed(2)} / \$${status.limit.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status.isOverBudget
                          ? 'Over by \$${(status.spent - status.limit).toStringAsFixed(2)}'
                          : '\$${status.remaining.toStringAsFixed(2)} remaining',
                      style: TextStyle(
                        color: progressColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddBudgetDialog() {
    String? selectedCategory;
    double? amount;
    BudgetPeriod period = BudgetPeriod.monthly;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => selectedCategory = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => amount = double.tryParse(value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BudgetPeriod>(
                decoration: const InputDecoration(labelText: 'Period'),
                initialValue: period,
                items: BudgetPeriod.values.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                )).toList(),
                onChanged: (value) => setState(() => period = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (selectedCategory != null && amount != null && amount! > 0) {
                  await _budgetService.setBudget(selectedCategory!, amount!, period);
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {});
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumRequired(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracking')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              const Text(
                'Premium Feature',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Set budgets for each category and get real-time alerts when you\'re approaching your limits.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/subscription'),
                child: const Text('Upgrade to Premium'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
