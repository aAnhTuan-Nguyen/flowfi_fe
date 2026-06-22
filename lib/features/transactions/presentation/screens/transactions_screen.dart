import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/placeholder_tab_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderTabScreen(
      icon: Icons.receipt_long_rounded,
      title: 'Transactions',
      message: 'Transaction history will live here.',
    );
  }
}
