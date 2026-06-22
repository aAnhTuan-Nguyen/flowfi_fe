import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/placeholder_tab_screen.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderTabScreen(
      icon: Icons.savings_rounded,
      title: 'Budgets',
      message: 'Budget limits and goals will live here.',
    );
  }
}
