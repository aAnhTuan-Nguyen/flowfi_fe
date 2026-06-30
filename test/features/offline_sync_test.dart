import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/core/local/flowfi_database.dart';
import 'package:flowfi_fe/core/local/flowfi_local_store.dart';
import 'package:flowfi_fe/core/sync/network_status_service.dart';
import 'package:flowfi_fe/features/sync/data/datasources/sync_remote_data_source.dart';
import 'package:flowfi_fe/features/sync/data/offline_sync_service.dart';
import 'package:flowfi_fe/features/tags/domain/entities/tag.dart';
import 'package:flowfi_fe/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:flowfi_fe/features/transactions/data/models/transaction_model.dart';
import 'package:flowfi_fe/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:flowfi_fe/features/transactions/domain/entities/transaction.dart';
import 'package:flowfi_fe/features/wallets/domain/entities/wallet.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FlowFiDatabase database;
  late FlowFiLocalStore store;

  setUp(() {
    database = FlowFiDatabase.inMemory();
    store = FlowFiLocalStore(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('lists cached transactions when offline', () async {
    await store.cacheTransactions([
      Transaction(
        id: 'tx-cache',
        walletId: 'wallet-1',
        tagId: 'tag-1',
        title: 'Cached coffee',
        amount: '50000',
        type: MoneyFlowType.expense,
        date: DateTime(2026, 6, 30),
        status: TransactionStatus.confirmed,
        inputMethod: TransactionInputMethod.manual,
      ),
    ]);
    final repository = TransactionRepositoryImpl(
      _FailingTransactionRemoteDataSource(),
      localStore: store,
      networkStatus: _FixedNetworkStatus(isOnline: false),
    );

    final transactions = await repository.listTransactions();

    expect(transactions, hasLength(1));
    expect(transactions.single.title, 'Cached coffee');
  });

  test(
    'creates a pending manual transaction offline and updates local balance',
    () async {
      await store.cacheWallets([
        const Wallet(
          id: 'wallet-1',
          name: 'Cash',
          type: WalletType.cash,
          balance: '500000',
          isDefault: true,
        ),
      ]);
      await store.cacheTags([
        const Tag(
          id: 'tag-1',
          name: 'Food',
          type: MoneyFlowType.expense,
          isDefault: false,
        ),
      ]);
      final repository = TransactionRepositoryImpl(
        _FailingTransactionRemoteDataSource(),
        localStore: store,
        networkStatus: _FixedNetworkStatus(isOnline: false),
        clientIdFactory: () => 'client-tx-1',
      );

      final transaction = await repository.createTransaction(
        walletId: 'wallet-1',
        tagId: 'tag-1',
        title: 'Offline coffee',
        amount: '50000',
        type: MoneyFlowType.expense,
        date: DateTime(2026, 6, 30),
        status: TransactionStatus.confirmed,
        inputMethod: TransactionInputMethod.manual,
      );

      final wallets = await store.readWallets();
      final pending = await store.readPendingOperations();

      expect(transaction.id, 'client-tx-1');
      expect(transaction.isPendingSync, isTrue);
      expect(wallets.single.balance, '450000');
      expect(pending, hasLength(1));
      expect(pending.single.entityName, 'transactions');
      expect(pending.single.clientId, 'client-tx-1');
      expect(pending.single.payload['status'], 'Confirmed');
      expect(pending.single.payload['inputMethod'], 'Manual');
    },
  );

  test(
    'sync pushes pending operations and clears them after success',
    () async {
      await store.cacheWallets([
        const Wallet(
          id: 'wallet-1',
          name: 'Cash',
          type: WalletType.cash,
          balance: '500000',
          isDefault: true,
        ),
      ]);
      await store.createPendingManualTransaction(
        clientId: 'client-tx-1',
        walletId: 'wallet-1',
        tagId: 'tag-1',
        title: 'Offline coffee',
        amount: '50000',
        type: MoneyFlowType.expense,
        date: DateTime(2026, 6, 30),
      );
      final remote = _FakeSyncRemoteDataSource();
      final service = OfflineSyncService(
        localStore: store,
        remoteDataSource: remote,
        networkStatus: _FixedNetworkStatus(isOnline: true),
        deviceIdProvider: () async => 'device-1',
      );

      await service.synchronize();

      expect(remote.pushedDeviceId, 'device-1');
      expect(remote.pushedItems.single.clientId, 'client-tx-1');
      expect(await store.readPendingOperations(), isEmpty);
    },
  );

  test('sync maps a pending local transaction to the server id', () async {
    await store.cacheWallets([
      const Wallet(
        id: 'wallet-1',
        name: 'Cash',
        type: WalletType.cash,
        balance: '500000',
        isDefault: true,
      ),
    ]);
    await store.createPendingManualTransaction(
      clientId: 'client-tx-1',
      walletId: 'wallet-1',
      tagId: 'tag-1',
      title: 'Offline coffee',
      amount: '50000',
      type: MoneyFlowType.expense,
      date: DateTime(2026, 6, 30),
    );
    final service = OfflineSyncService(
      localStore: store,
      remoteDataSource: _FakeSyncRemoteDataSource(),
      networkStatus: _FixedNetworkStatus(isOnline: true),
      deviceIdProvider: () async => 'device-1',
    );

    await service.synchronize();

    final transactions = await store.readTransactions();
    expect(await store.readPendingOperations(), isEmpty);
    expect(transactions, hasLength(1));
    expect(transactions.single.id, 'server-client-tx-1');
    expect(transactions.single.clientId, 'client-tx-1');
    expect(transactions.single.isPendingSync, isFalse);
  });

  test(
    'remote refresh after sync does not duplicate a reconciled transaction',
    () async {
      await store.cacheWallets([
        const Wallet(
          id: 'wallet-1',
          name: 'Cash',
          type: WalletType.cash,
          balance: '500000',
          isDefault: true,
        ),
      ]);
      await store.createPendingManualTransaction(
        clientId: 'client-tx-1',
        walletId: 'wallet-1',
        tagId: 'tag-1',
        title: 'Offline coffee',
        amount: '50000',
        type: MoneyFlowType.expense,
        date: DateTime(2026, 6, 30),
      );
      final service = OfflineSyncService(
        localStore: store,
        remoteDataSource: _FakeSyncRemoteDataSource(),
        networkStatus: _FixedNetworkStatus(isOnline: true),
        deviceIdProvider: () async => 'device-1',
      );

      await service.synchronize();
      await store.cacheTransactions([
        Transaction(
          id: 'server-client-tx-1',
          clientId: 'client-tx-1',
          walletId: 'wallet-1',
          tagId: 'tag-1',
          title: 'Offline coffee',
          amount: '50000',
          type: MoneyFlowType.expense,
          date: DateTime(2026, 6, 30),
          status: TransactionStatus.confirmed,
          inputMethod: TransactionInputMethod.manual,
        ),
      ]);

      final transactions = await store.readTransactions();
      expect(transactions, hasLength(1));
      expect(transactions.single.id, 'server-client-tx-1');
      expect(transactions.single.isPendingSync, isFalse);
    },
  );

  test(
    'does not create a pending transaction for a backend validation error',
    () async {
      await store.cacheWallets([
        const Wallet(
          id: 'wallet-1',
          name: 'Cash',
          type: WalletType.cash,
          balance: '500000',
          isDefault: true,
        ),
      ]);
      final repository = TransactionRepositoryImpl(
        _BackendValidationTransactionRemoteDataSource(),
        localStore: store,
        networkStatus: _FixedNetworkStatus(isOnline: true),
        clientIdFactory: () => 'client-tx-1',
      );

      await expectLater(
        repository.createTransaction(
          walletId: 'wallet-1',
          tagId: 'tag-1',
          title: 'Invalid coffee',
          amount: '50000',
          type: MoneyFlowType.expense,
          date: DateTime(2026, 6, 30),
          status: TransactionStatus.confirmed,
          inputMethod: TransactionInputMethod.manual,
        ),
        throwsA(isA<DioException>()),
      );

      expect(await store.readPendingOperations(), isEmpty);
      expect(await store.readTransactions(), isEmpty);
      expect((await store.readWallets()).single.balance, '500000');
    },
  );
}

final class _FixedNetworkStatus implements NetworkStatusService {
  const _FixedNetworkStatus({required this.isOnline});

  final bool isOnline;

  @override
  Future<bool> hasNetwork() async => isOnline;
}

final class _FailingTransactionRemoteDataSource
    implements TransactionRemoteDataSource {
  @override
  Future<List<TransactionModel>> listTransactions({
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
  }) {
    throw StateError('offline');
  }

  @override
  Future<TransactionModel> createTransaction({
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
  }) {
    throw StateError('offline');
  }

  @override
  Future<TransactionModel> updateTransaction(
    String id, {
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    String? merchantName,
    String? description,
  }) {
    throw StateError('offline');
  }

  @override
  Future<void> deleteTransaction(String id) {
    throw StateError('offline');
  }

  @override
  Future<TransactionModel> confirmTransaction(String id) {
    throw StateError('offline');
  }
}

final class _BackendValidationTransactionRemoteDataSource
    implements TransactionRemoteDataSource {
  DioException _error() {
    return DioException(
      requestOptions: RequestOptions(path: 'transactions'),
      response: Response<Object?>(
        requestOptions: RequestOptions(path: 'transactions'),
        statusCode: 400,
      ),
    );
  }

  @override
  Future<List<TransactionModel>> listTransactions({
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
  }) {
    throw _error();
  }

  @override
  Future<TransactionModel> createTransaction({
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
  }) {
    throw _error();
  }

  @override
  Future<TransactionModel> updateTransaction(
    String id, {
    String? tagId,
    String? title,
    String? amount,
    MoneyFlowType? type,
    DateTime? date,
    String? merchantName,
    String? description,
  }) {
    throw _error();
  }

  @override
  Future<void> deleteTransaction(String id) {
    throw _error();
  }

  @override
  Future<TransactionModel> confirmTransaction(String id) {
    throw _error();
  }
}

final class _FakeSyncRemoteDataSource implements SyncRemoteDataSource {
  String? pushedDeviceId;
  List<PendingSyncOperation> pushedItems = const [];

  @override
  Future<SyncPushResponse> push({
    required String deviceId,
    required List<PendingSyncOperation> items,
  }) async {
    pushedDeviceId = deviceId;
    pushedItems = items;
    return SyncPushResponse(
      results: [
        for (final item in items)
          SyncPushResult(
            entityName: item.entityName,
            clientId: item.clientId,
            entityId: 'server-${item.clientId}',
            status: SyncPushStatus.synced,
          ),
      ],
    );
  }
}
