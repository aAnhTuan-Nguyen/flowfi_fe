// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../../core/local/flowfi_local_store.dart';
import '../../../../core/sync/network_status_service.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';

final class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(
    this._remoteDataSource, {
    FlowFiLocalStore? localStore,
    NetworkStatusService? networkStatus,
    String Function()? clientIdFactory,
  }) : _localStore = localStore,
       _networkStatus = networkStatus,
       _clientIdFactory = clientIdFactory ?? (() => const Uuid().v4());

  final TransactionRemoteDataSource _remoteDataSource;
  final FlowFiLocalStore? _localStore;
  final NetworkStatusService? _networkStatus;
  final String Function() _clientIdFactory;

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
    if (!await _hasNetwork()) {
      return _filterCached(
        await _localStore?.readTransactions() ?? const [],
        walletId: walletId,
        tagId: tagId,
        transactionType: transactionType,
        status: status,
        inputMethod: inputMethod,
        keyword: keyword,
      );
    }
    try {
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
      final transactions = models
          .map((model) => model.toDomain())
          .toList(growable: false);
      await _localStore?.cacheTransactions(transactions);
      return transactions;
    } catch (_) {
      final cached = await _localStore?.readTransactions();
      if (cached != null) {
        return _filterCached(
          cached,
          walletId: walletId,
          tagId: tagId,
          transactionType: transactionType,
          status: status,
          inputMethod: inputMethod,
          keyword: keyword,
        );
      }
      rethrow;
    }
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
    if (_canCreateOffline(status, inputMethod) && !await _hasNetwork()) {
      return _createPendingManualTransaction(
        walletId: walletId,
        tagId: tagId,
        title: title,
        amount: amount,
        type: type,
        date: date,
        merchantName: merchantName,
        description: description,
        clientId: clientId,
      );
    }
    try {
      final transaction = (await _remoteDataSource.createTransaction(
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
      await _localStore?.cacheTransactions([transaction]);
      return transaction;
    } on DioException catch (error) {
      if (_canCreateOffline(status, inputMethod) &&
          _isRetryableOfflineError(error)) {
        return _createPendingManualTransaction(
          walletId: walletId,
          tagId: tagId,
          title: title,
          amount: amount,
          type: type,
          date: date,
          merchantName: merchantName,
          description: description,
          clientId: clientId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Transaction> updateTransaction(
    String id, {
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    String? merchantName,
    String? description,
  }) async {
    return (await _remoteDataSource.updateTransaction(
      id,
      tagId: tagId,
      title: title,
      amount: amount,
      type: type,
      date: date,
      merchantName: merchantName,
      description: description,
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

  Future<bool> _hasNetwork() async {
    return await _networkStatus?.hasNetwork() ?? true;
  }

  bool _canCreateOffline(
    TransactionStatus status,
    TransactionInputMethod inputMethod,
  ) {
    return _localStore != null &&
        status == TransactionStatus.confirmed &&
        inputMethod == TransactionInputMethod.manual;
  }

  Future<Transaction> _createPendingManualTransaction({
    required String walletId,
    required String tagId,
    required String title,
    required String amount,
    required MoneyFlowType type,
    required DateTime date,
    String? merchantName,
    String? description,
    String? clientId,
  }) {
    return _localStore!.createPendingManualTransaction(
      clientId: clientId ?? _clientIdFactory(),
      walletId: walletId,
      tagId: tagId,
      title: title,
      amount: amount,
      type: type,
      date: date,
      merchantName: merchantName,
      description: description,
    );
  }

  bool _isRetryableOfflineError(DioException error) {
    return error.response == null;
  }
}

List<Transaction> _filterCached(
  List<Transaction> transactions, {
  String? walletId,
  String? tagId,
  MoneyFlowType? transactionType,
  TransactionStatus? status,
  TransactionInputMethod? inputMethod,
  String? keyword,
}) {
  final normalizedKeyword = keyword?.trim().toLowerCase();
  return transactions
      .where((transaction) {
        if (walletId != null && transaction.walletId != walletId) return false;
        if (tagId != null && transaction.tagId != tagId) return false;
        if (transactionType != null &&
            transactionType != MoneyFlowType.unknown &&
            transaction.type != transactionType) {
          return false;
        }
        if (status != null &&
            status != TransactionStatus.unknown &&
            transaction.status != status) {
          return false;
        }
        if (inputMethod != null &&
            inputMethod != TransactionInputMethod.unknown &&
            transaction.inputMethod != inputMethod) {
          return false;
        }
        if (normalizedKeyword != null && normalizedKeyword.isNotEmpty) {
          return transaction.title.toLowerCase().contains(normalizedKeyword) ||
              (transaction.description ?? '').toLowerCase().contains(
                normalizedKeyword,
              ) ||
              (transaction.merchantName ?? '').toLowerCase().contains(
                normalizedKeyword,
              );
        }
        return true;
      })
      .toList(growable: false);
}
