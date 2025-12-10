import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/category.dart';
import '../models/transaction.dart' as model;

class AppDatabase {
  final DatabaseFactory? _databaseFactory;
  final String? _dbPath;
  Database? _db;

  AppDatabase({DatabaseFactory? databaseFactory, String? dbPath})
      : _databaseFactory = databaseFactory,
        _dbPath = dbPath;

  Future<void> init() async {
    sqfliteFfiInit();
    final factory = _databaseFactory ?? databaseFactoryFfi;

    _db = await factory.openDatabase(
      _dbPath ?? 'expense_manager.db',
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
        },
      ),
    );

    await _insertDefaultCategories();
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        categoryId INTEGER NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');
  }

  Future<void> _insertDefaultCategories() async {
    if (_db == null) return;
    final List<Map<String, Object?>> result =
        await _db!.rawQuery('SELECT COUNT(*) as count FROM categories');
    final count = (result.isNotEmpty ? result.first['count'] as int : 0);

    if (count == 0) {
      await _db!.insert(
          'categories', {'name': 'Lương', 'type': 'income', 'icon': '💰'});
      await _db!.insert(
          'categories', {'name': 'Thưởng', 'type': 'income', 'icon': '🎁'});
      await _db!.insert(
          'categories', {'name': 'Ăn uống', 'type': 'expense', 'icon': '🍔'});
      await _db!.insert(
          'categories', {'name': 'Di chuyển', 'type': 'expense', 'icon': '🚗'});
      await _db!.insert(
          'categories', {'name': 'Giải trí', 'type': 'expense', 'icon': '🎮'});
    }
  }

  Future<List<Category>> getCategories() async {
    final result = await _db!.query('categories');
    return result.map((row) => Category(
      id: row['id'] as int?,
      name: row['name'] as String,
      type: row['type'] as String,
      icon: row['icon'] as String,
    )).toList();
  }

  Future<void> addCategory(Category category) async {
    await _db!.insert('categories', {
      'name': category.name,
      'type': category.type,
      'icon': category.icon,
    });
  }

  Future<void> updateCategory(Category category) async {
    if (category.id == null) {
      throw ArgumentError('Category id is required for update');
    }
    await _db!.update(
      'categories',
      {
        'name': category.name,
        'type': category.type,
        'icon': category.icon,
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(int id) async {
    await _db!.delete('transactions', where: 'categoryId = ?', whereArgs: [id]);
    await _db!.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<model.Transaction>> getTransactions() async {
    final result = await _db!.query('transactions', orderBy: 'date DESC');
    return result.map((row) => model.Transaction(
      id: row['id'] as int?,
      amount: (row['amount'] as num).toDouble(),
      categoryId: row['categoryId'] as int,
      note: (row['note'] as String?) ?? '',
      date: DateTime.parse(row['date'] as String),
      type: row['type'] as String,
    )).toList();
  }

  Future<void> addTransaction(model.Transaction transaction) async {
    await _db!.insert('transactions', {
      'amount': transaction.amount,
      'categoryId': transaction.categoryId,
      'note': transaction.note,
      'date': transaction.date.toIso8601String(),
      'type': transaction.type,
    });
  }

  Future<void> updateTransaction(model.Transaction transaction) async {
    if (transaction.id == null) {
      throw ArgumentError('Transaction id is required for update');
    }
    await _db!.update(
      'transactions',
      {
        'amount': transaction.amount,
        'categoryId': transaction.categoryId,
        'note': transaction.note,
        'date': transaction.date.toIso8601String(),
        'type': transaction.type,
      },
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    await _db!.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getSummary() async {
    final incomeResult = await _db!.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'income'"
    );
    final expenseResult = await _db!.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'"
    );

    final income = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final expense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  Future<void> close() async {
    await _db?.close();
  }
}