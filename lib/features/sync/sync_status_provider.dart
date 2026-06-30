import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/local/flowfi_local_store.dart';
import '../../core/sync/network_status_service.dart';
import '../../di/injection.dart';
import '../transactions/presentation/providers/transactions_provider.dart';
import '../wallets/presentation/providers/wallets_provider.dart';
import 'data/offline_sync_service.dart';

final class SyncStatusState {
  const SyncStatusState({
    required this.isOnline,
    required this.pendingCount,
    this.error,
  });

  final bool isOnline;
  final int pendingCount;
  final Object? error;
}

class SyncStatusNotifier extends AsyncNotifier<SyncStatusState> {
  @override
  Future<SyncStatusState> build() async {
    if (!serviceLocator.isRegistered<NetworkStatusService>() ||
        !serviceLocator.isRegistered<FlowFiLocalStore>()) {
      return const SyncStatusState(isOnline: true, pendingCount: 0);
    }
    final networkStatus = serviceLocator<NetworkStatusService>();
    final localStore = serviceLocator<FlowFiLocalStore>();
    return SyncStatusState(
      isOnline: await networkStatus.hasNetwork(),
      pendingCount: await localStore.countPendingOperations(),
    );
  }

  Future<void> synchronize() async {
    if (!serviceLocator.isRegistered<OfflineSyncService>()) {
      return;
    }
    final previous = state.value;
    state = const AsyncLoading();
    try {
      await serviceLocator<OfflineSyncService>().synchronize();
      ref.invalidate(transactionsProvider);
      ref.invalidate(walletsProvider);
      ref.invalidateSelf();
      await future;
    } catch (error) {
      state = AsyncData(
        SyncStatusState(
          isOnline: previous?.isOnline ?? true,
          pendingCount: previous?.pendingCount ?? 0,
          error: error,
        ),
      );
    }
  }
}

final syncStatusProvider =
    AsyncNotifierProvider<SyncStatusNotifier, SyncStatusState>(
      SyncStatusNotifier.new,
    );
