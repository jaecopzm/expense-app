import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/income.dart';

class AIInsightsService {
  List<AIInsight> generateInsights(List<Expense> expenses, List<Income> incomes) {
    final insights = <AIInsight>[];
    final now = DateTime.now();
    final thisMonth = expenses.where((e) => 
      e.date.year == now.year && e.date.month == now.month
    ).toList();
    final lastMonth = expenses.where((e) {
      final lastMonthDate = DateTime(now.year, now.month - 1);
      return e.date.year == lastMonthDate.year && e.date.month == lastMonthDate.month;
    }).toList();

    // Spending trend analysis
    insights.add(_analyzeTrend(thisMonth, lastMonth));
    
    // Category overspending
    insights.addAll(_detectOverspending(thisMonth));
    
    // Unusual transactions
    insights.addAll(_detectAnomalies(expenses));
    
    // Savings opportunities
    insights.addAll(_findSavingsOpportunities(expenses));
    
    // Income vs expenses
    insights.add(_analyzeIncomeVsExpenses(thisMonth, incomes));
    
    // Recurring expense optimization
    insights.addAll(_optimizeRecurring(expenses));

    return insights..sort((a, b) => b.priority.compareTo(a.priority));
  }

  AIInsight _analyzeTrend(List<Expense> thisMonth, List<Expense> lastMonth) {
    final thisTotal = thisMonth.fold(0.0, (sum, e) => sum + e.amount);
    final lastTotal = lastMonth.fold(0.0, (sum, e) => sum + e.amount);
    
    if (lastTotal == 0) {
      return AIInsight(
        title: 'Welcome to WizeBudge!',
        description: 'Start tracking your expenses to get personalized insights.',
        type: InsightType.info,
        priority: 1,
        icon: Icons.lightbulb_outline,
      );
    }

    final change = ((thisTotal - lastTotal) / lastTotal * 100);
    
    if (change > 20) {
      return AIInsight(
        title: 'Spending Alert',
        description: 'Your spending is up ${change.toStringAsFixed(0)}% this month (\$${thisTotal.toStringAsFixed(2)}). Consider reviewing your budget.',
        type: InsightType.warning,
        priority: 9,
        icon: Icons.trending_up,
        actionable: true,
      );
    } else if (change < -10) {
      return AIInsight(
        title: 'Great Progress!',
        description: 'You\'ve reduced spending by ${change.abs().toStringAsFixed(0)}% this month. Keep it up!',
        type: InsightType.success,
        priority: 7,
        icon: Icons.trending_down,
      );
    }
    
    return AIInsight(
      title: 'Steady Spending',
      description: 'Your spending is consistent with last month (\$${thisTotal.toStringAsFixed(2)}).',
      type: InsightType.info,
      priority: 3,
      icon: Icons.show_chart,
    );
  }

  List<AIInsight> _detectOverspending(List<Expense> expenses) {
    final insights = <AIInsight>[];
    final categoryTotals = <String, double>{};
    
    for (var expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCategories.isNotEmpty) {
      final top = sortedCategories.first;
      final total = categoryTotals.values.fold(0.0, (a, b) => a + b);
      final percentage = (top.value / total * 100);
      
      if (percentage > 40) {
        insights.add(AIInsight(
          title: '${top.key} Dominates Budget',
          description: '${percentage.toStringAsFixed(0)}% of spending (\$${top.value.toStringAsFixed(2)}) goes to ${top.key}. Consider setting a limit.',
          type: InsightType.warning,
          priority: 8,
          icon: Icons.pie_chart,
          actionable: true,
        ));
      }
    }

    return insights;
  }

  List<AIInsight> _detectAnomalies(List<Expense> expenses) {
    final insights = <AIInsight>[];
    if (expenses.length < 10) return insights;

    final amounts = expenses.map((e) => e.amount).toList();
    final avg = amounts.reduce((a, b) => a + b) / amounts.length;
    final stdDev = _calculateStdDev(amounts, avg);

    final anomalies = expenses.where((e) => e.amount > avg + (2 * stdDev)).toList();
    
    if (anomalies.isNotEmpty) {
      final largest = anomalies.reduce((a, b) => a.amount > b.amount ? a : b);
      insights.add(AIInsight(
        title: 'Unusual Transaction Detected',
        description: '\$${largest.amount.toStringAsFixed(2)} for ${largest.category} on ${_formatDate(largest.date)} is significantly higher than usual.',
        type: InsightType.alert,
        priority: 6,
        icon: Icons.warning_amber,
      ));
    }

    return insights;
  }

