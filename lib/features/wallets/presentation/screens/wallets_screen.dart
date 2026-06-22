import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/placeholder_tab_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderTabScreen(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Wallets',
      message: 'Wallet balances and transfers will live here.',
    );
  }
}
