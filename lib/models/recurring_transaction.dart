enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
}

enum TransactionType {
  income,
  expense,
}

class RecurringTransaction {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final TransactionType type;
  final RecurrenceType recurrence;
  final DateTime startDate;
  final DateTime? endDate;
  final String? note;
  final bool isActive;
  final DateTime? lastProcessed;
  final DateTime? createdAt;

  RecurringTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.recurrence,
    required this.startDate,
    this.endDate,
    this.note,
    this.isActive = true,
    this.lastProcessed,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type.name,
      'recurrence': recurrence.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'note': note,
      'isActive': isActive ? 1 : 0,
      'lastProcessed': lastProcessed?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      recurrence: RecurrenceType.values.firstWhere((e) => e.name == map['recurrence']),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      note: map['note'],
      isActive: map['isActive'] == 1,
      lastProcessed: map['lastProcessed'] != null ? DateTime.parse(map['lastProcessed']) : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  RecurringTransaction copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    TransactionType? type,
    RecurrenceType? recurrence,
    DateTime? startDate,
    DateTime? endDate,
    String? note,
    bool? isActive,
    DateTime? lastProcessed,
    DateTime? createdAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      recurrence: recurrence ?? this.recurrence,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
      lastProcessed: lastProcessed ?? this.lastProcessed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get recurrenceText {
    switch (recurrence) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }

  DateTime? get nextDueDate {
    if (!isActive) return null;
    
    final base = lastProcessed ?? startDate;
    DateTime next;
    
    switch (recurrence) {
      case RecurrenceType.daily:
        next = base.add(const Duration(days: 1));
        break;
      case RecurrenceType.weekly:
        next = base.add(const Duration(days: 7));
        break;
      case RecurrenceType.monthly:
        next = DateTime(base.year, base.month + 1, base.day);
        break;
      case RecurrenceType.yearly:
        next = DateTime(base.year + 1, base.month, base.day);
        break;
    }
    
    // Check if end date has passed
    if (endDate != null && next.isAfter(endDate!)) {
      return null;
    }
    
    return next;
  }

  bool get isDueToday {
    final next = nextDueDate;
    if (next == null) return false;
    
    final now = DateTime.now();
    return next.year == now.year && 
           next.month == now.month && 
           next.day == now.day;
  }

  bool get isOverdue {
    final next = nextDueDate;
    if (next == null) return false;
    
    return next.isBefore(DateTime.now());
  }
}
