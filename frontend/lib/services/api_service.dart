import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/transaction.dart';
import 'platform_host_stub.dart'
    if (dart.library.io) 'platform_host_io.dart' as platform_host;

class ApiService {
  static final String baseUrl = 'http://${platform_host.resolveHost()}:8080/api';

  // Categories
  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    }
    throw Exception('Failed to load categories');
  }

  Future<void> addCategory(Category category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add category');
    }
  }

  Future<void> updateCategory(Category category) async {
    if (category.id == null) throw Exception('Category id is required');
    final response = await http.put(
      Uri.parse('$baseUrl/categories/${category.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update category');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/categories/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }

  // Transactions
  Future<List<Transaction>> getTransactions() async {
    final response = await http.get(Uri.parse('$baseUrl/transactions'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    }
    throw Exception('Failed to load transactions');
  }

  Future<void> addTransaction(Transaction transaction) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transaction.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add transaction');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    if (transaction.id == null) throw Exception('Transaction id is required');
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/${transaction.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transaction.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update transaction');
    }
  }

  Future<void> deleteTransaction(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/transactions/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction');
    }
  }

  // Summary
  Future<Map<String, double>> getSummary() async {
    final response = await http.get(Uri.parse('$baseUrl/summary'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'income': (data['income'] as num).toDouble(),
        'expense': (data['expense'] as num).toDouble(),
        'balance': (data['balance'] as num).toDouble(),
      };
    }
    throw Exception('Failed to load summary');
  }
}