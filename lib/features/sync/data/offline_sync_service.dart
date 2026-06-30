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

  Future<void> synchronize() async {
    if (!await _networkStatus.hasNetwork()) {
      return;
    }
    final pending = await _localStore.readPendingOperations();
    if (pending.isEmpty) {
      return;
    }
    final response = await _remoteDataSource.push(
      deviceId: await _deviceIdProvider(),
      items: pending,
    );
    final syncedResults = {
      for (final result in response.results)
        if (result.status == SyncPushStatus.synced && result.clientId != null)
          result.clientId!: result,
    };
    final syncedCreates = <SyncedTransactionCreate>[];
    final syncedOtherOperationIds = <int>[];
    for (final operation in pending) {
      final result = syncedResults[operation.clientId];
      if (result == null) {
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
  }
}
