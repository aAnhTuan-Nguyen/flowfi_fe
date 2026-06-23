import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  const WalletModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.walletType,
    required this.balance,
    required this.currency,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String walletType; // e.g. "cash", "bank", "savings", "investment"
  final double balance;
  final String currency; // e.g. "VND", "USD"
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      walletType: json['walletType'] as String? ?? 'cash',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'VND',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'walletType': walletType,
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props =>
      [id, userId, name, walletType, balance, currency, isActive];
}
