import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/transactions/domain/entities/transaction.dart';
import 'package:flowfi_fe/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/flowfi_test_helpers.dart';

void main() {
  test('creating a transaction invalidates the monthly summary', () async {
    final repository = TestTransactionRepository(transactions: []);
    final container = ProviderContainer(
      overrides: [transactionRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final month = DateTime(2026, 7, 25);

    final before = await container.read(
      monthlyTransactionSummaryProvider(month).future,
    );
    expect(before.totalExpense, '0');

    await container.read(transactionsProvider.future);
    await container
        .read(transactionsProvider.notifier)
        .createTransaction(
          walletId: 'wallet-1',
          tagId: 'tag-1',
          title: 'Lunch',
          amount: '50000',
          type: MoneyFlowType.expense,
          date: month,
          status: TransactionStatus.confirmed,
        );

    final after = await container.read(
      monthlyTransactionSummaryProvider(month).future,
    );
    expect(after.totalExpense, '50000');
  });
}
