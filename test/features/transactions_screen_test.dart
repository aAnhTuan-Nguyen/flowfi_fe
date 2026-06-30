import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/transactions/domain/entities/transaction.dart';
import 'package:flowfi_fe/features/transactions/presentation/widgets/transaction_form_sheet.dart';
import 'package:flowfi_fe/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import '../helpers/flowfi_test_helpers.dart';

void main() {
  testWidgets('transaction edit form keeps wallet and status immutable', (
    tester,
  ) async {
    final transactionRepository = TestTransactionRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: flowFiTestOverrides(
          authRepository: authenticatedAuthRepository(),
          transactionRepository: transactionRepository,
        ),
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TransactionFormSheet(
                transaction: Transaction(
                  id: 'tx-draft',
                  walletId: 'wallet-1',
                  tagId: 'tag-1',
                  title: 'Receipt review',
                  amount: '125000',
                  type: MoneyFlowType.expense,
                  date: DateTime(2026, 6, 27),
                  status: TransactionStatus.draft,
                  inputMethod: TransactionInputMethod.ocr,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byType(DropdownButtonFormField<TransactionStatus>),
      findsNothing,
    );
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    await tester.ensureVisible(find.text('Lưu thay đổi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu thay đổi'));
    await tester.pumpAndSettle();

    expect(transactionRepository.updatedId, 'tx-draft');
  });

  testWidgets('transactions screen filters by type and status', (tester) async {
    await pumpFlowFiApp(
      tester,
      authenticatedAuthRepository(),
      initialLocation: AppRoutes.transactions,
    );
    await tester.pumpAndSettle();

    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Thu'), findsOneWidget);
    expect(find.text('Chi'), findsOneWidget);
    expect(find.text('Nháp'), findsOneWidget);
    expect(find.text('Đã xác nhận'), findsOneWidget);

    await tester.tap(find.text('Thu'));
    await tester.pumpAndSettle();
    expect(find.text('Monthly Salary'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);

    await tester.tap(find.text('Nháp'));
    await tester.pumpAndSettle();
    expect(find.text('Chờ kiểm tra'), findsOneWidget);
    expect(find.text('Nháp'), findsWidgets);
  });

  testWidgets('transactions card actions confirm and delete entries', (
    tester,
  ) async {
    final transactionRepository = TestTransactionRepository();
    await pumpFlowFiApp(
      tester,
      authenticatedAuthRepository(),
      initialLocation: AppRoutes.transactions,
      transactionRepository: transactionRepository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nháp'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thao tác giao dịch').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận nháp'));
    await tester.pumpAndSettle();
    expect(transactionRepository.confirmedId, 'tx-draft');

    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thao tác giao dịch').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa giao dịch'));
    await tester.pumpAndSettle();
    expect(transactionRepository.deletedId, isNotNull);
  });

  testWidgets('transactions scan and tag actions open reusable sheets', (
    tester,
  ) async {
    await pumpFlowFiApp(
      tester,
      authenticatedAuthRepository(),
      initialLocation: AppRoutes.transactions,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Quét hóa đơn'));
    await tester.pumpAndSettle();
    expect(find.text('Quét hóa đơn'), findsOneWidget);
    expect(find.text('Chụp ảnh'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Quản lý danh mục'));
    await tester.pumpAndSettle();
    expect(find.text('Quản lý danh mục'), findsOneWidget);
    expect(find.text('Add tag'), findsOneWidget);
  });

  testWidgets('empty transaction views use a Lottie-backed state', (
    tester,
  ) async {
    await pumpFlowFiApp(
      tester,
      authenticatedAuthRepository(),
      initialLocation: AppRoutes.transactions,
      transactionRepository: TestTransactionRepository(transactions: const []),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa có giao dịch'), findsOneWidget);
    expect(find.byType(Lottie), findsOneWidget);
  });
}
