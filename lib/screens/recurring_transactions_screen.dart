import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/recurring_transaction_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../models/recurring_transaction.dart';
import 'add_recurring_transaction_screen.dart';

class RecurringTransactionsScreen extends StatelessWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecurringTransactionProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        actions: [
          if (provider.dueTransactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.dueTransactions.length} due',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: provider.recurringTransactions.isEmpty
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (provider.dueTransactions.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Due Now', Icons.notification_important, Colors.red),
                  const SizedBox(height: 12),
                  ...provider.dueTransactions.map((transaction) => 
                    _buildTransactionCard(
                      context, 
                      transaction, 
                      provider,
                      expenseProvider,
                      incomeProvider,
                      isDue: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                _buildSectionHeader(context, 'Active', Icons.check_circle, Colors.green),
                const SizedBox(height: 12),
                ...provider.activeRecurringTransactions
                    .where((t) => !t.isDueToday && !t.isOverdue)
                    .map((transaction) => 
                      _buildTransactionCard(
                        context, 
                        transaction, 
                        provider,
                        expenseProvider,
                        incomeProvider,
                      ),
                    ),

                if (provider.recurringTransactions.any((t) => !t.isActive)) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Inactive', Icons.pause_circle, Colors.grey),
                  const SizedBox(height: 12),
                  ...provider.recurringTransactions
                      .where((t) => !t.isActive)
                      .map((transaction) => 
                        _buildTransactionCard(
                          context, 
                          transaction, 
                          provider,
                          expenseProvider,
                          incomeProvider,
                        ),
                      ),
                ],
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRecurringTransactionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Recurring'),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    RecurringTransaction transaction,
    RecurringTransactionProvider provider,
    ExpenseProvider expenseProvider,
    IncomeProvider incomeProvider,
    {bool isDue = false}
  ) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${transaction.recurrenceText} • ${transaction.category}'),
            if (transaction.nextDueDate != null)
              Text(
                'Next: ${DateFormat('MMM dd, yyyy').format(transaction.nextDueDate!)}',
                style: TextStyle(
                  color: isDue ? Colors.red : Colors.grey,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                if (isDue)
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.check, size: 20),
                        SizedBox(width: 8),
                        Text('Process Now'),
                      ],
                    ),
                    onTap: () async {
                      await Future.delayed(Duration.zero);
                      await provider.processRecurringTransaction(
                        transaction,
                        expenseProvider,
                        incomeProvider,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaction processed')),
                        );
                      }
                    },
                  ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(transaction.isActive ? Icons.pause : Icons.play_arrow, size: 20),
                      const SizedBox(width: 8),
                      Text(transaction.isActive ? 'Pause' : 'Resume'),
                    ],
                  ),
                  onTap: () async {
                    await Future.delayed(Duration.zero);
                    await provider.toggleActive(transaction.id!, !transaction.isActive);
                  },
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  onTap: () async {
                    await Future.delayed(Duration.zero);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Recurring Transaction'),
                        content: const Text('Are you sure you want to delete this recurring transaction?'),
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
                    if (confirmed == true) {
                      await provider.deleteRecurringTransaction(transaction.id!);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
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
              Icons.loop,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Recurring Transactions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Set up recurring income or expenses\nto automate your tracking',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
