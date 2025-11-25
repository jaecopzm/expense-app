import 'package:flutter/material.dart';
import '../utils/db_helper.dart';

class ExpenseTemplate {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String? notes;
  final IconData icon;

  ExpenseTemplate({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.notes,
    this.icon = Icons.receipt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'notes': notes,
      };

  factory ExpenseTemplate.fromMap(Map<String, dynamic> map) => ExpenseTemplate(
        id: map['id'],
        title: map['title'],
        amount: map['amount'],
        category: map['category'],
        notes: map['notes'],
      );
}

class TemplateService extends ChangeNotifier {
  List<ExpenseTemplate> _templates = [];

  List<ExpenseTemplate> get templates => _templates;

  Future<void> loadTemplates() async {
    try {
      final db = await DBHelper.database;
      final maps = await db.query('expense_templates', orderBy: 'title ASC');
      _templates = maps.map((m) => ExpenseTemplate.fromMap(m)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading templates: $e');
      _templates = [];
    }
  }

  Future<void> addTemplate(ExpenseTemplate template) async {
    final db = await DBHelper.database;
    final id = await db.insert('expense_templates', template.toMap());
    _templates.add(ExpenseTemplate(
      id: id,
      title: template.title,
      amount: template.amount,
      category: template.category,
      notes: template.notes,
    ));
    notifyListeners();
  }

  Future<void> deleteTemplate(int id) async {
    final db = await DBHelper.database;
    await db.delete('expense_templates', where: 'id = ?', whereArgs: [id]);
    _templates.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Default templates
  static List<ExpenseTemplate> getDefaultTemplates() => [
        ExpenseTemplate(
          title: 'Morning Coffee',
          amount: 5.0,
          category: 'Dining',
          icon: Icons.coffee,
        ),
        ExpenseTemplate(
          title: 'Lunch',
          amount: 15.0,
          category: 'Dining',
          icon: Icons.restaurant,
        ),
        ExpenseTemplate(
          title: 'Gas',
          amount: 50.0,
          category: 'Transportation',
          icon: Icons.local_gas_station,
        ),
        ExpenseTemplate(
          title: 'Groceries',
          amount: 100.0,
          category: 'Groceries',
          icon: Icons.shopping_cart,
        ),
        ExpenseTemplate(
          title: 'Gym',
          amount: 30.0,
          category: 'Health',
          icon: Icons.fitness_center,
        ),
      ];
}
