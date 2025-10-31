import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:math';

/// Enhanced AI Service with advanced financial analysis capabilities
class AIService {
  static const String _apiKey =
      'AIzaSyABhIdjIefJTRRGEwc-OL30LCNA3SYxmn4'; // Replace with actual API key
  late final GenerativeModel _model;
  late final GenerativeModel _proModel;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
    _proModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 50,
        topP: 0.95,
        maxOutputTokens: 4096,
      ),
    );
  }

  /// Get comprehensive spending insights with detailed analysis
  Future<String> getSpendingInsights(
    List<Map<String, dynamic>> transactions,
  ) async {
    try {
      if (transactions.isEmpty) {
        return 'No transactions available for analysis. Start tracking your expenses to get personalized insights!';
      }

      // Calculate statistics
      final stats = _calculateTransactionStats(transactions);
      
      // Format transaction data for the AI
      final transactionText = transactions.take(50).map(
            (t) =>
                "• \${t['title'] ?? 'Untitled'}: \$${t['amount']} - ${t['category']} (${t['date']})",
          )
          .join("\n");

      final prompt = """
You are a professional financial advisor AI assistant. Analyze these financial transactions and provide comprehensive insights.

TRANSACTION DATA (Last ${transactions.length} transactions):
$transactionText

STATISTICS:
- Total Spending: \$${stats['total']?.toStringAsFixed(2)}
- Average Transaction: \$${stats['average']?.toStringAsFixed(2)}
- Highest Transaction: \$${stats['max']?.toStringAsFixed(2)}
- Lowest Transaction: \$${stats['min']?.toStringAsFixed(2)}
- Most Frequent Category: ${stats['topCategory']}
- Number of Categories: ${stats['categoryCount']}

Please provide a detailed analysis including:

1. 📊 **Spending Patterns**: Identify trends, peak spending periods, and behavioral patterns
2. 💡 **Smart Insights**: Highlight unusual or noteworthy transactions
3. 💰 **Savings Opportunities**: Specific recommendations to reduce expenses
4. 📈 **Optimization Tips**: Actionable steps to improve financial health
5. ⚠️ **Risk Areas**: Categories where spending might be concerning
6. 🎯 **Recommendations**: Personalized advice based on spending habits

Format your response with clear sections using emojis and bullet points for easy reading.
""";

      final content = [Content.text(prompt)];
      final response = await _proModel.generateContent(content);

      return response.text ?? 'Unable to generate insights. Please try again later.';
    } catch (e) {
      return 'Error generating AI insights: ${e.toString()}\n\nPlease check your internet connection and try again.';
    }
  }

  /// Get personalized budget recommendations
  Future<String> getBudgetRecommendations(
    double monthlyIncome,
    List<Map<String, dynamic>> expenses,
  ) async {
    try {
      if (monthlyIncome <= 0) {
        return 'Please set your monthly income to get personalized budget recommendations.';
      }

      final categoryTotals = <String, double>{};
      double totalExpenses = 0;

      for (var expense in expenses) {
        final category = expense['category'] as String;
        final amount = expense['amount'] as double;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        totalExpenses += amount;
      }

      final expenseText = categoryTotals.entries
          .map((e) => "• ${e.key}: \$${e.value.toStringAsFixed(2)} (${((e.value / totalExpenses) * 100).toStringAsFixed(1)}%)")
          .join("\n");

      final savingsRate = ((monthlyIncome - totalExpenses) / monthlyIncome * 100).toStringAsFixed(1);

      final prompt = """
You are a certified financial planner. Create a personalized budget plan based on this financial data.

INCOME & EXPENSES:
- Monthly Income: \$${monthlyIncome.toStringAsFixed(2)}
- Total Monthly Expenses: \$${totalExpenses.toStringAsFixed(2)}
- Current Savings Rate: $savingsRate%
- Remaining Balance: \$${(monthlyIncome - totalExpenses).toStringAsFixed(2)}

EXPENSE BREAKDOWN BY CATEGORY:
$expenseText

Please provide:

1. 📊 **Budget Analysis**: Evaluate the current budget distribution
2. 💵 **50/30/20 Rule Assessment**: Compare with the 50/30/20 budgeting rule (50% needs, 30% wants, 20% savings)
3. 🎯 **Recommended Allocation**: Suggest optimal budget percentages for each category
4. 💡 **Savings Strategy**: Specific tactics to increase savings rate
5. ⚡ **Quick Wins**: Immediate changes that can make a big impact
6. 📈 **Long-term Goals**: Suggestions for building wealth over time
7. 🚨 **Red Flags**: Any concerning spending patterns to address

Use clear formatting with emojis and bullet points. Be encouraging but realistic.
""";

      final content = [Content.text(prompt)];
      final response = await _proModel.generateContent(content);

      return response.text ?? 'Unable to generate recommendations. Please try again later.';
    } catch (e) {
      return 'Error generating budget recommendations: ${e.toString()}\n\nPlease check your internet connection and try again.';
    }
  }

  /// Predict future spending based on historical data
  Future<Map<String, dynamic>> predictFutureSpending(
    List<Map<String, dynamic>> historicalExpenses,
    int monthsAhead,
  ) async {
    try {
      if (historicalExpenses.isEmpty) {
        return {
          'success': false,
          'message': 'Not enough historical data for prediction',
        };
      }

      // Calculate monthly averages
      final monthlyData = <String, List<double>>{};
      for (var expense in historicalExpenses) {
        final date = DateTime.parse(expense['date'] as String);
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        monthlyData[monthKey] = monthlyData[monthKey] ?? [];
        monthlyData[monthKey]!.add(expense['amount'] as double);
      }

      final monthlyTotals = monthlyData.map(
        (key, values) => MapEntry(key, values.reduce((a, b) => a + b)),
      );

      final dataText = monthlyTotals.entries
          .map((e) => "${e.key}: \$${e.value.toStringAsFixed(2)}")
          .join("\n");

      final prompt = """
Analyze this spending history and predict future spending trends.

HISTORICAL MONTHLY SPENDING:
$dataText

Predict spending for the next $monthsAhead month(s) and provide:
1. Predicted amount for each month
2. Confidence level (High/Medium/Low)
3. Factors that might affect the prediction
4. Recommendations to optimize future spending

Provide predictions in a structured format.
""";

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return {
        'success': true,
        'prediction': response.text,
        'historicalAverage': monthlyTotals.values.isEmpty
            ? 0
            : monthlyTotals.values.reduce((a, b) => a + b) / monthlyTotals.length,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error predicting spending: ${e.toString()}',
      };
    }
  }

  /// Detect unusual spending patterns and anomalies
  Future<List<Map<String, dynamic>>> detectAnomalies(
    List<Map<String, dynamic>> transactions,
  ) async {
    try {
      if (transactions.length < 10) {
        return [];
      }

      final amounts = transactions.map((t) => t['amount'] as double).toList();
      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance = amounts
          .map((x) => pow(x - mean, 2))
          .reduce((a, b) => a + b) / amounts.length;
      final stdDev = sqrt(variance);

      final anomalies = <Map<String, dynamic>>[];
      for (var transaction in transactions) {
        final amount = transaction['amount'] as double;
        final zScore = (amount - mean) / stdDev;
        
        // Flag transactions more than 2 standard deviations from mean
        if (zScore.abs() > 2) {
          anomalies.add({
            ...transaction,
            'zScore': zScore,
            'severity': zScore.abs() > 3 ? 'high' : 'medium',
          });
        }
      }

      return anomalies;
    } catch (e) {
      return [];
    }
  }

  /// Get smart alerts based on spending patterns
  Future<List<String>> getSmartAlerts(
    List<Map<String, dynamic>> expenses,
    double monthlyIncome,
    Map<String, double>? budgetLimits,
  ) async {
    try {
      final alerts = <String>[];
      
      // Calculate category spending
      final categorySpending = <String, double>{};
      for (var expense in expenses) {
        final category = expense['category'] as String;
        final amount = expense['amount'] as double;
        categorySpending[category] = (categorySpending[category] ?? 0) + amount;
      }

      // Check budget limits
      if (budgetLimits != null) {
        for (var entry in categorySpending.entries) {
          final limit = budgetLimits[entry.key];
          if (limit != null && entry.value > limit) {
            final percentage = ((entry.value / limit) * 100).toStringAsFixed(0);
            alerts.add('⚠️ ${entry.key}: Over budget by $percentage% (\$${(entry.value - limit).toStringAsFixed(2)})');
          } else if (limit != null && entry.value > limit * 0.8) {
            final percentage = ((entry.value / limit) * 100).toStringAsFixed(0);
            alerts.add('⚡ ${entry.key}: Used $percentage% of budget');
          }
        }
      }

      // Check overall spending vs income
      final totalSpending = categorySpending.values.fold(0.0, (a, b) => a + b);
      if (totalSpending > monthlyIncome * 0.9) {
        alerts.add('🚨 High Alert: Spending is ${((totalSpending / monthlyIncome) * 100).toStringAsFixed(0)}% of income!');
      }

      // Detect anomalies
      final anomalies = await detectAnomalies(expenses);
      if (anomalies.isNotEmpty) {
        alerts.add('🔍 ${anomalies.length} unusual transaction(s) detected');
      }

      return alerts;
    } catch (e) {
      return ['Error generating alerts: ${e.toString()}'];
    }
  }

  /// Get category-specific recommendations
  Future<String> getCategoryRecommendations(
    String category,
    List<Map<String, dynamic>> categoryExpenses,
  ) async {
    try {
      final total = categoryExpenses.fold<double>(
        0,
        (sum, e) => sum + (e['amount'] as double),
      );
      final average = total / categoryExpenses.length;
      
      final expenseList = categoryExpenses.take(20).map(
        (e) => "• ${e['title']}: \$${e['amount']} (${e['date']})",
      ).join("\n");

      final prompt = """
Provide specific recommendations for optimizing spending in the "$category" category.

CATEGORY STATISTICS:
- Total Spent: \$${total.toStringAsFixed(2)}
- Number of Transactions: ${categoryExpenses.length}
- Average Transaction: \$${average.toStringAsFixed(2)}

RECENT TRANSACTIONS:
$expenseList

Please provide:
1. 💡 **Category Analysis**: Insights specific to this spending category
2. 💰 **Cost-Saving Tips**: Practical ways to reduce expenses in this category
3. 🔄 **Alternatives**: Cheaper alternatives or substitutes
4. 📊 **Benchmarks**: How this compares to typical spending in this category
5. ✅ **Action Items**: 3-5 specific steps to optimize this category

Be specific and actionable.
""";

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Unable to generate category recommendations.';
    } catch (e) {
      return 'Error generating category recommendations: ${e.toString()}';
    }
  }

  /// Calculate transaction statistics
  Map<String, dynamic> _calculateTransactionStats(
    List<Map<String, dynamic>> transactions,
  ) {
    if (transactions.isEmpty) {
      return {
        'total': 0.0,
        'average': 0.0,
        'max': 0.0,
        'min': 0.0,
        'topCategory': 'None',
        'categoryCount': 0,
      };
    }

    final amounts = transactions.map((t) => t['amount'] as double).toList();
    final categories = <String, int>{};
    
    for (var transaction in transactions) {
      final category = transaction['category'] as String;
      categories[category] = (categories[category] ?? 0) + 1;
    }

    final topCategory = categories.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'total': amounts.reduce((a, b) => a + b),
      'average': amounts.reduce((a, b) => a + b) / amounts.length,
      'max': amounts.reduce((a, b) => a > b ? a : b),
      'min': amounts.reduce((a, b) => a < b ? a : b),
      'topCategory': topCategory,
      'categoryCount': categories.length,
    };
  }
}
