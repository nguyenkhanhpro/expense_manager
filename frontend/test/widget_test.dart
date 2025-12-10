import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/api_service.dart';

class _StubApiService extends ApiService {
  @override
  Future<Map<String, double>> getSummary() async => {
        'income': 1000000,
        'expense': 400000,
        'balance': 600000,
      };
}

void main() {
  testWidgets('Hiển thị màn hình chính với tổng quan', (tester) async {
    await tester.pumpWidget(MyApp(apiService: _StubApiService()));
    await tester.pumpAndSettle();

    expect(find.text('Quản lý Thu Chi'), findsOneWidget);
    expect(find.text('Số dư'), findsWidgets);
  });
}
