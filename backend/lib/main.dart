import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'database/database.dart';
import 'routes/category_routes.dart';
import 'routes/transaction_routes.dart';

Future<void> main() async {
  final db = AppDatabase();
  await db.init();
  
  final app = Router();

  // CORS Middleware
  final cors = createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        });
      }
      return null;
    },
    responseHandler: (Response response) {
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      });
    },
  );

  // Routes
  app.mount('/api', CategoryRoutes(db).router.call);
  app.mount('/api', TransactionRoutes(db).router.call);

  app.get('/', (Request request) => Response.ok('Expense Manager API'));

  final handler = Pipeline()
      .addMiddleware(cors)
      .addMiddleware(logRequests())
      .addHandler(app.call);

  // Bind on all interfaces so real devices/emulators can reach the API.
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('Server running on http://${server.address.host}:${server.port}');
  print('API Endpoints:');
  print('GET  http://localhost:8080/api/categories');
  print('POST http://localhost:8080/api/categories');
  print('GET  http://localhost:8080/api/transactions');
  print('POST http://localhost:8080/api/transactions');
  print('GET  http://localhost:8080/api/summary');
}