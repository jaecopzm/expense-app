import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/db_helper.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  double get totalSpent =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  ExpenseProvider() {
    // Initialize by fetching expenses
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    try {
      _isLoading = true;
      notifyListeners();
      _expenses = await DBHelper.getExpenses();
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
      _expenses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await DBHelper.insertExpense(expense);
      await fetchExpenses();
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await DBHelper.deleteExpense(id);
      await fetchExpenses();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await DBHelper.updateExpense(expense);
      await fetchExpenses();
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }
}
