class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final String? receiptImage;
  final DateTime? createdAt;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.receiptImage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'receiptImage': receiptImage,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      receiptImage: map['receiptImage'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? receiptImage,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptImage: receiptImage ?? this.receiptImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
