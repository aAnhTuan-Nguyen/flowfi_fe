import 'package:flowfi_fe/features/wallets/data/models/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps wallet json into a domain wallet without using double money', () {
    final model = WalletModel.fromJson({
      'id': 'wallet-1',
      'name': 'Cash',
      'walletType': 'Cash',
      'balance': '125000.50',
      'isDefault': true,
    });

    final wallet = model.toDomain();

    expect(wallet.id, 'wallet-1');
    expect(wallet.name, 'Cash');
    expect(wallet.type, WalletType.cash);
    expect(wallet.balance, '125000.50');
    expect(wallet.isDefault, isTrue);
  });

  test('keeps unknown wallet types explicit', () {
    final model = WalletModel.fromJson({
      'id': 'wallet-1',
      'name': 'Other',
      'walletType': 'Crypto',
      'balance': '0',
      'isDefault': false,
    });

    expect(model.toDomain().type, WalletType.unknown);
  });
}
