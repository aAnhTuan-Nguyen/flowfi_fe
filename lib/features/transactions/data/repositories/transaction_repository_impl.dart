import '../../../../core/finance/money_flow_type.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';

final class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._remoteDataSource);

  final TransactionRemoteDataSource _remoteDataSource;

  @override
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
  }) async {
    final models = await _remoteDataSource.listTransactions(
      page: page,
      limit: limit,
      walletId: walletId,
      tagId: tagId,
      transactionType: transactionType,
      status: status,
      inputMethod: inputMethod,
      keyword: keyword,
      from: from,
      to: to,
    );
    return models.map((model) => model.toDomain()).toList(growable: false);
  }

  @override
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
  }) async {
    return (await _remoteDataSource.createTransaction(
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
    )).toDomain();
  }

  @override
  Future<Transaction> updateTransaction(
    String id, {
    String? walletId,
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    TransactionStatus? status,
    TransactionInputMethod? inputMethod,
    String? merchantName,
    String? description,
    String? clientId,
  }) async {
    return (await _remoteDataSource.updateTransaction(
      id,
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
    )).toDomain();
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _remoteDataSource.deleteTransaction(id);
  }

  @override
  Future<Transaction> confirmTransaction(String id) async {
    return (await _remoteDataSource.confirmTransaction(id)).toDomain();
  }
}
