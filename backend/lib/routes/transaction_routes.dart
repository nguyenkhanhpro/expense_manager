import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/database.dart';
import '../models/transaction.dart';

class TransactionRoutes {
  final AppDatabase db;

  TransactionRoutes(this.db);

  Router get router {
    final router = Router();

    router.get('/transactions', (Request request) async {
      final transactions = await db.getTransactions();
      return Response.ok(
        jsonEncode(transactions.map((t) => t.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.post('/transactions', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);
      final transaction = Transaction.fromJson(data);
      await db.addTransaction(transaction);
      return Response.ok(
        jsonEncode({'message': 'Transaction added successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.put('/transactions/<id>', (Request request, String id) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final transaction = Transaction.fromJson({
        ...data,
        'id': int.parse(id),
      });
      await db.updateTransaction(transaction);
      return Response.ok(
        jsonEncode({'message': 'Transaction updated successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.delete('/transactions/<id>', (Request request, String id) async {
      await db.deleteTransaction(int.parse(id));
      return Response.ok(
        jsonEncode({'message': 'Transaction deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/summary', (Request request) async {
      final summary = await db.getSummary();
      return Response.ok(
        jsonEncode(summary),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }
}