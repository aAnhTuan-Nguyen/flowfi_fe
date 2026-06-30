import '../../../../core/finance/money_flow_type.dart';
import '../entities/transaction.dart';

abstract interface class TransactionRepository {
  Future<List<Transaction>> listTransactions({
    int page = 1,
    int limit = 20,
    String? walletId,
    String? tagId,
    MoneyFlowType? transactionType,
    TransactionStatus? status,
    TransactionInputMethod? inputMethod,
    String? keyword,
    String? from,
    String? to,
  });

  Future<Transaction> createTransaction({
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
  });

  Future<Transaction> updateTransaction(
    String id, {
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    String? merchantName,
    String? description,
  });

  Future<void> deleteTransaction(String id);

  Future<Transaction> confirmTransaction(String id);
}
