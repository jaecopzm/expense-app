# Quick Integration Guide

## 🔔 Add Notification Badge to Dashboard

In `lib/screens/enhanced_dashboard_screen.dart`, add to the AppBar:

```dart
import '../widgets/notification_badge.dart';

// In your AppBar actions:
actions: [
  NotificationBadge(onTap: _showNotifications),
  const SizedBox(width: 8),
],
```

## ⚡ Add Quick Template Button

Add a floating action button or button in dashboard:

```dart
FloatingActionButton.extended(
  onPressed: _showTemplates,
  icon: const Icon(Icons.flash_on),
  label: const Text('Quick Add'),
)
```

## 📊 Add Charts to Insights Screen

In `lib/screens/enhanced_insights_screen_new.dart`, add to your build method:

```dart
// After existing content
SpendingTrendChart(expenses: expenseProvider.expenses),
const SizedBox(height: 16),
CategoryPieChart(expenses: expenseProvider.expenses),
const SizedBox(height: 16),
ComparisonBarChart(
  thisMonth: _calculateThisMonth(expenseProvider.expenses),
  lastMonth: _calculateLastMonth(expenseProvider.expenses),
),
```

Helper methods:
```dart
double _calculateThisMonth(List expenses) {
  final now = DateTime.now();
  return expenses
      .where((e) {
        final date = DateTime.parse(e['date']);
        return date.month == now.month && date.year == now.year;
      })
      .fold(0.0, (sum, e) => sum + e['amount']);
}

double _calculateLastMonth(List expenses) {
  final lastMonth = DateTime.now().subtract(const Duration(days: 30));
  return expenses
      .where((e) {
        final date = DateTime.parse(e['date']);
        return date.month == lastMonth.month && date.year == lastMonth.year;
      })
      .fold(0.0, (sum, e) => sum + e['amount']);
}
```

## 🎯 Trigger Smart Notifications

In `lib/providers/expense_provider.dart`, after adding an expense:

```dart
Future<void> addExpense(Expense expense) async {
  // ... existing code ...
  
  // Trigger smart notifications
  final notificationService = NotificationService();
  
  // Check if unusual spending
  final average = _calculateAverageExpense();
  notificationService.checkUnusualSpending(expense.amount, average);
  
  // Check budget threshold (if you have budget tracking)
  final categoryTotal = _getCategoryTotal(expense.category);
  final categoryBudget = _getCategoryBudget(expense.category);
  if (categoryBudget > 0) {
    notificationService.checkBudgetThreshold(
      expense.category,
      categoryTotal,
      categoryBudget,
    );
  }
}
```

## 📝 Use Templates in Add Expense Screen

In `lib/screens/enhanced_add_expense_screen.dart`:

```dart
// Add a button to show templates
TextButton.icon(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TemplateSelector(
        onTemplateSelected: (template) {
          setState(() {
            _titleController.text = template.title;
            _amountController.text = template.amount.toString();
            _selectedCategory = template.category;
            if (template.notes != null) {
              _noteController.text = template.notes!;
            }
          });
        },
      ),
    );
  },
  icon: const Icon(Icons.flash_on),
  label: const Text('Use Template'),
)
```

## 🎨 Save Current Expense as Template

Add a "Save as Template" button:

```dart
TextButton.icon(
  onPressed: () async {
    final templateService = Provider.of<TemplateService>(context, listen: false);
    await templateService.addTemplate(
      ExpenseTemplate(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        notes: _noteController.text.isEmpty ? null : _noteController.text,
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Template saved!')),
    );
  },
  icon: const Icon(Icons.bookmark_add),
  label: const Text('Save as Template'),
)
```

## 🔄 Weekly Summary Scheduler

Add to your main app or a background service:

```dart
void _scheduleWeeklySummary() {
  // Run every Sunday at 8 PM
  Timer.periodic(const Duration(days: 1), (timer) {
    final now = DateTime.now();
    if (now.weekday == DateTime.sunday && now.hour == 20) {
      final notificationService = NotificationService();
      final expenses = _getThisWeekExpenses();
      final total = expenses.fold(0.0, (sum, e) => sum + e['amount']);
      notificationService.sendWeeklySummary(total, expenses.length);
    }
  });
}
```

## ✅ Testing

Run the app:
```bash
flutter run
```

Test each feature:
1. Add an expense → Check for unusual spending notification
2. Tap notification bell → See notification panel
3. Tap quick add → See templates
4. Select template → Form auto-fills
5. Go to insights → See new charts

---

That's it! Your app now has:
- ✅ Smart notifications
- ✅ Quick expense templates
- ✅ Advanced analytics charts

All with minimal, clean code! 🎉
