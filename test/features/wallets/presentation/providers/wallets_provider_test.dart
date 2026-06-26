import 'package:flowfi_fe/features/wallets/domain/entities/wallet.dart';
import 'package:flowfi_fe/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:flowfi_fe/features/wallets/presentation/providers/wallets_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads wallets from repository', () async {
    final repository = FakeWalletRepository([
      const Wallet(
        id: 'wallet-1',
        name: 'Cash',
        type: WalletType.cash,
        balance: '125000',
        isDefault: true,
      ),
    ]);
    final container = _container(repository);

    final wallets = await container.read(walletsProvider.future);

    expect(wallets.single.name, 'Cash');
    expect(repository.listCalls, 1);
  });

  test('reload fetches wallets again', () async {
    final repository = FakeWalletRepository([]);
    final container = _container(repository);
    await container.read(walletsProvider.future);

    await container.read(walletsProvider.notifier).reload();

    expect(repository.listCalls, 2);
  });
}

ProviderContainer _container(WalletRepository repository) {
  final container = ProviderContainer(
    overrides: [walletRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository(this.wallets);

  final List<Wallet> wallets;
  int listCalls = 0;

  @override
  Future<List<Wallet>> listWallets({int page = 1, int limit = 20}) async {
    listCalls++;
    return wallets;
  }

  @override
  Future<Wallet> createWallet({
    required String name,
    required WalletType type,
    String? balance,
    String? clientId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteWallet(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Wallet> getWallet(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Wallet> setDefaultWallet(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Wallet> updateWallet(
    String id, {
    String? name,
    WalletType? type,
    String? balance,
    String? clientId,
  }) {
    throw UnimplementedError();
  }
}
