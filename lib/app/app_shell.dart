import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/budgets/presentation/screens/budgets_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/insights/presentation/screens/insights_screen.dart';
import '../features/transactions/presentation/screens/transactions_screen.dart';
import '../features/transactions/presentation/widgets/transaction_entry_sheet.dart';
import '../features/wallets/presentation/screens/wallets_screen.dart';
import '../features/ai_processing/presentation/widgets/image_transaction_import_sheet.dart';
import '../features/shared/presentation/widgets/feature_states.dart';
import '../features/sync/sync_status_banner.dart';
import '../routes/app_routes.dart';

class FlowFiAppShell extends StatelessWidget {
  const FlowFiAppShell({super.key, this.selectedIndex = 0})
    : assert(selectedIndex >= 0 && selectedIndex < _tabCount);

  final int selectedIndex;

  static const _tabCount = 5;
  static const _navigationCount = 4;

  static const _screens = <Widget>[
    HomeScreen(),
    TransactionsScreen(),
    WalletsScreen(),
    BudgetsScreen(),
    InsightsScreen(),
  ];

  static const _navigationRoutes = <String>[
    AppRoutes.home,
    AppRoutes.transactions,
    AppRoutes.wallets,
    AppRoutes.budgets,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SyncStatusBanner(),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              sizing: StackFit.expand,
              children: _screens,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm giao dịch',
        onPressed: () => _showTransactionLauncher(context),
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: _FlowFiBottomBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index != selectedIndex) {
            context.go(_navigationRoutes[index]);
          }
        },
      ),
    );
  }

  void _showTransactionLauncher(BuildContext context) {
    showFlowFiFormSheet<void>(
      context: context,
      title: 'Thêm giao dịch',
      child: TransactionEntryLauncherSheet(
        onScan: () => _openNextSheet(
          context,
          title: 'Quét hóa đơn',
          child: const ImageTransactionImportSheet(),
        ),
        onVoice: () => _openNextSheet(
          context,
          title: 'Nói giao dịch',
          child: const VoiceTransactionPlaceholder(),
        ),
        onManual: () => _openNextSheet(
          context,
          title: 'Nhập nhanh',
          child: const QuickTransactionSheet(),
        ),
      ),
    );
  }

  void _openNextSheet(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      showFlowFiFormSheet<void>(context: context, title: title, child: child);
    });
  }
}

class _FlowFiBottomBar extends StatelessWidget {
  const _FlowFiBottomBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final activeIndex = selectedIndex < FlowFiAppShell._navigationCount
        ? selectedIndex
        : -1;

    return BottomAppBar(
      height: 78,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 8,
      child: Row(
        children: [
          _BottomBarItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Trang chủ',
            selected: activeIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),
          _BottomBarItem(
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long_rounded,
            label: 'Giao dịch',
            selected: activeIndex == 1,
            onTap: () => onDestinationSelected(1),
          ),
          const SizedBox(width: 70),
          _BottomBarItem(
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet_rounded,
            label: 'Ví',
            selected: activeIndex == 2,
            onTap: () => onDestinationSelected(2),
          ),
          _BottomBarItem(
            icon: Icons.savings_outlined,
            selectedIcon: Icons.savings_rounded,
            label: 'Ngân sách',
            selected: activeIndex == 3,
            onTap: () => onDestinationSelected(3),
          ),
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF49672A) : const Color(0xFF757872);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 23),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
