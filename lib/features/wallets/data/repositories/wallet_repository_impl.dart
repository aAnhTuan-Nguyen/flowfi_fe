// ignore_for_file: prefer_initializing_formals

import '../../../../core/local/flowfi_local_store.dart';
import '../../../../core/sync/network_status_service.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

final class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl(
    this._remoteDataSource, {
    FlowFiLocalStore? localStore,
    NetworkStatusService? networkStatus,
  }) : _localStore = localStore,
       _networkStatus = networkStatus;

  final WalletRemoteDataSource _remoteDataSource;
  final FlowFiLocalStore? _localStore;
  final NetworkStatusService? _networkStatus;

  @override
  Future<List<Wallet>> listWallets({int page = 1, int limit = 20}) async {
    if (!await _hasNetwork()) {
      return _localStore?.readWallets() ?? const [];
    }
    try {
      final models = await _remoteDataSource.listWallets(
        page: page,
        limit: limit,
      );
      final wallets = models
          .map((model) => model.toDomain())
          .toList(growable: false);
      await _localStore?.cacheWallets(wallets);
      return wallets;
    } catch (_) {
      final cached = await _localStore?.readWallets();
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<Wallet> getWallet(String id) async {
    return (await _remoteDataSource.getWallet(id)).toDomain();
  }

  @override
  Future<Wallet> createWallet({
    required String name,
    required WalletType type,
    String? balance,
    String? clientId,
  }) async {
    return (await _remoteDataSource.createWallet(
      name: name,
      type: type,
      balance: balance,
      clientId: clientId,
    )).toDomain();
  }

  @override
  Future<Wallet> updateWallet(
    String id, {
    String? name,
    WalletType? type,
    String? balance,
    String? clientId,
  }) async {
    return (await _remoteDataSource.updateWallet(
      id,
      name: name,
      type: type,
      balance: balance,
      clientId: clientId,
    )).toDomain();
  }

  @override
  Future<void> deleteWallet(String id) {
    return _remoteDataSource.deleteWallet(id);
  }

  @override
  Future<Wallet> setDefaultWallet(String id) async {
    return (await _remoteDataSource.setDefaultWallet(id)).toDomain();
  }

  Future<bool> _hasNetwork() async {
    return await _networkStatus?.hasNetwork() ?? true;
  }
}
