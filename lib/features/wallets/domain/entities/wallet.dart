enum WalletType { cash, bank, eWallet, unknown }

final class Wallet {
  const Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.isDefault,
  });

  final String id;
  final String name;
  final WalletType type;
  final String balance;
  final bool isDefault;
}

extension WalletTypeApi on WalletType {
  String get apiValue {
    return switch (this) {
      WalletType.cash => 'Cash',
      WalletType.bank => 'Bank',
      WalletType.eWallet => 'EWallet',
      WalletType.unknown => 'Unknown',
    };
  }
}

WalletType walletTypeFromApi(Object? value) {
  return switch (value) {
    'Cash' => WalletType.cash,
    'Bank' => WalletType.bank,
    'EWallet' => WalletType.eWallet,
    _ => WalletType.unknown,
  };
}
