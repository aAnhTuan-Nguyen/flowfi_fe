import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

final class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl(this._remoteDataSource);

  final WalletRemoteDataSource _remoteDataSource;

  @override
  Future<List<Wallet>> listWallets({int page = 1, int limit = 20}) async {
    final models = await _remoteDataSource.listWallets(
      page: page,
      limit: limit,
    );
    return models.map((model) => model.toDomain()).toList(growable: false);
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
}
