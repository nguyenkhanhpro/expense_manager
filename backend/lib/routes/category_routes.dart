import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/database.dart';
import '../models/category.dart';

class CategoryRoutes {
  final AppDatabase db;

  CategoryRoutes(this.db);

  Router get router {
    final router = Router();

    router.get('/categories', (Request request) async {
      final categories = await db.getCategories();
      return Response.ok(
        jsonEncode(categories.map((c) => c.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.post('/categories', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);
      final category = Category.fromJson(data);
      await db.addCategory(category);
      return Response.ok(
        jsonEncode({'message': 'Category added successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.put('/categories/<id>', (Request request, String id) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final category = Category.fromJson({
        ...data,
        'id': int.parse(id),
      });
      await db.updateCategory(category);
      return Response.ok(
        jsonEncode({'message': 'Category updated successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.delete('/categories/<id>', (Request request, String id) async {
      await db.deleteCategory(int.parse(id));
      return Response.ok(
        jsonEncode({'message': 'Category deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }
}