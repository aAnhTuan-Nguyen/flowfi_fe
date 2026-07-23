import 'package:fl_chart/fl_chart.dart';
import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/transactions/domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/flowfi_test_helpers.dart';

void main() {
  testWidgets('shows a provider-backed finance dashboard', (tester) async {
    await pumpFlowFiShell(tester, currentDate: DateTime(2026, 6, 30));
    await tester.pumpAndSettle();

    expect(find.text('Xin chào, Alex'), findsOneWidget);
    expect(find.text('Tổng số dư'), findsOneWidget);
    expect(find.text('5.000.000 VND'), findsOneWidget);
    expect(find.text('Chi tiêu tháng này'), findsOneWidget);
    expect(find.text('120.000 VND'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Coffee House'), findsNothing);
    expect(find.text('Ngân sách nổi bật'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('home dashboard scrolls on a compact mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpFlowFiShell(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ngân sách nổi bật'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();

    expect(find.text('Monthly Salary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'recent transactions prefer confirmed activity over receipt date',
    (tester) async {
      final repository = TestTransactionRepository(
        transactions: [
          Transaction(
            id: 'draft',
            title: 'Draft should stay hidden',
            amount: '10000',
            type: MoneyFlowType.expense,
            date: DateTime(2026, 7, 30),
            status: TransactionStatus.draft,
            inputMethod: TransactionInputMethod.ocr,
            updatedAt: DateTime.utc(2026, 7, 30),
          ),
          for (var day = 23; day >= 21; day--)
            Transaction(
              id: 'confirmed-$day',
              title: 'Confirmed $day',
              amount: '20000',
              type: MoneyFlowType.expense,
              date: DateTime(2026, 7, day),
              status: TransactionStatus.confirmed,
              inputMethod: TransactionInputMethod.manual,
              updatedAt: DateTime.utc(2026, 7, day),
            ),
          Transaction(
            id: 'just-confirmed',
            title: 'Just confirmed OCR',
            amount: '50000',
            type: MoneyFlowType.expense,
            date: DateTime(2026, 7, 1),
            status: TransactionStatus.confirmed,
            inputMethod: TransactionInputMethod.ocr,
            updatedAt: DateTime.utc(2026, 7, 31),
          ),
        ],
      );

      await pumpFlowFiShell(tester, transactionRepository: repository);
      await tester.pumpAndSettle();

      expect(find.text('Just confirmed OCR'), findsOneWidget);
      expect(find.text('Draft should stay hidden'), findsNothing);
      expect(find.text('Confirmed 21'), findsNothing);
    },
  );

  testWidgets('home keeps creation actions in the center add launcher', (
    tester,
  ) async {
    await pumpFlowFiApp(tester, authenticatedAuthRepository());
    await tester.pumpAndSettle();

    expect(find.text('Quét'), findsNothing);
    expect(find.text('Danh mục'), findsNothing);

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();
    expect(find.text('Quét hóa đơn'), findsOneWidget);
    expect(find.text('Nhập nhanh'), findsOneWidget);
  });

  testWidgets('home account action navigates to the profile page', (
    tester,
  ) async {
    final router = await pumpFlowFiApp(tester, authenticatedAuthRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/profile');
    expect(find.text('Hồ sơ cá nhân'), findsOneWidget);
  });
}
