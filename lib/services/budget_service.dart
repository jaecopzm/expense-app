import 'package:sqflite/sqflite.dart';
import '../utils/db_helper.dart';

class BudgetService {
  Future<void> setBudget(String category, double amount, BudgetPeriod period) async {
    final db = await DBHelper.database;
    await db.insert(
      'budgets',
      {
        'category': category,
        'amount': amount,
        'period': period.name,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Budget>> getAllBudgets() async {
    final db = await DBHelper.database;
    final maps = await db.query('budgets');
    return maps.map((m) => Budget.fromMap(m)).toList();
  }

  Future<BudgetStatus> getBudgetStatus(String category, BudgetPeriod period) async {
    final budget = await _getBudget(category, period);
    if (budget == null) return BudgetStatus(spent: 0, limit: 0, percentage: 0);

    final spent = await _getSpentAmount(category, period);
    final percentage = (spent / budget.amount * 100);

    return BudgetStatus(
      spent: spent,
      limit: budget.amount,
      percentage: percentage,
      isOverBudget: spent > budget.amount,
      isNearLimit: percentage > 80 && percentage <= 100,
    );
  }

  Future<Budget?> _getBudget(String category, BudgetPeriod period) async {
    final db = await DBHelper.database;
    final maps = await db.query(
      'budgets',
      where: 'category = ? AND period = ?',
      whereArgs: [category, period.name],
    );
    return maps.isEmpty ? null : Budget.fromMap(maps.first);
  }

  Future<double> _getSpentAmount(String category, BudgetPeriod period) async {
    final db = await DBHelper.database;
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case BudgetPeriod.weekly:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case BudgetPeriod.monthly:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case BudgetPeriod.yearly:
        startDate = DateTime(now.year, 1, 1);
        break;
    }

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE category = ? AND date >= ?',
      [category, startDate.toIso8601String()],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> deleteBudget(String category, BudgetPeriod period) async {
    final db = await DBHelper.database;
    await db.delete(
      'budgets',
      where: 'category = ? AND period = ?',
      whereArgs: [category, period.name],
    );
  }
}

class Budget {
  final String category;
  final double amount;
  final BudgetPeriod period;
  final DateTime createdAt;

  Budget({
    required this.category,
    required this.amount,
    required this.period,
    required this.createdAt,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      category: map['category'],
      amount: map['amount'],
      period: BudgetPeriod.values.firstWhere((e) => e.name == map['period']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class BudgetStatus {
  final double spent;
  final double limit;
  final double percentage;
  final bool isOverBudget;
  final bool isNearLimit;

  BudgetStatus({
    required this.spent,
    required this.limit,
    required this.percentage,
    this.isOverBudget = false,
    this.isNearLimit = false,
  });

  double get remaining => limit - spent;
}

enum BudgetPeriod {
  weekly,
  monthly,
  yearly,
}

// Add to db_helper.dart in _onCreate method:
// await db.execute('''
//   CREATE TABLE budgets(
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     category TEXT NOT NULL,
//     amount REAL NOT NULL,
//     period TEXT NOT NULL,
//     created_at TEXT NOT NULL,
//     UNIQUE(category, period)
//   )
// ''');
