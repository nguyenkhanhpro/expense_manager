import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import 'package:backend/database/database.dart';
import 'package:backend/models/transaction.dart' as model;

void main() {
  sqfliteFfiInit();

  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(
        databaseFactory: databaseFactoryFfi,
        dbPath: inMemoryDatabasePath,
      );
      await db.init();
    });

    tearDown(() async {
      await db.close();
    });

    test('inserts default categories once', () async {
      final categories = await db.getCategories();
      expect(categories, isNotEmpty);

      // Re-run init should not duplicate categories
      await db.init();
      final categoriesAfter = await db.getCategories();
      expect(categoriesAfter.length, categories.length);
    });

    test('adds, orders and summarizes transactions', () async {
      final now = DateTime.now();
      await db.addTransaction(model.Transaction(
        amount: 1000,
        categoryId: 1,
        note: 'Old income',
        date: now.subtract(const Duration(days: 1)),
        type: 'income',
      ));

      await db.addTransaction(model.Transaction(
        amount: 500,
        categoryId: 3,
        note: 'New expense',
        date: now,
        type: 'expense',
      ));

      final transactions = await db.getTransactions();
      expect(transactions.first.note, 'New expense'); 
      expect(transactions.last.note, 'Old income');

      final summary = await db.getSummary();
      expect(summary['income'], 1000);
      expect(summary['expense'], 500);
      expect(summary['balance'], 500);
    });
  });
}
