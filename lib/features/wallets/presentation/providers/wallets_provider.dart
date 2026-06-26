import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => serviceLocator<WalletRepository>(),
);

class WalletsNotifier extends AsyncNotifier<List<Wallet>> {
  @override
  Future<List<Wallet>> build() {
    return ref.watch(walletRepositoryProvider).listWallets();
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> createWallet({
    required String name,
    required WalletType type,
    String? balance,
    String? clientId,
  }) async {
    await ref
        .read(walletRepositoryProvider)
        .createWallet(
          name: name,
          type: type,
          balance: balance,
          clientId: clientId,
        );
    await reload();
  }

  Future<void> updateWallet(
    String id, {
    String? name,
    WalletType? type,
    String? balance,
    String? clientId,
  }) async {
    await ref
        .read(walletRepositoryProvider)
        .updateWallet(
          id,
          name: name,
          type: type,
          balance: balance,
          clientId: clientId,
        );
    await reload();
  }

  Future<void> deleteWallet(String id) async {
    await ref.read(walletRepositoryProvider).deleteWallet(id);
    await reload();
  }

  Future<void> setDefaultWallet(String id) async {
    await ref.read(walletRepositoryProvider).setDefaultWallet(id);
    await reload();
  }
}

final walletsProvider = AsyncNotifierProvider<WalletsNotifier, List<Wallet>>(
  WalletsNotifier.new,
);
