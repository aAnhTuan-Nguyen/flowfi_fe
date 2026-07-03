import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/core/local/flowfi_database.dart';
import 'package:flowfi_fe/core/local/flowfi_local_store.dart';
import 'package:flowfi_fe/core/sync/network_status_service.dart';
import 'package:flowfi_fe/di/injection.dart';
import 'package:flowfi_fe/features/sync/data/datasources/sync_remote_data_source.dart';
import 'package:flowfi_fe/features/sync/data/offline_sync_service.dart';
import 'package:flowfi_fe/features/sync/sync_failure.dart';
import 'package:flowfi_fe/features/sync/sync_status_provider.dart';
import 'package:flowfi_fe/features/wallets/domain/entities/wallet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FlowFiDatabase database;
  late FlowFiLocalStore store;
  late _MutableNetworkStatus networkStatus;
  late _FakeSyncRemoteDataSource remoteDataSource;

  setUp(() async {
    await serviceLocator.reset();
    database = FlowFiDatabase.inMemory();
    store = FlowFiLocalStore(database);
    networkStatus = _MutableNetworkStatus(isOnline: false);
    remoteDataSource = _FakeSyncRemoteDataSource();

    serviceLocator.registerSingleton<FlowFiLocalStore>(store);
    serviceLocator.registerSingleton<NetworkStatusService>(networkStatus);
    serviceLocator.registerSingleton<OfflineSyncService>(
      OfflineSyncService(
        localStore: store,
        remoteDataSource: remoteDataSource,
        networkStatus: networkStatus,
        deviceIdProvider: () async => 'device-1',
      ),
    );
  });

  tearDown(() async {
    await networkStatus.dispose();
    await database.close();
    await serviceLocator.reset();
  });

  test('auto-syncs pending operations when connectivity returns', () async {
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
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = await container.read(syncStatusProvider.future);
    expect(initial.isOnline, isFalse);
    expect(initial.pendingCount, 1);

    networkStatus.setOnline(true);
    await _pumpEventQueue();

    expect(remoteDataSource.pushCount, 1);
    expect(await store.readPendingOperations(), isEmpty);
    expect(container.read(syncStatusProvider).value?.pendingCount, 0);
    expect(container.read(syncStatusProvider).value?.error, isNull);
  });

  test(
    'keeps pending operations and exposes an error when sync fails',
    () async {
      networkStatus.setOnline(true);
      remoteDataSource.failure = DioException(
        requestOptions: RequestOptions(path: 'sync/push'),
        response: Response<Object?>(
          requestOptions: RequestOptions(path: 'sync/push'),
          statusCode: 404,
          data: {
            'success': false,
            'error': {'code': 'NOT_FOUND', 'message': 'Wallet not found'},
            'meta': {'requestId': 'req-sync-1'},
          },
        ),
      );
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
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = await container.read(syncStatusProvider.future);
      expect(initial.isOnline, isTrue);
      expect(initial.pendingCount, 1);

      await _pumpEventQueue();

      final status = container.read(syncStatusProvider).value;
      expect(remoteDataSource.pushCount, 1);
      expect(await store.readPendingOperations(), hasLength(1));
      expect(status?.pendingCount, 1);
      expect(status?.isSynchronizing, isFalse);
      final failure = status?.error;
      expect(failure, isA<SyncFailure>());
      expect(failure?.kind, SyncFailureKind.staleReference);
      expect(failure?.statusCode, 404);
      expect(failure?.code, 'NOT_FOUND');
      expect(failure?.requestId, 'req-sync-1');
      expect(
        failure?.message,
        'Một thao tác chờ dùng ví hoặc danh mục không còn hợp lệ.',
      );
    },
  );

  test('auto-syncs pending operations when provider starts online', () async {
    networkStatus.setOnline(true);
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
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = await container.read(syncStatusProvider.future);
    expect(initial.isOnline, isTrue);
    expect(initial.pendingCount, 1);

    await _pumpEventQueue();

    final status = container.read(syncStatusProvider).value;
    expect(remoteDataSource.pushCount, 1);
    expect(await store.readPendingOperations(), isEmpty);
    expect(status?.pendingCount, 0);
    expect(status?.lastSyncedCount, 1);
    expect(status?.error, isNull);
  });

  test(
    'auto-syncs newly queued operations after provider invalidation',
    () async {
      networkStatus.setOnline(true);
      await store.cacheWallets([
        const Wallet(
          id: 'wallet-1',
          name: 'Cash',
          type: WalletType.cash,
          balance: '500000',
          isDefault: true,
        ),
      ]);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = await container.read(syncStatusProvider.future);
      expect(initial.pendingCount, 0);

      await store.createPendingManualTransaction(
        clientId: 'client-tx-1',
        walletId: 'wallet-1',
        tagId: 'tag-1',
        title: 'Offline coffee',
        amount: '50000',
        type: MoneyFlowType.expense,
        date: DateTime(2026, 6, 30),
      );
      container.invalidate(syncStatusProvider);

      await container.read(syncStatusProvider.future);

      await _pumpEventQueue();

      expect(remoteDataSource.pushCount, 1);
      expect(await store.readPendingOperations(), isEmpty);
      expect(container.read(syncStatusProvider).value?.pendingCount, 0);
    },
  );

  test(
    'keeps pending operations and exposes a failure for partial sync results',
    () async {
      networkStatus.setOnline(true);
      remoteDataSource.status = SyncPushStatus.conflict;
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
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(syncStatusProvider.future);
      await _pumpEventQueue();

      final status = container.read(syncStatusProvider).value;
      expect(remoteDataSource.pushCount, 1);
      expect(await store.readPendingOperations(), hasLength(1));
      expect(status?.error, isA<SyncFailure>());
      expect(status?.error?.kind, SyncFailureKind.conflict);
      expect(status?.pendingCount, 1);
    },
  );
}

Future<void> _pumpEventQueue() async {
  for (var index = 0; index < 6; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}

final class _MutableNetworkStatus implements NetworkStatusService {
  _MutableNetworkStatus({required this.isOnline});

  bool isOnline;
  final _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> hasNetwork() async => isOnline;

  @override
  Stream<bool> get onlineChanges => _controller.stream;

  void setOnline(bool value) {
    isOnline = value;
    _controller.add(value);
  }

  Future<void> dispose() => _controller.close();
}

final class _FakeSyncRemoteDataSource implements SyncRemoteDataSource {
  int pushCount = 0;
  Object? failure;
  SyncPushStatus status = SyncPushStatus.synced;

  @override
  Future<SyncPushResponse> push({
    required String deviceId,
    required List<PendingSyncOperation> items,
  }) async {
    pushCount += 1;
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    return SyncPushResponse(
      results: [
        for (final item in items)
          SyncPushResult(
            entityName: item.entityName,
            clientId: item.clientId,
            entityId: 'server-${item.clientId}',
            status: status,
          ),
      ],
    );
  }
}
