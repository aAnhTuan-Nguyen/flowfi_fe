import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/local/flowfi_local_store.dart';
import '../../core/sync/network_status_service.dart';
import '../../di/injection.dart';
import '../budgets/presentation/providers/budgets_provider.dart';
import '../goals/presentation/providers/goals_provider.dart';
import '../notifications/presentation/providers/notifications_provider.dart';
import '../tags/presentation/providers/tags_provider.dart';
import '../transactions/presentation/providers/transactions_provider.dart';
import '../wallets/presentation/providers/wallets_provider.dart';
import 'data/offline_sync_service.dart';
import 'sync_failure.dart';

final class SyncStatusState {
  const SyncStatusState({
    required this.isOnline,
    required this.pendingCount,
    this.isSynchronizing = false,
    this.error,
    this.lastSyncedCount = 0,
  });

  final bool isOnline;
  final int pendingCount;
  final bool isSynchronizing;
  final SyncFailure? error;
  final int lastSyncedCount;
}

class SyncStatusNotifier extends AsyncNotifier<SyncStatusState> {
  StreamSubscription<bool>? _networkSubscription;
  bool _autoSyncScheduled = false;
  bool _disposed = false;
  bool _syncInFlight = false;

  @override
  Future<SyncStatusState> build() async {
    _disposed = false;
    _listenForConnectivity();
    final status = await _readStatus();
    _scheduleAutoSync(status);
    return status;
  }

  Future<void> synchronize() async {
    if (!serviceLocator.isRegistered<OfflineSyncService>()) {
      state = AsyncData(await _readStatus());
      return;
    }
    if (_syncInFlight) {
      return;
    }
    _syncInFlight = true;
    state = AsyncData(await _readStatus(isSynchronizing: true));
    try {
      final summary = await serviceLocator<OfflineSyncService>().synchronize();
      if (summary.syncedCount > 0) {
        _invalidateSyncedProviders();
      }
      if (summary.hasFailures) {
        state = AsyncData(
          await _readStatus(error: SyncFailure.fromSummary(summary)),
        );
        return;
      }
      state = AsyncData(
        await _readStatus(lastSyncedCount: summary.syncedCount),
      );
    } catch (error) {
      state = AsyncData(await _readStatus(error: SyncFailure.fromError(error)));
    } finally {
      _syncInFlight = false;
    }
  }

  void _listenForConnectivity() {
    if (!serviceLocator.isRegistered<NetworkStatusService>()) {
      return;
    }
    _networkSubscription?.cancel();
    _networkSubscription = serviceLocator<NetworkStatusService>().onlineChanges
        .listen((isOnline) => unawaited(_handleConnectivityChange(isOnline)));
    ref.onDispose(() {
      _disposed = true;
      unawaited(_networkSubscription?.cancel());
      _networkSubscription = null;
    });
  }

  Future<void> _handleConnectivityChange(bool isOnline) async {
    if (!serviceLocator.isRegistered<FlowFiLocalStore>()) {
      state = AsyncData(SyncStatusState(isOnline: isOnline, pendingCount: 0));
      return;
    }
    final pendingCount = await serviceLocator<FlowFiLocalStore>()
        .countPendingOperations();
    if (!isOnline) {
      state = AsyncData(
        SyncStatusState(isOnline: false, pendingCount: pendingCount),
      );
      return;
    }
    if (pendingCount > 0) {
      await synchronize();
      return;
    }
    state = const AsyncData(SyncStatusState(isOnline: true, pendingCount: 0));
  }

  Future<SyncStatusState> _readStatus({
    bool isSynchronizing = false,
    SyncFailure? error,
    int lastSyncedCount = 0,
  }) async {
    if (!serviceLocator.isRegistered<NetworkStatusService>() ||
        !serviceLocator.isRegistered<FlowFiLocalStore>()) {
      return SyncStatusState(
        isOnline: true,
        pendingCount: 0,
        isSynchronizing: isSynchronizing,
        error: error,
        lastSyncedCount: lastSyncedCount,
      );
    }
    final networkStatus = serviceLocator<NetworkStatusService>();
    final localStore = serviceLocator<FlowFiLocalStore>();
    return SyncStatusState(
      isOnline: await networkStatus.hasNetwork(),
      pendingCount: await localStore.countPendingOperations(),
      isSynchronizing: isSynchronizing,
      error: error,
      lastSyncedCount: lastSyncedCount,
    );
  }

  void _scheduleAutoSync(SyncStatusState status) {
    if (!status.isOnline ||
        status.pendingCount == 0 ||
        status.isSynchronizing ||
        _syncInFlight ||
        _autoSyncScheduled) {
      return;
    }
    _autoSyncScheduled = true;
    unawaited(
      Future<void>(() async {
        _autoSyncScheduled = false;
        if (_disposed) {
          return;
        }
        final latest = await _readStatus();
        if (latest.isOnline && latest.pendingCount > 0 && !_syncInFlight) {
          await synchronize();
        }
      }),
    );
  }

  void _invalidateSyncedProviders() {
    ref.invalidate(transactionsProvider);
    ref.invalidate(walletsProvider);
    ref.invalidate(budgetsProvider);
    ref.invalidate(goalsProvider);
    ref.invalidate(tagsProvider);
    ref.invalidate(notificationsProvider);
  }
}

final syncStatusProvider =
    AsyncNotifierProvider<SyncStatusNotifier, SyncStatusState>(
      SyncStatusNotifier.new,
    );
