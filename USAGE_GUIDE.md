# SpendWise AI & Database Enhancements - Quick Usage Guide

## 🚀 Getting Started

### 1. Using the Enhanced AI Insights Screen

Simply navigate to the new Enhanced AI Insights screen in your app:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EnhancedAIInsightsScreen(),
  ),
);
```

The screen includes 4 tabs:
- **Smart Alerts**: Real-time budget warnings and anomaly detection
- **Insights**: Comprehensive spending analysis
- **Budget Tips**: Personalized budget recommendations
- **Predictions**: Future spending forecasts

### 2. Using AI Service Directly

#### Get Spending Insights
```dart
import 'package:spend_wise/services/ai_service.dart';
import 'package:spend_wise/utils/db_helper.dart';

final aiService = AIService();

// Fetch expenses from database
final expenses = await DBHelper.getExpenses();

// Convert to format AI expects
final expenseData = expenses.map((e) => {
  'amount': e.amount,
  'category': e.category,
  'date': e.date.toString(),
  'title': e.title,
}).toList();

// Get AI insights
String insights = await aiService.getSpendingInsights(expenseData);
print(insights);
```

#### Get Budget Recommendations
```dart
final incomes = await DBHelper.getIncomes();
final totalIncome = incomes.fold<double>(0, (sum, i) => sum + i.amount);

String recommendations = await aiService.getBudgetRecommendations(
  totalIncome,
  expenseData,
);
print(recommendations);
```

#### Predict Future Spending
```dart
Map<String, dynamic> prediction = await aiService.predictFutureSpending(
  expenseData,
  3, // Predict for next 3 months
);

if (prediction['success']) {
  print('Prediction: ${prediction['prediction']}');
  print('Historical Average: \$${prediction['historicalAverage']}');
}
```

#### Detect Spending Anomalies
```dart
List<Map<String, dynamic>> anomalies = await aiService.detectAnomalies(expenseData);

for (var anomaly in anomalies) {
  print('Unusual: ${anomaly['title']} - \$${anomaly['amount']}');
  print('Severity: ${anomaly['severity']}'); // 'high' or 'medium'
}
```

#### Get Smart Alerts
```dart
List<String> alerts = await aiService.getSmartAlerts(
  expenseData,
  totalIncome,
  {
    'Food': 500.0,
    'Transport': 200.0,
    'Entertainment': 150.0,
  }, // Budget limits by category (optional)
);

for (var alert in alerts) {
  print(alert);
}
```

#### Get Category-Specific Recommendations
```dart
// Get all expenses in a specific category
final foodExpenses = expenses.where((e) => e.category == 'Food').toList();
final foodData = foodExpenses.map((e) => {
  'amount': e.amount,
  'category': e.category,
  'date': e.date.toString(),
  'title': e.title,
}).toList();

String categoryTips = await aiService.getCategoryRecommendations(
  'Food',
  foodData,
);
print(categoryTips);
```

### 3. Using Enhanced Database Operations

#### Batch Operations
```dart
// Batch insert expenses
List<Expense> expenses = [
  Expense(title: 'Lunch', amount: 15.0, category: 'Food', date: DateTime.now()),
  Expense(title: 'Coffee', amount: 5.0, category: 'Food', date: DateTime.now()),
  Expense(title: 'Gas', amount: 40.0, category: 'Transport', date: DateTime.now()),
];

List<int> ids = await DBHelper.insertExpensesBatch(expenses);
print('Inserted ${ids.length} expenses');

// Batch delete
await DBHelper.deleteExpensesBatch([1, 2, 3]);
```

#### Aggregate Queries
```dart
// Get total spending by category
Map<String, double> categoryTotals = await DBHelper.getExpenseTotalsByCategory();
categoryTotals.forEach((category, total) {
  print('$category: \$$total');
});

// Get monthly totals for last 6 months
Map<String, double> monthlyTotals = await DBHelper.getMonthlyExpenseTotals(6);

// Get spending statistics
Map<String, dynamic> stats = await DBHelper.getSpendingStats(
  DateTime(2024, 1, 1),
  DateTime(2024, 12, 31),
);
print('Total: \$${stats['total']}');
print('Average: \$${stats['average']}');
print('Max: \$${stats['max']}');
print('Count: ${stats['count']}');
```

#### Search and Filter
```dart
// Search expenses
List<Expense> results = await DBHelper.searchExpenses('grocery');

// Advanced filtering
List<Expense> filtered = await DBHelper.getExpensesFiltered(
  categories: ['Food', 'Dining'],
  minAmount: 10.0,
  maxAmount: 100.0,
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
  searchQuery: 'lunch',
  sortBy: 'amount',
  ascending: false,
);

// Get top expenses
List<Expense> topExpenses = await DBHelper.getTopExpenses(10);
```

#### Analytics
```dart
// Get expense count by category
Map<String, int> counts = await DBHelper.getExpenseCountByCategory();

// Get average expense by category
Map<String, double> averages = await DBHelper.getAverageExpenseByCategory();

// Get daily spending trend
Map<String, double> dailyTrend = await DBHelper.getDailySpendingTrend(30);

// Calculate net balance
double netBalance = await DBHelper.getNetBalance(
  DateTime(2024, 1, 1),
  DateTime(2024, 12, 31),
);
print('Net Balance: \$$netBalance');
```

#### Data Export/Import
```dart
// Export all data
Map<String, dynamic> exportedData = await DBHelper.exportAllData();
String jsonString = jsonEncode(exportedData);
// Save to file or share

