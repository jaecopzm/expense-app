import 'package:flutter/material.dart';

class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  double currentAmount;
  final DateTime targetDate;
  final String category;
  final IconData icon;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.category,
    required this.icon,
  });

  double get progress => currentAmount / targetAmount;

  bool get isCompleted => currentAmount >= targetAmount;

  int get daysRemaining {
    return targetDate.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'category': category,
      'icon': icon.codePoint,
    };
  }

  static FinancialGoal fromMap(Map<String, dynamic> map) {
    return FinancialGoal(
      id: map['id'],
      name: map['name'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      targetDate: DateTime.parse(map['targetDate']),
      category: map['category'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
    );
  }
}

class FinancialGoalsProvider with ChangeNotifier {
  final List<FinancialGoal> _goals = [];

  List<FinancialGoal> get goals => List.unmodifiable(_goals);

  List<FinancialGoal> get activeGoals =>
      _goals.where((goal) => !goal.isCompleted).toList();

  List<FinancialGoal> get completedGoals =>
      _goals.where((goal) => goal.isCompleted).toList();

  Future<void> addGoal(FinancialGoal goal) async {
    _goals.add(goal);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> updateGoalProgress(String goalId, double amount) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      _goals[goalIndex].currentAmount = amount;
      await _saveGoals();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    await _saveGoals();
    notifyListeners();
  }

  // This is a placeholder - implement actual persistence
  Future<void> _saveGoals() async {
    // TODO: Implement saving to database
  }

  // This is a placeholder - implement actual loading
  Future<void> loadGoals() async {
    // TODO: Implement loading from database
  }

  double getTotalProgress() {
    if (_goals.isEmpty) return 0.0;

    double totalProgress = _goals.fold(0.0, (sum, goal) => sum + goal.progress);

    return totalProgress / _goals.length;
  }

  String getOverallStatus() {
    double totalProgress = getTotalProgress();
    if (totalProgress >= 0.9) {
      return 'Excellent';
    } else if (totalProgress >= 0.7) {
      return 'Good';
    } else if (totalProgress >= 0.5) {
      return 'On Track';
    } else {
      return 'Needs Attention';
    }
  }
}
