import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => serviceLocator<TransactionRepository>(),
);

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() {
    return ref.watch(transactionRepositoryProvider).listTransactions();
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> createTransaction({
    required String walletId,
    required String tagId,
    required String title,
    required String amount,
    required MoneyFlowType type,
    required DateTime date,
    TransactionStatus status = TransactionStatus.draft,
    TransactionInputMethod inputMethod = TransactionInputMethod.manual,
    String? merchantName,
    String? description,
    String? clientId,
  }) async {
    await ref
        .read(transactionRepositoryProvider)
        .createTransaction(
          walletId: walletId,
          tagId: tagId,
          title: title,
          amount: amount,
          type: type,
          date: date,
          status: status,
          inputMethod: inputMethod,
          merchantName: merchantName,
          description: description,
          clientId: clientId,
        );
    await reload();
  }

  Future<void> updateTransaction(
    String id, {
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    String? merchantName,
    String? description,
  }) async {
    await ref
        .read(transactionRepositoryProvider)
        .updateTransaction(
          id,
          tagId: tagId,
          title: title,
          amount: amount,
          type: type,
          date: date,
          merchantName: merchantName,
          description: description,
        );
    await reload();
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
    await reload();
  }

  Future<void> confirmTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).confirmTransaction(id);
    await reload();
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
      TransactionsNotifier.new,
    );
