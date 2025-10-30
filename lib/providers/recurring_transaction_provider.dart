import 'package:flutter/material.dart';
import '../models/recurring_transaction.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../utils/db_helper.dart';
import 'expense_provider.dart';
import 'income_provider.dart';

class RecurringTransactionProvider extends ChangeNotifier {
  List<RecurringTransaction> _recurringTransactions = [];
  bool _isLoading = false;

  List<RecurringTransaction> get recurringTransactions => _recurringTransactions;
  bool get isLoading => _isLoading;

  List<RecurringTransaction> get activeRecurringTransactions =>
      _recurringTransactions.where((t) => t.isActive).toList();

  List<RecurringTransaction> get dueTransactions =>
      _recurringTransactions.where((t) => t.isActive && (t.isDueToday || t.isOverdue)).toList();

  RecurringTransactionProvider() {
    fetchRecurringTransactions();
  }

  Future<void> fetchRecurringTransactions() async {
    try {
      _isLoading = true;
      notifyListeners();
      _recurringTransactions = await DBHelper.getRecurringTransactions();
    } catch (e) {
      debugPrint('Error fetching recurring transactions: $e');
      _recurringTransactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    try {
      await DBHelper.insertRecurringTransaction(transaction);
      await fetchRecurringTransactions();
    } catch (e) {
      debugPrint('Error adding recurring transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteRecurringTransaction(int id) async {
    try {
      await DBHelper.deleteRecurringTransaction(id);
      await fetchRecurringTransactions();
    } catch (e) {
      debugPrint('Error deleting recurring transaction: $e');
      rethrow;
    }
  }

  Future<void> updateRecurringTransaction(RecurringTransaction transaction) async {
    try {
      await DBHelper.updateRecurringTransaction(transaction);
      await fetchRecurringTransactions();
    } catch (e) {
      debugPrint('Error updating recurring transaction: $e');
      rethrow;
    }
  }

  Future<void> toggleActive(int id, bool isActive) async {
    try {
      final transaction = _recurringTransactions.firstWhere((t) => t.id == id);
      await updateRecurringTransaction(transaction.copyWith(isActive: isActive));
    } catch (e) {
      debugPrint('Error toggling recurring transaction: $e');
      rethrow;
    }
  }

  Future<void> processRecurringTransaction(
    RecurringTransaction transaction,
    ExpenseProvider? expenseProvider,
    IncomeProvider? incomeProvider,
  ) async {
    try {
      if (transaction.type == TransactionType.expense) {
        final expense = Expense(
          title: transaction.title,
          amount: transaction.amount,
          category: transaction.category,
          date: DateTime.now(),
          note: transaction.note,
        );
        await expenseProvider?.addExpense(expense);
      } else {
        final income = Income(
          title: transaction.title,
          amount: transaction.amount,
          category: transaction.category,
          date: DateTime.now(),
          note: transaction.note,
        );
        await incomeProvider?.addIncome(income);
      }

      // Update last processed date
      await updateRecurringTransaction(
        transaction.copyWith(lastProcessed: DateTime.now()),
      );
    } catch (e) {
      debugPrint('Error processing recurring transaction: $e');
      rethrow;
    }
  }

  Future<void> checkAndProcessDueTransactions(
    ExpenseProvider expenseProvider,
    IncomeProvider incomeProvider,
  ) async {
    for (var transaction in dueTransactions) {
      await processRecurringTransaction(transaction, expenseProvider, incomeProvider);
    }
  }
}