  List<AIInsight> _findSavingsOpportunities(List<Expense> expenses) {
    final insights = <AIInsight>[];
    final last30Days = expenses.where((e) => 
      DateTime.now().difference(e.date).inDays <= 30
    ).toList();

    // Frequent small purchases
    final smallPurchases = last30Days.where((e) => e.amount < 10).toList();
    if (smallPurchases.length > 20) {
      final total = smallPurchases.fold(0.0, (sum, e) => sum + e.amount);
      insights.add(AIInsight(
        title: 'Small Purchases Add Up',
        description: '${smallPurchases.length} purchases under \$10 totaled \$${total.toStringAsFixed(2)} this month. Consider bulk buying.',
        type: InsightType.tip,
        priority: 5,
        icon: Icons.savings,
        actionable: true,
      ));
    }

    // Weekend spending
    final weekendExpenses = last30Days.where((e) => 
      e.date.weekday == DateTime.saturday || e.date.weekday == DateTime.sunday
    ).toList();
    if (weekendExpenses.isNotEmpty) {
      final weekendTotal = weekendExpenses.fold(0.0, (sum, e) => sum + e.amount);
      final avgWeekend = weekendTotal / (last30Days.isNotEmpty ? last30Days.length : 1);
      
      if (avgWeekend > 100) {
        insights.add(AIInsight(
          title: 'Weekend Spending Pattern',
          description: 'You spend \$${weekendTotal.toStringAsFixed(2)} on weekends. Planning ahead could reduce impulse purchases.',
          type: InsightType.tip,
          priority: 4,
          icon: Icons.weekend,
        ));
      }
    }

    return insights;
  }

  AIInsight _analyzeIncomeVsExpenses(List<Expense> expenses, List<Income> incomes) {
    final now = DateTime.now();
    final monthlyIncome = incomes.where((i) => 
      i.date.year == now.year && i.date.month == now.month
    ).fold(0.0, (sum, i) => sum + i.amount);
    
    final monthlyExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final savingsRate = monthlyIncome > 0 ? ((monthlyIncome - monthlyExpenses) / monthlyIncome * 100) : 0;

    if (savingsRate < 0) {
      return AIInsight(
        title: 'Budget Deficit',
        description: 'Expenses exceed income by \$${(monthlyExpenses - monthlyIncome).toStringAsFixed(2)}. Review your spending urgently.',
        type: InsightType.alert,
        priority: 10,
        icon: Icons.error_outline,
        actionable: true,
      );
    } else if (savingsRate < 10) {
      return AIInsight(
        title: 'Low Savings Rate',
        description: 'You\'re saving ${savingsRate.toStringAsFixed(0)}% of income. Aim for at least 20% for financial health.',
        type: InsightType.warning,
        priority: 7,
        icon: Icons.account_balance_wallet,
        actionable: true,
      );
    } else if (savingsRate > 30) {
      return AIInsight(
        title: 'Excellent Savings!',
        description: 'You\'re saving ${savingsRate.toStringAsFixed(0)}% of income (\$${(monthlyIncome - monthlyExpenses).toStringAsFixed(2)}). Outstanding!',
        type: InsightType.success,
        priority: 8,
        icon: Icons.stars,
      );
    }

    return AIInsight(
      title: 'Healthy Savings Rate',
      description: 'Saving ${savingsRate.toStringAsFixed(0)}% of income. You\'re on track!',
      type: InsightType.success,
      priority: 5,
      icon: Icons.thumb_up,
    );
  }

  List<AIInsight> _optimizeRecurring(List<Expense> expenses) {
    final insights = <AIInsight>[];
    final subscriptions = expenses.where((e) => 
      e.note?.toLowerCase().contains('subscription') == true ||
      e.note?.toLowerCase().contains('monthly') == true ||
      e.category == 'Subscriptions'
    ).toList();

    if (subscriptions.length > 5) {
      final total = subscriptions.fold(0.0, (sum, e) => sum + e.amount);
      insights.add(AIInsight(
        title: 'Subscription Overload',
        description: '${subscriptions.length} subscriptions cost \$${total.toStringAsFixed(2)}/month. Review and cancel unused ones.',
        type: InsightType.tip,
        priority: 6,
        icon: Icons.subscriptions,
        actionable: true,
      ));
    }

    return insights;
  }

  double _calculateStdDev(List<double> values, double mean) {
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    return variance > 0 ? variance : 0;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

class AIInsight {
  final String title;
  final String description;
  final InsightType type;
  final int priority;
  final IconData icon;
  final bool actionable;

  AIInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.icon,
    this.actionable = false,
  });
}

enum InsightType {
  success,
  warning,
  alert,
  tip,
  info,
}
