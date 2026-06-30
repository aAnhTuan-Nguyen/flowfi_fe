import 'package:flowfi_fe/features/transactions/domain/entities/transaction.dart';
import 'package:flowfi_fe/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/flowfi_test_helpers.dart';

void main() {
  testWidgets('switches between the four primary dashboard tabs', (
    tester,
  ) async {
    await pumpFlowFiApp(tester, authenticatedAuthRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Giao dịch'));
    await tester.pumpAndSettle();
    expect(
      find.text('Duyệt giao dịch mới, nháp và đã xác nhận.'),
      findsOneWidget,
    );
    expect(find.text('Groceries'), findsOneWidget);

    await tester.tap(find.text('Ví'));
    await tester.pumpAndSettle();
    expect(
      find.text('Track balances across cash, bank, and e-wallets.'),
      findsOneWidget,
    );
    expect(find.text('500000'), findsOneWidget);

    await tester.tap(find.text('Ngân sách'));
    await tester.pumpAndSettle();
    expect(
      find.text('Watch monthly limits and savings progress.'),
      findsOneWidget,
    );
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Emergency Fund'), findsOneWidget);

    await tester.tap(find.text('Trang chủ'));
    await tester.pumpAndSettle();
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
  });

  testWidgets('center add action opens the transaction launcher', (
    tester,
  ) async {
    await pumpFlowFiApp(tester, authenticatedAuthRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();

    expect(find.text('Thêm giao dịch'), findsOneWidget);
    expect(find.text('Quét hóa đơn'), findsOneWidget);
    expect(find.text('Nói giao dịch'), findsOneWidget);
    expect(find.text('Nhập nhanh'), findsOneWidget);
  });

  testWidgets('transaction launcher opens the scan flow', (tester) async {
    await pumpFlowFiApp(tester, authenticatedAuthRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quét hóa đơn'));
    await tester.pumpAndSettle();

    expect(find.text('Quét hóa đơn'), findsOneWidget);
    expect(find.text('Chụp ảnh'), findsOneWidget);
    expect(find.text('Chọn ảnh'), findsOneWidget);
  });

  testWidgets('transaction launcher opens the voice placeholder flow', (
    tester,
  ) async {
    await pumpFlowFiApp(tester, authenticatedAuthRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nói giao dịch'));
    await tester.pumpAndSettle();

    expect(find.text('Nói giao dịch'), findsOneWidget);
    expect(find.text('Voice sẽ tạo gợi ý để bạn xác nhận.'), findsOneWidget);
  });

  testWidgets('transaction launcher opens the quick manual form', (
    tester,
  ) async {
    await pumpFlowFiApp(tester, authenticatedAuthRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhập nhanh'));
    await tester.pumpAndSettle();

    expect(find.text('Nhập nhanh'), findsOneWidget);
    expect(find.text('Số tiền'), findsOneWidget);
    expect(find.text('Danh mục'), findsWidgets);
    expect(find.text('Ghi chú'), findsOneWidget);
  });

  testWidgets('quick manual form saves a confirmed transaction with defaults', (
    tester,
  ) async {
    final transactionRepository = TestTransactionRepository();
    await pumpFlowFiApp(
      tester,
      authenticatedAuthRepository(),
      transactionRepository: transactionRepository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhập nhanh'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.ancestor(
        of: find.text('Số tiền'),
        matching: find.byType(TextFormField),
      ),
      '50000',
    );
    await tester.enterText(
      find.ancestor(
        of: find.text('Ghi chú'),
        matching: find.byType(TextFormField),
      ),
      'Cà phê sáng',
    );
    await tester.tap(find.text('Lưu giao dịch'));
    await tester.pumpAndSettle();

    expect(transactionRepository.createdWalletId, 'wallet-1');
    expect(transactionRepository.createdTagId, 'tag-1');
    expect(transactionRepository.createdTitle, 'Cà phê sáng');
    expect(transactionRepository.createdAmount, '50000');
    expect(transactionRepository.createdStatus, TransactionStatus.confirmed);
    expect(transactionRepository.createdDescription, 'Cà phê sáng');
  });

  testWidgets('opens the home tab at the root route when authenticated', (
    tester,
  ) async {
    final router = await pumpFlowFiApp(tester, authenticatedAuthRepository());
    await tester.pumpAndSettle();

    expect(router.state.uri.path, AppRoutes.root);
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
  });

  for (final routeCase in [
    (path: AppRoutes.home, text: 'Giao dịch gần đây'),
    (
      path: AppRoutes.transactions,
      text: 'Duyệt giao dịch mới, nháp và đã xác nhận.',
    ),
    (
      path: AppRoutes.wallets,
      text: 'Track balances across cash, bank, and e-wallets.',
    ),
    (
      path: AppRoutes.budgets,
      text: 'Watch monthly limits and savings progress.',
    ),
    (
      path: AppRoutes.insights,
      text: 'Notifications and backend-driven insights.',
    ),
  ]) {
    testWidgets('opens ${routeCase.path} on the matching authenticated tab', (
      tester,
    ) async {
      final router = await pumpFlowFiApp(
        tester,
        authenticatedAuthRepository(),
        initialLocation: routeCase.path,
      );
      await tester.pumpAndSettle();

      expect(router.state.uri.path, routeCase.path);
      expect(find.text(routeCase.text), findsOneWidget);
    });
  }

  testWidgets('bottom navigation changes the route location', (tester) async {
    final router = await pumpFlowFiApp(tester, authenticatedAuthRepository());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Giao dịch'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.transactions);
    expect(
      find.text('Duyệt giao dịch mới, nháp và đã xác nhận.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ví'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.wallets);
    expect(
      find.text('Track balances across cash, bank, and e-wallets.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ngân sách'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.budgets);
    expect(
      find.text('Watch monthly limits and savings progress.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Trang chủ'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.home);
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
  });
}
