import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/transaction.dart';
import 'package:frontend/screens/history_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/transaction_item.dart';

class _FakeApiService extends ApiService {
  @override
  Future<List<Category>> getCategories() async {
    return [
      Category(id: 1, name: 'Lương', type: 'income', icon: '💰'),
      Category(id: 2, name: 'Ăn uống', type: 'expense', icon: '🍔'),
    ];
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final base = DateTime(2025, 12, 9, 15, 52);

    return [
      Transaction(
        id: 1,
        amount: 1000000,
        categoryId: 1,
        note: 'Thu mới nhất',
        date: base,
        type: 'income',
      ),
      Transaction(
        id: 2,
        amount: 500000,
        categoryId: 1,
        note: 'Thu cũ',
        date: base.subtract(const Duration(days: 1)), // 08/12/2025
        type: 'income',
      ),
      Transaction(
        id: 3,
        amount: 200000,
        categoryId: 2,
        note: 'Chi tháng này',
        date: base.subtract(const Duration(hours: 1)), // 09/12/2025
        type: 'expense',
      ),
      Transaction(
        id: 4,
        amount: 150000,
        categoryId: 2,
        note: 'Chi tháng trước',
        date: base.subtract(const Duration(days: 35)), // 04/11/2025
        type: 'expense',
      ),
    ];
  }

  @override
  Future<void> deleteTransaction(int id) async {}
}

void main() {
  testWidgets('lọc và sắp xếp giao dịch theo thời gian và loại',
      (WidgetTester tester) async {
    final api = _FakeApiService();

    await tester.pumpWidget(
      MaterialApp(
        home: HistoryScreen(apiService: api),
      ),
    );

    await tester.pumpAndSettle();

    // ===== Test sắp xếp mặc định =====
    final itemsDesc = tester
        .widgetList<TransactionItem>(find.byType(TransactionItem))
        .toList();

    expect(itemsDesc.length, 4);
    expect(itemsDesc.first.transaction.note, 'Thu mới nhất');

    // ===== Test đổi sang cũ nhất trước =====
    final sortDropdown = find.byKey(const Key('sortOrderDropdown'));
    await tester.tap(sortDropdown);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    
    final ascOption = find.text('Cũ → Mới');
    expect(ascOption, findsWidgets);
    await tester.tap(ascOption.last);
    await tester.pumpAndSettle();

    final itemsAsc = tester
        .widgetList<TransactionItem>(find.byType(TransactionItem))
        .toList();

    // Sau khi sắp xếp asc (cũ → mới), item đầu tiên phải là "Chi tháng trước" (04/11/2025 - cũ nhất)
    expect(itemsAsc.first.transaction.note, 'Chi tháng trước');
    expect(itemsAsc.last.transaction.note, 'Thu mới nhất');

    // ===== Test lọc theo loại Chi =====
    final typeDropdown = find.byKey(const Key('typeFilterDropdown'));
    await tester.tap(typeDropdown);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    
    final chiOption = find.text('Chi');
    expect(chiOption, findsWidgets);
    await tester.tap(chiOption.last);
    await tester.pumpAndSettle();

    expect(find.text('Chi tháng này'), findsOneWidget);
    expect(find.text('Thu cũ'), findsNothing);

    // ===== Test lọc theo tháng (tháng trước là 11/2025) =====
    final monthDropdown = find.byKey(const Key('monthFilterDropdown'));
    await tester.tap(monthDropdown);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    
    final monthOption = find.text('11/2025');
    expect(monthOption, findsWidgets);
    await tester.tap(monthOption.last);
    await tester.pumpAndSettle();

    expect(find.text('Chi tháng trước'), findsOneWidget);
    expect(find.text('Chi tháng này'), findsNothing);

    // ===== Test xóa toàn bộ filter =====
    await tester.tap(find.byKey(const Key('clearFilterButton')));
    await tester.pumpAndSettle();
    expect(find.text('Thu mới nhất'), findsOneWidget);
    expect(find.text('Thu cũ'), findsOneWidget);
  });
}
