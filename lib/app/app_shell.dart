import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/budgets/presentation/screens/budgets_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/insights/presentation/screens/insights_screen.dart';
import '../features/transactions/presentation/screens/transactions_screen.dart';
import '../features/wallets/presentation/screens/wallets_screen.dart';
import '../routes/app_routes.dart';

class FlowFiAppShell extends StatelessWidget {
  const FlowFiAppShell({super.key, this.selectedIndex = 0})
    : assert(selectedIndex >= 0 && selectedIndex < _tabCount);

  final int selectedIndex;

  static const _tabCount = 5;

  static const _screens = <Widget>[
    HomeScreen(),
    TransactionsScreen(),
    WalletsScreen(),
    BudgetsScreen(),
    InsightsScreen(),
  ];

  static const _routes = <String>[
    AppRoutes.home,
    AppRoutes.transactions,
    AppRoutes.wallets,
    AppRoutes.budgets,
    AppRoutes.insights,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        sizing: StackFit.expand,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index != selectedIndex) {
            context.go(_routes[index]);
          }
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
