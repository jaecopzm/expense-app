import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';
import '../models/income.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _db.collection('users').doc(_userId).collection('expenses');

  CollectionReference<Map<String, dynamic>> get _incomesRef =>
      _db.collection('users').doc(_userId).collection('incomes');

  CollectionReference<Map<String, dynamic>> get _userRef =>
      _db.collection('users');

  // User profile
  Future<void> createUserProfile(String uid, String email, String? name) async {
    await _userRef.doc(uid).set({
      'email': email,
      'displayName': name ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'lastSync': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_userId == null) return null;
    final doc = await _userRef.doc(_userId).get();
    return doc.data();
  }

  // Expenses
  Future<void> addExpense(Expense expense) async {
    if (_userId == null) return;
    await _expensesRef.doc(expense.id.toString()).set({
      'title': expense.title,
      'amount': expense.amount,
      'category': expense.category,
      'note': expense.note,
      'date': Timestamp.fromDate(expense.date),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateExpense(Expense expense) async {
    if (_userId == null) return;
    await _expensesRef.doc(expense.id.toString()).update({
      'title': expense.title,
      'amount': expense.amount,
      'category': expense.category,
      'note': expense.note,
      'date': Timestamp.fromDate(expense.date),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteExpense(int id) async {
    if (_userId == null) return;
    await _expensesRef.doc(id.toString()).delete();
  }

  Stream<List<Expense>> getExpensesStream() {
    if (_userId == null) return Stream.value([]);
    return _expensesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Expense(
                id: int.tryParse(doc.id) ?? 0,
                title: data['title'] ?? '',
                amount: (data['amount'] as num).toDouble(),
                category: data['category'] ?? 'Other',
                note: data['note'],
                date: (data['date'] as Timestamp).toDate(),
              );
            }).toList());
  }

  // Incomes
  Future<void> addIncome(Income income) async {
    if (_userId == null) return;
    await _incomesRef.doc(income.id.toString()).set({
      'title': income.title,
      'amount': income.amount,
      'category': income.category,
      'note': income.note,
      'date': Timestamp.fromDate(income.date),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateIncome(Income income) async {
    if (_userId == null) return;
    await _incomesRef.doc(income.id.toString()).update({
      'title': income.title,
      'amount': income.amount,
      'category': income.category,
      'note': income.note,
      'date': Timestamp.fromDate(income.date),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteIncome(int id) async {
    if (_userId == null) return;
    await _incomesRef.doc(id.toString()).delete();
  }

  Stream<List<Income>> getIncomesStream() {
    if (_userId == null) return Stream.value([]);
    return _incomesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Income(
                id: int.tryParse(doc.id) ?? 0,
                title: data['title'] ?? '',
                amount: (data['amount'] as num).toDouble(),
                category: data['category'] ?? 'Other',
                note: data['note'],
                date: (data['date'] as Timestamp).toDate(),
              );
            }).toList());
  }

  // Sync local data to cloud
  Future<void> syncExpenses(List<Expense> expenses) async {
    if (_userId == null) return;
    final batch = _db.batch();
    for (final expense in expenses) {
      batch.set(_expensesRef.doc(expense.id.toString()), {
        'title': expense.title,
        'amount': expense.amount,
        'category': expense.category,
        'note': expense.note,
        'date': Timestamp.fromDate(expense.date),
        'syncedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> syncIncomes(List<Income> incomes) async {
    if (_userId == null) return;
    final batch = _db.batch();
    for (final income in incomes) {
      batch.set(_incomesRef.doc(income.id.toString()), {
        'title': income.title,
        'amount': income.amount,
        'category': income.category,
        'note': income.note,
        'date': Timestamp.fromDate(income.date),
        'syncedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
