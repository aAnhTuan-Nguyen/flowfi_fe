import '../entities/wallet.dart';

abstract interface class WalletRepository {
  Future<List<Wallet>> listWallets({int page = 1, int limit = 20});

  Future<Wallet> getWallet(String id);

  Future<Wallet> createWallet({
    required String name,
    required WalletType type,
    String? balance,
    String? clientId,
  });

  Future<Wallet> updateWallet(
    String id, {
    String? name,
    WalletType? type,
    String? balance,
    String? clientId,
  });

  Future<void> deleteWallet(String id);

  Future<Wallet> setDefaultWallet(String id);
}
