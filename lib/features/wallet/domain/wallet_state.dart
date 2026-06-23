import 'package:equatable/equatable.dart';
import 'wallet_model.dart';

class WalletState extends Equatable {
  const WalletState({
    this.wallets = const [],
    this.totalAssets = 0.0,
    this.isLoading = false,
    this.error,
  });

  final List<WalletModel> wallets;
  final double totalAssets;
  final bool isLoading;
  final String? error;

  @override
  List<Object?> get props => [wallets, totalAssets, isLoading, error];
}
