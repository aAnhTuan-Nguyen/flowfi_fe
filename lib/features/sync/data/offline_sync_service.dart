// ignore_for_file: prefer_initializing_formals

import '../../../core/local/flowfi_local_store.dart';
import '../../../core/sync/network_status_service.dart';
import 'datasources/sync_remote_data_source.dart';

final class OfflineSyncService {
  const OfflineSyncService({
    required FlowFiLocalStore localStore,
    required SyncRemoteDataSource remoteDataSource,
    required NetworkStatusService networkStatus,
    required Future<String> Function() deviceIdProvider,
  }) : _localStore = localStore,
       _remoteDataSource = remoteDataSource,
       _networkStatus = networkStatus,
       _deviceIdProvider = deviceIdProvider;

  final FlowFiLocalStore _localStore;
  final SyncRemoteDataSource _remoteDataSource;
  final NetworkStatusService _networkStatus;
  final Future<String> Function() _deviceIdProvider;

  Future<OfflineSyncSummary> synchronize() async {
    if (!await _networkStatus.hasNetwork()) {
      return const OfflineSyncSummary(attemptedCount: 0, wasOnline: false);
    }
    final pending = await _localStore.readPendingOperations();
    if (pending.isEmpty) {
      return const OfflineSyncSummary(attemptedCount: 0);
    }
    final response = await _remoteDataSource.push(
      deviceId: await _deviceIdProvider(),
      items: pending,
    );
    final resultsByClientId = {
      for (final result in response.results)
        if (result.clientId != null) result.clientId!: result,
    };
    final syncedCreates = <SyncedTransactionCreate>[];
    final syncedOtherOperationIds = <int>[];
    var failedCount = 0;
    var conflictCount = 0;
    for (final operation in pending) {
      final result = resultsByClientId[operation.clientId];
      if (result == null) {
        failedCount += 1;
        continue;
      }
      if (result.status == SyncPushStatus.conflict) {
        conflictCount += 1;
        continue;
      }
      if (result.status == SyncPushStatus.failed) {
        failedCount += 1;
        continue;
      }
      if (operation.entityName == 'transactions' &&
          operation.action == PendingSyncAction.create &&
          result.entityId != null) {
        syncedCreates.add(
          SyncedTransactionCreate(
            localOperationId: operation.localId,
            clientId: operation.clientId,
            entityId: result.entityId!,
          ),
        );
      } else {
        syncedOtherOperationIds.add(operation.localId);
      }
    }
    await _localStore.markTransactionCreatesSynced(syncedCreates);
    await _localStore.markOperationsSynced(syncedOtherOperationIds);
    return OfflineSyncSummary(
      attemptedCount: pending.length,
      syncedCount: syncedCreates.length + syncedOtherOperationIds.length,
      failedCount: failedCount,
      conflictCount: conflictCount,
    );
  }
}

final class OfflineSyncSummary {
  const OfflineSyncSummary({
    required this.attemptedCount,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.conflictCount = 0,
    this.wasOnline = true,
  });

  final int attemptedCount;
  final int syncedCount;
  final int failedCount;
  final int conflictCount;
  final bool wasOnline;

  bool get hasFailures => failedCount > 0 || conflictCount > 0;
}
