import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/wallet.dart';

export '../../domain/entities/wallet.dart';

final class WalletModel {
  const WalletModel({
    required this.id,
    required this.name,
    required this.walletType,
    required this.balance,
    required this.isDefault,
  });

  final String id;
  final String name;
  final WalletType walletType;
  final String balance;
  final bool isDefault;

  factory WalletModel.fromJson(JsonMap json) {
    return WalletModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      walletType: walletTypeFromApi(json['walletType']),
      balance: json['balance']?.toString() ?? '0',
      isDefault: json['isDefault'] == true,
    );
  }

  Wallet toDomain() {
    return Wallet(
      id: id,
      name: name,
      type: walletType,
      balance: balance,
      isDefault: isDefault,
    );
  }
}
