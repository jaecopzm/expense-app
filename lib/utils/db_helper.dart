import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/recurring_transaction.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Diagnostic and migration helper: logs current schema and applies safe migrations
  static Future<void> _runDiagnosticsAndMigrations(Database db) async {
    try {
      debugPrint('Running DB diagnostics...');

      // List existing tables
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final tableNames = tables.map((t) => t['name'].toString()).toList();
      debugPrint('Existing tables: $tableNames');

      // Check user_version PRAGMA (schema version)
      final userVersionRes = await db.rawQuery('PRAGMA user_version');
      int currentVersion = 0;
      if (userVersionRes.isNotEmpty) {
        final first = userVersionRes.first.values.first;
        if (first is int)
          currentVersion = first;
        else if (first is String)
          currentVersion = int.tryParse(first) ?? 0;
      }
      debugPrint('Current DB user_version: $currentVersion');

      // Helper to check if a column exists in a table
      Future<bool> columnExists(String table, String column) async {
        final info = await db.rawQuery("PRAGMA table_info('$table')");
        return info.any((col) => col['name']?.toString() == column);
      }

      // Migrate to v2: ensure expenses has note and createdAt
      if (currentVersion < 2) {
        debugPrint('Applying migration to v2');
        final hasNote = await columnExists('expenses', 'note');
        final hasCreatedAt = await columnExists('expenses', 'createdAt');
        if (!hasNote) {
          try {
            await db.execute("ALTER TABLE expenses ADD COLUMN note TEXT");
          } catch (e) {
            debugPrint('Could not add column note: $e');
          }
        }
        if (!hasCreatedAt) {
          try {
            await db.execute("ALTER TABLE expenses ADD COLUMN createdAt TEXT");
          } catch (e) {
            debugPrint('Could not add column createdAt: $e');
          }
        }
        currentVersion = 2;
        await db.execute('PRAGMA user_version = $currentVersion');
      }

      // Migrate to v3: ensure incomes table exists
      if (currentVersion < 3) {
        debugPrint('Applying migration to v3');
        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS incomes(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              date TEXT NOT NULL,
              note TEXT,
              createdAt TEXT
            )
          ''');
        } catch (e) {
          debugPrint('Could not create incomes table: $e');
        }
        currentVersion = 3;
        await db.execute('PRAGMA user_version = $currentVersion');
      }

      // Migrate to v4: ensure recurring_transactions table exists
      if (currentVersion < 4) {
        debugPrint('Applying migration to v4');
        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS recurring_transactions(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              type TEXT NOT NULL,
              recurrence TEXT NOT NULL,
              startDate TEXT NOT NULL,
              endDate TEXT,
              note TEXT,
              isActive INTEGER DEFAULT 1,
              lastProcessed TEXT,
              createdAt TEXT
            )
          ''');
        } catch (e) {
          debugPrint('Could not create recurring_transactions table: $e');
        }
        currentVersion = 4;
        await db.execute('PRAGMA user_version = $currentVersion');
      }

      debugPrint(
        'DB diagnostics/migrations complete. user_version=$currentVersion',
      );
    } catch (e) {
      debugPrint('Diagnostics/migrations failed: $e');
      rethrow;
    }
  }

  static Future<void> initializeDatabase() async {
    // Initialize FFI for desktop platforms
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }
  }

  static Future<Database> _initDB() async {
    try {
      await initializeDatabase(); // Initialize database factory
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'expenses.db');

      debugPrint('Initializing database at: $path');

      return await openDatabase(
        path,
        version: 4,
        onCreate: (db, version) async {
          debugPrint('Creating database tables...');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS expenses(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              date TEXT NOT NULL,
              note TEXT,
              createdAt TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS incomes(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              date TEXT NOT NULL,
              note TEXT,
              createdAt TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS recurring_transactions(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              type TEXT NOT NULL,
              recurrence TEXT NOT NULL,
              startDate TEXT NOT NULL,
              endDate TEXT,
              note TEXT,
              isActive INTEGER DEFAULT 1,
              lastProcessed TEXT,
              createdAt TEXT
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          debugPrint('Upgrading database from v$oldVersion to v$newVersion');
          if (oldVersion < 2) {
            // Add new columns for version 2
            await db.execute('ALTER TABLE expenses ADD COLUMN note TEXT');
            await db.execute('ALTER TABLE expenses ADD COLUMN createdAt TEXT');
          }
          if (oldVersion < 3) {
            // Add incomes table for version 3
            await db.execute('''
              CREATE TABLE IF NOT EXISTS incomes(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                amount REAL NOT NULL,
                category TEXT NOT NULL,
                date TEXT NOT NULL,
                note TEXT,
                createdAt TEXT
              )
            ''');
          }
          if (oldVersion < 4) {
            // Add recurring_transactions table for version 4
            await db.execute('''
              CREATE TABLE IF NOT EXISTS recurring_transactions(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                amount REAL NOT NULL,
                category TEXT NOT NULL,
                type TEXT NOT NULL,
                recurrence TEXT NOT NULL,
                startDate TEXT NOT NULL,
                endDate TEXT,
                note TEXT,
                isActive INTEGER DEFAULT 1,
                lastProcessed TEXT,
                createdAt TEXT
              )
            ''');
          }
        },
        onOpen: (db) async {
          // Ensure tables exist (useful for existing DBs where migrations may have been missed)
          await db.execute('''
            CREATE TABLE IF NOT EXISTS expenses(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              date TEXT NOT NULL,
              note TEXT,
              createdAt TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS incomes(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              date TEXT NOT NULL,
              note TEXT,
              createdAt TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS recurring_transactions(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              type TEXT NOT NULL,
              recurrence TEXT NOT NULL,
              startDate TEXT NOT NULL,
              endDate TEXT,
              note TEXT,
              isActive INTEGER DEFAULT 1,
              lastProcessed TEXT,
              createdAt TEXT
            )
          ''');

          // Run diagnostics and migrations to bring older DBs up to date.
          try {
            await _runDiagnosticsAndMigrations(db);
          } catch (e) {
            debugPrint('Error running DB diagnostics/migrations: $e');
          }
        },
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  static Future<int> insertExpense(Expense expense) async {
    try {
      final db = await database;
      final id = await db.insert(
        'expenses',
        expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Inserted expense with id: $id');
      return id;
    } catch (e) {
      debugPrint('Error inserting expense: $e');
      rethrow;
    }
  }

  static Future<List<Expense>> getExpenses() async {
    try {
      final db = await database;
      final result = await db.query('expenses', orderBy: 'date DESC');
      debugPrint('Fetched ${result.length} expenses');
      return result.map((e) => Expense.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
      return [];
    }
  }

  static Future<int> deleteExpense(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('Deleted expense with id: $id');
      return count;
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  static Future<int> updateExpense(Expense expense) async {
    try {
      final db = await database;
      final count = await db.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
      debugPrint('Updated expense with id: ${expense.id}');
      return count;
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }

  static Future<List<Expense>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final db = await database;
      final result = await db.query(
        'expenses',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC',
      );
      return result.map((e) => Expense.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching expenses by date range: $e');
      return [];
    }
  }

  static Future<List<Expense>> getExpensesByCategory(String category) async {
    try {
      final db = await database;
      final result = await db.query(
        'expenses',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'date DESC',
      );
      return result.map((e) => Expense.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching expenses by category: $e');
      return [];
    }
  }

  static Future<void> clearAllExpenses() async {
    try {
      final db = await database;
      await db.delete('expenses');
      debugPrint('Cleared all expenses');
    } catch (e) {
      debugPrint('Error clearing expenses: $e');
      rethrow;
    }
  }

  // Income CRUD operations
  static Future<int> insertIncome(Income income) async {
    try {
      final db = await database;
      final id = await db.insert(
        'incomes',
        income.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Inserted income with id: $id');
      return id;
    } catch (e) {
      debugPrint('Error inserting income: $e');
      rethrow;
    }
  }

  static Future<List<Income>> getIncomes() async {
    try {
      final db = await database;
      final result = await db.query('incomes', orderBy: 'date DESC');
      debugPrint('Fetched ${result.length} incomes');
      return result.map((e) => Income.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching incomes: $e');
      return [];
    }
  }

  static Future<int> deleteIncome(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'incomes',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('Deleted income with id: $id');
      return count;
    } catch (e) {
      debugPrint('Error deleting income: $e');
      rethrow;
    }
  }

  static Future<int> updateIncome(Income income) async {
    try {
      final db = await database;
      final count = await db.update(
        'incomes',
        income.toMap(),
        where: 'id = ?',
        whereArgs: [income.id],
      );
      debugPrint('Updated income with id: ${income.id}');
      return count;
    } catch (e) {
      debugPrint('Error updating income: $e');
      rethrow;
    }
  }

  static Future<List<Income>> getIncomesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final db = await database;
      final result = await db.query(
        'incomes',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC',
      );
      return result.map((e) => Income.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching incomes by date range: $e');
      return [];
    }
  }

  static Future<List<Income>> getIncomesByCategory(String category) async {
    try {
      final db = await database;
      final result = await db.query(
        'incomes',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'date DESC',
      );
      return result.map((e) => Income.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching incomes by category: $e');
      return [];
    }
  }

  static Future<void> clearAllIncomes() async {
    try {
      final db = await database;
      await db.delete('incomes');
      debugPrint('Cleared all incomes');
    } catch (e) {
      debugPrint('Error clearing incomes: $e');
      rethrow;
    }
  }

  // Recurring Transaction CRUD operations
  static Future<int> insertRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    try {
      final db = await database;
      final id = await db.insert(
        'recurring_transactions',
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Inserted recurring transaction with id: $id');
      return id;
    } catch (e) {
      debugPrint('Error inserting recurring transaction: $e');
      rethrow;
    }
  }

  static Future<List<RecurringTransaction>> getRecurringTransactions() async {
    try {
      final db = await database;
      final result = await db.query(
        'recurring_transactions',
        orderBy: 'startDate DESC',
      );
      debugPrint('Fetched ${result.length} recurring transactions');
      return result.map((e) => RecurringTransaction.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching recurring transactions: $e');
      return [];
    }
  }

  static Future<int> deleteRecurringTransaction(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'recurring_transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('Deleted recurring transaction with id: $id');
      return count;
    } catch (e) {
      debugPrint('Error deleting recurring transaction: $e');
      rethrow;
    }
  }

  static Future<int> updateRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    try {
      final db = await database;
      final count = await db.update(
        'recurring_transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      debugPrint('Updated recurring transaction with id: ${transaction.id}');
      return count;
    } catch (e) {
      debugPrint('Error updating recurring transaction: $e');
      rethrow;
    }
  }

  static Future<List<RecurringTransaction>>
  getActiveRecurringTransactions() async {
    try {
      final db = await database;
      final result = await db.query(
        'recurring_transactions',
        where: 'isActive = ?',
        whereArgs: [1],
        orderBy: 'startDate DESC',
      );
      return result.map((e) => RecurringTransaction.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching active recurring transactions: $e');
      return [];
    }
  }
}