// Import data
Map<String, dynamic> importedData = jsonDecode(jsonString);
await DBHelper.importData(importedData);
```

#### Maintenance
```dart
// Optimize database
await DBHelper.vacuumDatabase();

// Get database statistics
Map<String, dynamic> stats = await DBHelper.getDatabaseStats();
print('Total expenses: ${stats['expenseCount']}');
print('Total incomes: ${stats['incomeCount']}');
print('Total records: ${stats['totalRecords']}');
```

## 🎨 UI Integration Examples

### Show AI Insights in a Dialog
```dart
void showAIInsights(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.psychology, color: Theme.of(context).primaryColor),
          SizedBox(width: 8),
          Text('AI Insights'),
        ],
      ),
      content: FutureBuilder<String>(
        future: _getInsights(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analyzing your spending...'),
              ],
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return SingleChildScrollView(
            child: Text(snapshot.data ?? 'No insights available'),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

Future<String> _getInsights() async {
  final expenses = await DBHelper.getExpenses();
  final expenseData = expenses.map((e) => {
    'amount': e.amount,
    'category': e.category,
    'date': e.date.toString(),
    'title': e.title,
  }).toList();
  
  final aiService = AIService();
  return await aiService.getSpendingInsights(expenseData);
}
```

### Display Anomalies in a List
```dart
Widget buildAnomaliesList() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: _getAnomalies(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return CircularProgressIndicator();
      }
      
      final anomalies = snapshot.data!;
      if (anomalies.isEmpty) {
        return Text('No unusual transactions detected');
      }
      
      return ListView.builder(
        itemCount: anomalies.length,
        itemBuilder: (context, index) {
          final anomaly = anomalies[index];
          final severity = anomaly['severity'];
          final color = severity == 'high' ? Colors.red : Colors.orange;
          
          return Card(
            color: color.withOpacity(0.1),
            child: ListTile(
              leading: Icon(Icons.warning, color: color),
              title: Text(anomaly['title']),
              subtitle: Text(
                '\$${anomaly['amount']} - ${anomaly['category']}\n${anomaly['date']}',
              ),
              trailing: Chip(
                label: Text(severity.toUpperCase()),
                backgroundColor: color.withOpacity(0.3),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<List<Map<String, dynamic>>> _getAnomalies() async {
  final expenses = await DBHelper.getExpenses();
  final expenseData = expenses.map((e) => {
    'amount': e.amount,
    'category': e.category,
    'date': e.date.toString(),
    'title': e.title,
  }).toList();
  
  final aiService = AIService();
  return await aiService.detectAnomalies(expenseData);
}
```

### Show Smart Alerts Badge
```dart
Widget buildAlertsBadge() {
  return FutureBuilder<List<String>>(
    future: _getAlerts(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return SizedBox.shrink();
      
      final alertCount = snapshot.data!.length;
      if (alertCount == 0) return SizedBox.shrink();
      
      return Badge(
        label: Text('$alertCount'),
        backgroundColor: Colors.red,
        child: IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // Show alerts
          },
        ),
      );
    },
  );
}

Future<List<String>> _getAlerts() async {
  final expenses = await DBHelper.getExpenses();
  final incomes = await DBHelper.getIncomes();
  final totalIncome = incomes.fold<double>(0, (sum, i) => sum + i.amount);
  
  final expenseData = expenses.map((e) => {
    'amount': e.amount,
    'category': e.category,
    'date': e.date.toString(),
    'title': e.title,
  }).toList();
  
  final aiService = AIService();
  return await aiService.getSmartAlerts(expenseData, totalIncome, null);
}
```

## 📱 Integration with Existing Screens

### Add to Dashboard
```dart
// In dashboard_screen.dart
Card(
  child: ListTile(
    leading: Icon(Icons.psychology, color: Colors.purple),
    title: Text('AI Insights'),
    subtitle: Text('Get smart recommendations'),
    trailing: Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnhancedAIInsightsScreen(),
        ),
      );
    },
  ),
)
```

### Add to Settings
```dart
// In settings_screen.dart
ListTile(
  leading: Icon(Icons.storage),
  title: Text('Database Maintenance'),
  subtitle: Text('Optimize app performance'),
  onTap: () async {
    await DBHelper.vacuumDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Database optimized successfully!')),
    );
  },
)
```

## 🔧 Performance Tips

1. **Cache AI Results**: Store insights for a day to reduce API calls
2. **Use Batch Operations**: Always prefer batch operations for multiple records
3. **Optimize Queries**: Use the built-in aggregate methods instead of manual calculations
4. **Regular Maintenance**: Run `vacuumDatabase()` monthly
5. **Limit Data**: Only send recent transactions to AI (last 50-100)

## ⚠️ Important Notes

- **API Key**: Replace the hardcoded API key in `ai_service.dart` with environment variables
- **Premium Features**: All AI features require premium subscription
- **Error Handling**: Always wrap AI calls in try-catch blocks
- **Rate Limiting**: Implement rate limiting to avoid API quota issues
- **Data Privacy**: Inform users that their data is sent to AI service

## 📊 Monitoring

Track these metrics to ensure optimal performance:

```dart
// Example monitoring
void logAIUsage() async {
  final startTime = DateTime.now();
  
  try {
    final insights = await aiService.getSpendingInsights(data);
    final duration = DateTime.now().difference(startTime);
    
    print('AI call successful - Duration: ${duration.inSeconds}s');
  } catch (e) {
    print('AI call failed: $e');
  }
}
```

---

Happy coding! 🚀
