import 'package:flutter/material.dart';

import '../features/budgets/presentation/screens/budgets_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/insights/presentation/screens/insights_screen.dart';
import '../features/transactions/presentation/screens/transactions_screen.dart';
import '../features/wallets/presentation/screens/wallets_screen.dart';

class FlowFiAppShell extends StatefulWidget {
  const FlowFiAppShell({super.key});

  @override
  State<FlowFiAppShell> createState() => _FlowFiAppShellState();
}

class _FlowFiAppShellState extends State<FlowFiAppShell> {
  int _selectedIndex = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    TransactionsScreen(),
    WalletsScreen(),
    BudgetsScreen(),
    InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home_rounded),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.receipt_long_rounded),
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Transactions',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallets',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.savings_rounded),
            icon: Icon(Icons.savings_outlined),
            label: 'Budgets',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.insights_rounded),
            icon: Icon(Icons.insights_outlined),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}
