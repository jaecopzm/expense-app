import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart';
import '../models/income.dart';

class SyncProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  bool _isOnline = true;
  DateTime? _lastSyncTime;
  String? _syncError;

  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get syncError => _syncError;
  
  bool get isSignedIn {
    try {
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }
  
  User? get currentUser {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  SyncProvider() {
    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivity.onConnectivityChanged.listen((results) {
      _isOnline = results.isNotEmpty && 
          results.any((r) => r != ConnectivityResult.none);
      notifyListeners();
    });
  }

  Future<void> syncExpenses(List<Expense> expenses) async {
    if (!isSignedIn || !_isOnline) return;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      await FirestoreService().syncExpenses(expenses);
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _syncError = 'Failed to sync expenses';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncIncomes(List<Income> incomes) async {
    if (!isSignedIn || !_isOnline) return;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      await FirestoreService().syncIncomes(incomes);
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _syncError = 'Failed to sync incomes';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> addExpenseToCloud(Expense expense) async {
    if (!isSignedIn) return;
    try {
      await FirestoreService().addExpense(expense);
    } catch (_) {}
  }

  Future<void> addIncomeToCloud(Income income) async {
    if (!isSignedIn) return;
    try {
      await FirestoreService().addIncome(income);
    } catch (_) {}
  }

  Future<void> deleteExpenseFromCloud(int id) async {
    if (!isSignedIn) return;
    try {
      await FirestoreService().deleteExpense(id);
    } catch (_) {}
  }

  Future<void> deleteIncomeFromCloud(int id) async {
    if (!isSignedIn) return;
    try {
      await FirestoreService().deleteIncome(id);
    } catch (_) {}
  }

  void clearError() {
    _syncError = null;
    notifyListeners();
  }
}
