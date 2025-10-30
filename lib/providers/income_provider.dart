import 'package:flutter/material.dart';
import '../models/income.dart';
import '../utils/db_helper.dart';

class IncomeProvider extends ChangeNotifier {
  List<Income> _incomes = [];
  bool _isLoading = false;

  List<Income> get incomes => _incomes;
  bool get isLoading => _isLoading;

  double get totalIncome =>
      _incomes.fold(0.0, (sum, item) => sum + item.amount);

  IncomeProvider() {
    // Initialize by fetching incomes
    fetchIncomes();
  }

  Future<void> fetchIncomes() async {
    try {
      _isLoading = true;
      notifyListeners();
      _incomes = await DBHelper.getIncomes();
    } catch (e) {
      debugPrint('Error fetching incomes: $e');
      _incomes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addIncome(Income income) async {
    try {
      await DBHelper.insertIncome(income);
      await fetchIncomes();
    } catch (e) {
      debugPrint('Error adding income: $e');
      rethrow;
    }
  }

  Future<void> deleteIncome(int id) async {
    try {
      await DBHelper.deleteIncome(id);
      await fetchIncomes();
    } catch (e) {
      debugPrint('Error deleting income: $e');
      rethrow;
    }
  }

  Future<void> updateIncome(Income income) async {
    try {
      await DBHelper.updateIncome(income);
      await fetchIncomes();
    } catch (e) {
      debugPrint('Error updating income: $e');
      rethrow;
    }
  }
}
