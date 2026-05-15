import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/app_settings.dart';
import '../models/budget.dart';
import '../models/category_model.dart';
import '../models/expense.dart';
import '../utils/category_catalog.dart';

class DatabaseService {
  static const _dbName = 'catatboros.db';
  static const _dbVersion = 1;
  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final path = p.join(await getDatabasesPath(), _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);
        await _insertDefaultCategories(db);
        await _insertDefaultSettings(db);
      },
      onOpen: _ensureDefaults,
    );
  }

  Future<Database> get database async {
    await init();
    return _db!;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''CREATE TABLE expenses(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      amount INTEGER NOT NULL,
      category_id TEXT NOT NULL,
      category_name TEXT NOT NULL,
      category_icon TEXT NOT NULL,
      spent_at TEXT NOT NULL,
      note TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE categories(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      icon TEXT NOT NULL,
      keywords TEXT NOT NULL,
      color INTEGER NOT NULL,
      is_default INTEGER NOT NULL,
      sort_order INTEGER NOT NULL
    )''');
    await db.execute('''CREATE TABLE budgets(
      month_key TEXT PRIMARY KEY,
      total_budget INTEGER NOT NULL,
      category_budgets TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE settings(
      id INTEGER PRIMARY KEY CHECK(id = 1),
      data TEXT NOT NULL
    )''');
  }

  Future<void> _ensureDefaults(Database db) async {
    final categoryCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM categories')) ?? 0;
    if (categoryCount == 0) await _insertDefaultCategories(db);
    final settingsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM settings')) ?? 0;
    if (settingsCount == 0) await _insertDefaultSettings(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final batch = db.batch();
    for (final category in CategoryCatalog.defaults) {
      batch.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _insertDefaultSettings(Database db) async {
    await db.insert('settings', {'id': 1, 'data': AppSettings.defaults().encode()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final rows = await db.query('expenses', orderBy: 'spent_at DESC, id DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return db.insert('expenses', expense.toMap()..remove('id'));
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update('expenses', expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteExpensesByDay(DateTime day) async {
    final db = await database;
    final start = DateTime(day.year, day.month, day.day).toIso8601String();
    final end = DateTime(day.year, day.month, day.day).add(const Duration(days: 1)).toIso8601String();
    await db.delete('expenses', where: 'spent_at >= ? AND spent_at < ?', whereArgs: [start, end]);
  }

  Future<List<ExpenseCategory>> getCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'sort_order ASC, name ASC');
    return rows.map(ExpenseCategory.fromMap).toList();
  }

  Future<void> upsertCategory(ExpenseCategory category) async {
    final db = await database;
    await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteCategory(String id) async {
    if (id == 'lainnya') return;
    final db = await database;
    await db.transaction((txn) async {
      final fallback = CategoryCatalog.defaults.last;
      await txn.update('expenses', {'category_id': fallback.id, 'category_name': fallback.name, 'category_icon': fallback.icon}, where: 'category_id = ?', whereArgs: [id]);
      await txn.delete('categories', where: 'id = ? AND is_default = 0', whereArgs: [id]);
    });
  }

  Future<AppSettings> getSettings() async {
    final db = await database;
    final rows = await db.query('settings', where: 'id = 1');
    if (rows.isEmpty) return AppSettings.defaults();
    return AppSettings.decode(rows.first['data'] as String);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await database;
    await db.insert('settings', {'id': 1, 'data': settings.encode()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Budget> getBudget(String monthKey) async {
    final db = await database;
    final rows = await db.query('budgets', where: 'month_key = ?', whereArgs: [monthKey]);
    if (rows.isEmpty) return Budget.empty(monthKey);
    return Budget.fromMap(rows.first);
  }

  Future<List<Budget>> getBudgets() async {
    final db = await database;
    final rows = await db.query('budgets', orderBy: 'month_key DESC');
    return rows.map(Budget.fromMap).toList();
  }

  Future<void> saveBudget(Budget budget) async {
    final db = await database;
    await db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>> exportAll() async {
    final db = await database;
    return {
      'app': 'CatatBoros',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'expenses': await db.query('expenses'),
      'categories': await db.query('categories'),
      'budgets': await db.query('budgets'),
      'settings': (await getSettings()).toJson(),
    };
  }

  Future<void> importAll(Map<String, dynamic> data) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('expenses');
      await txn.delete('categories');
      await txn.delete('budgets');
      final expenses = List<Map<String, dynamic>>.from(data['expenses'] as List? ?? []);
      final categories = List<Map<String, dynamic>>.from(data['categories'] as List? ?? []);
      final budgets = List<Map<String, dynamic>>.from(data['budgets'] as List? ?? []);
      for (final item in categories) {
        await txn.insert('categories', item, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      if (categories.isEmpty) {
        for (final c in CategoryCatalog.defaults) {
          await txn.insert('categories', c.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      for (final item in expenses) {
        await txn.insert('expenses', item, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final item in budgets) {
        await txn.insert('budgets', item, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      if (data['settings'] is Map) {
        await txn.insert('settings', {'id': 1, 'data': jsonEncode(Map<String, dynamic>.from(data['settings'] as Map))}, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
