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
        if (first is int) {
          currentVersion = first;
        } else if (first is String) {
          currentVersion = int.tryParse(first) ?? 0;
        }
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

          // Create indexes for better performance
          try {
            await _createIndexesInternal(db);
          } catch (e) {
            debugPrint('Error creating indexes on open: $e');
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

  // ============================================================================
  // ENHANCED DATABASE OPERATIONS
  // ============================================================================

  /// Internal method to create indexes (used during database initialization)
  static Future<void> _createIndexesInternal(Database db) async {
    // Index on expenses date for faster date range queries
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date DESC)',
    );
    
    // Index on expenses category for faster category queries
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category)',
    );
    
    // Index on incomes date
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_incomes_date ON incomes(date DESC)',
    );
    
    // Index on incomes category
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_incomes_category ON incomes(category)',
    );
    
    // Composite index for recurring transactions
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_recurring_active_date ON recurring_transactions(isActive, startDate DESC)',
    );
    
    debugPrint('Database indexes created successfully');
  }

  /// Create database indexes for improved query performance (public method)
  static Future<void> createIndexes() async {
    try {
      final db = await database;
      await _createIndexesInternal(db);
    } catch (e) {
      debugPrint('Error creating indexes: $e');
    }
  }

  // ============================================================================
  // BATCH OPERATIONS
  // ============================================================================

  /// Insert multiple expenses in a single transaction
  static Future<List<int>> insertExpensesBatch(List<Expense> expenses) async {
    try {
      final db = await database;
      final ids = <int>[];
      
      await db.transaction((txn) async {
        for (var expense in expenses) {
          final id = await txn.insert(
            'expenses',
            expense.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          ids.add(id);
        }
      });
      
      debugPrint('Batch inserted ${ids.length} expenses');
      return ids;
    } catch (e) {
      debugPrint('Error batch inserting expenses: $e');
      rethrow;
    }
  }

  /// Insert multiple incomes in a single transaction
  static Future<List<int>> insertIncomesBatch(List<Income> incomes) async {
    try {
      final db = await database;
      final ids = <int>[];
      
      await db.transaction((txn) async {
        for (var income in incomes) {
          final id = await txn.insert(
            'incomes',
            income.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          ids.add(id);
        }
      });
      
      debugPrint('Batch inserted ${ids.length} incomes');
      return ids;
    } catch (e) {
      debugPrint('Error batch inserting incomes: $e');
      rethrow;
    }
  }

  /// Delete multiple expenses by IDs
  static Future<int> deleteExpensesBatch(List<int> ids) async {
    try {
      final db = await database;
      int totalDeleted = 0;
      
      await db.transaction((txn) async {
        for (var id in ids) {
          final count = await txn.delete(
            'expenses',
            where: 'id = ?',
            whereArgs: [id],
          );
          totalDeleted += count;
        }
      });
      
      debugPrint('Batch deleted $totalDeleted expenses');
      return totalDeleted;
    } catch (e) {
      debugPrint('Error batch deleting expenses: $e');
      rethrow;
    }
  }

  // ============================================================================
  // AGGREGATE QUERIES
  // ============================================================================

  /// Get total expenses by category
  static Future<Map<String, double>> getExpenseTotalsByCategory() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT category, SUM(amount) as total
        FROM expenses
        GROUP BY category
        ORDER BY total DESC
      ''');
      
      final totals = <String, double>{};
      for (var row in result) {
        totals[row['category'] as String] = row['total'] as double;
      }
      
      return totals;
    } catch (e) {
      debugPrint('Error getting expense totals by category: $e');
      return {};
    }
  }

  /// Get total incomes by category
  static Future<Map<String, double>> getIncomeTotalsByCategory() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT category, SUM(amount) as total
        FROM incomes
        GROUP BY category
        ORDER BY total DESC
      ''');
      
      final totals = <String, double>{};
      for (var row in result) {
        totals[row['category'] as String] = row['total'] as double;
      }
      
      return totals;
    } catch (e) {
      debugPrint('Error getting income totals by category: $e');
      return {};
    }
  }

  /// Get monthly expense totals for the last N months
  static Future<Map<String, double>> getMonthlyExpenseTotals(int months) async {
    try {
      final db = await database;
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - months, 1);
      
      final result = await db.rawQuery('''
        SELECT strftime('%Y-%m', date) as month, SUM(amount) as total
        FROM expenses
        WHERE date >= ?
        GROUP BY month
        ORDER BY month DESC
      ''', [startDate.toIso8601String()]);
      
      final totals = <String, double>{};
      for (var row in result) {
        totals[row['month'] as String] = row['total'] as double;
      }
      
      return totals;
    } catch (e) {
      debugPrint('Error getting monthly expense totals: $e');
      return {};
    }
  }

  /// Get monthly income totals for the last N months
  static Future<Map<String, double>> getMonthlyIncomeTotals(int months) async {
    try {
      final db = await database;
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - months, 1);
      
      final result = await db.rawQuery('''
        SELECT strftime('%Y-%m', date) as month, SUM(amount) as total
        FROM incomes
        WHERE date >= ?
        GROUP BY month
        ORDER BY month DESC
      ''', [startDate.toIso8601String()]);
      
      final totals = <String, double>{};
      for (var row in result) {
        totals[row['month'] as String] = row['total'] as double;
      }
      
      return totals;
    } catch (e) {
      debugPrint('Error getting monthly income totals: $e');
      return {};
    }
  }

  /// Get spending statistics for a date range
  static Future<Map<String, dynamic>> getSpendingStats(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as count,
          SUM(amount) as total,
          AVG(amount) as average,
          MAX(amount) as max,
          MIN(amount) as min
        FROM expenses
        WHERE date BETWEEN ? AND ?
      ''', [start.toIso8601String(), end.toIso8601String()]);
      
      if (result.isEmpty) {
        return {
          'count': 0,
          'total': 0.0,
          'average': 0.0,
          'max': 0.0,
          'min': 0.0,
        };
      }
      
      final row = result.first;
      return {
        'count': row['count'] ?? 0,
        'total': row['total'] ?? 0.0,
        'average': row['average'] ?? 0.0,
        'max': row['max'] ?? 0.0,
        'min': row['min'] ?? 0.0,
      };
    } catch (e) {
      debugPrint('Error getting spending stats: $e');
      return {
        'count': 0,
        'total': 0.0,
        'average': 0.0,
        'max': 0.0,
        'min': 0.0,
      };
    }
  }

  // ============================================================================
  // SEARCH AND FILTER OPERATIONS
  // ============================================================================

  /// Search expenses by title or note
  static Future<List<Expense>> searchExpenses(String query) async {
    try {
      final db = await database;
      final result = await db.query(
        'expenses',
        where: 'title LIKE ? OR note LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'date DESC',
      );
      
      return result.map((e) => Expense.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error searching expenses: $e');
      return [];
    }
  }

  /// Search incomes by title or note
  static Future<List<Income>> searchIncomes(String query) async {
    try {
      final db = await database;
      final result = await db.query(
        'incomes',
        where: 'title LIKE ? OR note LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'date DESC',
      );
      
      return result.map((e) => Income.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error searching incomes: $e');
      return [];
    }
  }

  /// Get expenses with advanced filters
  static Future<List<Expense>> getExpensesFiltered({
    List<String>? categories,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
  }) async {
    try {
      final db = await database;
      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];
      
      if (categories != null && categories.isNotEmpty) {
        whereClauses.add('category IN (${List.filled(categories.length, '?').join(',')})');
        whereArgs.addAll(categories);
      }
      
      if (minAmount != null) {
        whereClauses.add('amount >= ?');
        whereArgs.add(minAmount);
      }
      
      if (maxAmount != null) {
        whereClauses.add('amount <= ?');
        whereArgs.add(maxAmount);
      }
      
      if (startDate != null) {
        whereClauses.add('date >= ?');
        whereArgs.add(startDate.toIso8601String());
      }
      
      if (endDate != null) {
        whereClauses.add('date <= ?');
        whereArgs.add(endDate.toIso8601String());
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClauses.add('(title LIKE ? OR note LIKE ?)');
        whereArgs.add('%$searchQuery%');
        whereArgs.add('%$searchQuery%');
      }
      
      final orderByColumn = sortBy ?? 'date';
      final orderDirection = ascending ? 'ASC' : 'DESC';
      
      final result = await db.query(
        'expenses',
        where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: '$orderByColumn $orderDirection',
      );
      
      return result.map((e) => Expense.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error getting filtered expenses: $e');
      return [];
    }
  }

  /// Get top N expenses
  static Future<List<Expense>> getTopExpenses(int limit) async {
    try {
      final db = await database;
      final result = await db.query(
        'expenses',
        orderBy: 'amount DESC',
        limit: limit,
      );
      
      return result.map((e) => Expense.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error getting top expenses: $e');
      return [];
    }
  }

  // ============================================================================
  // DATA EXPORT/IMPORT
  // ============================================================================

  /// Export all data as JSON
  static Future<Map<String, dynamic>> exportAllData() async {
    try {
      final expenses = await getExpenses();
      final incomes = await getIncomes();
      final recurringTransactions = await getRecurringTransactions();
      
      return {
        'version': 1,
        'exportDate': DateTime.now().toIso8601String(),
        'expenses': expenses.map((e) => e.toMap()).toList(),
        'incomes': incomes.map((i) => i.toMap()).toList(),
        'recurringTransactions': recurringTransactions.map((r) => r.toMap()).toList(),
      };
    } catch (e) {
      debugPrint('Error exporting data: $e');
      rethrow;
    }
  }

  /// Import data from JSON
  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      final db = await database;
      
      await db.transaction((txn) async {
        // Import expenses
        if (data['expenses'] != null) {
          for (var expenseMap in data['expenses']) {
            final expense = Expense.fromMap(expenseMap);
            await txn.insert(
              'expenses',
              expense.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
        
        // Import incomes
        if (data['incomes'] != null) {
          for (var incomeMap in data['incomes']) {
            final income = Income.fromMap(incomeMap);
            await txn.insert(
              'incomes',
              income.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
        
        // Import recurring transactions
        if (data['recurringTransactions'] != null) {
          for (var transactionMap in data['recurringTransactions']) {
            final transaction = RecurringTransaction.fromMap(transactionMap);
            await txn.insert(
              'recurring_transactions',
              transaction.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });
      
      debugPrint('Data imported successfully');
    } catch (e) {
      debugPrint('Error importing data: $e');
      rethrow;
    }
  }

  // ============================================================================
  // ANALYTICS HELPERS
  // ============================================================================

  /// Get expense count by category
  static Future<Map<String, int>> getExpenseCountByCategory() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT category, COUNT(*) as count
        FROM expenses
        GROUP BY category
        ORDER BY count DESC
      ''');
      
      final counts = <String, int>{};
      for (var row in result) {
        counts[row['category'] as String] = row['count'] as int;
      }
      
      return counts;
    } catch (e) {
      debugPrint('Error getting expense count by category: $e');
      return {};
    }
  }

  /// Get average expense by category
  static Future<Map<String, double>> getAverageExpenseByCategory() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT category, AVG(amount) as average
        FROM expenses
        GROUP BY category
        ORDER BY average DESC
      ''');
      
      final averages = <String, double>{};
      for (var row in result) {
        averages[row['category'] as String] = row['average'] as double;
      }
      
      return averages;
    } catch (e) {
      debugPrint('Error getting average expense by category: $e');
      return {};
    }
  }

  /// Get daily spending trend for last N days
  static Future<Map<String, double>> getDailySpendingTrend(int days) async {
    try {
      final db = await database;
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      
      final result = await db.rawQuery('''
        SELECT DATE(date) as day, SUM(amount) as total
        FROM expenses
        WHERE date >= ?
        GROUP BY day
        ORDER BY day DESC
      ''', [startDate.toIso8601String()]);
      
      final trend = <String, double>{};
      for (var row in result) {
        trend[row['day'] as String] = row['total'] as double;
      }
      
      return trend;
    } catch (e) {
      debugPrint('Error getting daily spending trend: $e');
      return {};
    }
  }

  /// Get net balance (income - expenses) for date range
  static Future<double> getNetBalance(DateTime start, DateTime end) async {
    try {
      final db = await database;
      
      final incomeResult = await db.rawQuery('''
        SELECT SUM(amount) as total
        FROM incomes
        WHERE date BETWEEN ? AND ?
      ''', [start.toIso8601String(), end.toIso8601String()]);
      
      final expenseResult = await db.rawQuery('''
        SELECT SUM(amount) as total
        FROM expenses
        WHERE date BETWEEN ? AND ?
      ''', [start.toIso8601String(), end.toIso8601String()]);
      
      final totalIncome = incomeResult.first['total'] as double? ?? 0.0;
      final totalExpense = expenseResult.first['total'] as double? ?? 0.0;
      
      return totalIncome - totalExpense;
    } catch (e) {
      debugPrint('Error calculating net balance: $e');
      return 0.0;
    }
  }

  // ============================================================================
  // MAINTENANCE OPERATIONS
  // ============================================================================

  /// Vacuum database to optimize storage and performance
  static Future<void> vacuumDatabase() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
      debugPrint('Database vacuumed successfully');
    } catch (e) {
      debugPrint('Error vacuuming database: $e');
    }
  }

  /// Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final db = await database;
      
      final expenseCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM expenses'),
      ) ?? 0;
      
      final incomeCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM incomes'),
      ) ?? 0;
      
      final recurringCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM recurring_transactions'),
      ) ?? 0;
      
      return {
        'expenseCount': expenseCount,
        'incomeCount': incomeCount,
        'recurringCount': recurringCount,
        'totalRecords': expenseCount + incomeCount + recurringCount,
      };
    } catch (e) {
      debugPrint('Error getting database stats: $e');
      return {
        'expenseCount': 0,
        'incomeCount': 0,
        'recurringCount': 0,
        'totalRecords': 0,
      };
    }
  }
}
