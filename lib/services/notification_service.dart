import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        type: json['type'],
        timestamp: DateTime.parse(json['timestamp']),
        isRead: json['isRead'] ?? false,
      );
}

class NotificationService extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  static const String _key = 'app_notifications';

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _notifications = decoded.map((e) => NotificationItem.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_notifications.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> addNotification(String title, String message, String type) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, notification);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = NotificationItem(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        timestamp: _notifications[index].timestamp,
        isRead: true,
      );
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((n) => NotificationItem(
              id: n.id,
              title: n.title,
              message: n.message,
              type: n.type,
              timestamp: n.timestamp,
              isRead: true,
            ))
        .toList();
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  // Smart notification generators
  void checkBudgetThreshold(String category, double spent, double budget) {
    final percentage = (spent / budget * 100).round();
    if (percentage >= 80 && percentage < 100) {
      addNotification(
        '⚡ Budget Alert',
        'You\'ve used $percentage% of your $category budget',
        'warning',
      );
    } else if (percentage >= 100) {
      addNotification(
        '🚨 Budget Exceeded',
        'You\'ve exceeded your $category budget by \$${(spent - budget).toStringAsFixed(2)}',
        'error',
      );
    }
  }

  void checkUnusualSpending(double amount, double average) {
    if (amount > average * 2) {
      addNotification(
        '🔍 Unusual Spending',
        'This expense (\$${amount.toStringAsFixed(2)}) is 2x your average',
        'info',
      );
    }
  }

  void sendWeeklySummary(double totalSpent, int transactionCount) {
    addNotification(
      '📊 Weekly Summary',
      'You spent \$$totalSpent across $transactionCount transactions this week',
      'info',
    );
  }

  void sendSavingsStreak(int days) {
    addNotification(
      '🎉 Savings Streak!',
      'You\'ve stayed under budget for $days days in a row!',
      'success',
    );
  }
}
