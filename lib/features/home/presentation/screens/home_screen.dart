import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/app_routes.dart';
import '../../../ai_processing/presentation/widgets/image_transaction_import_sheet.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../tags/presentation/widgets/tag_manager_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _transactions = [
    _TransactionItem(
      icon: Icons.local_cafe_rounded,
      title: 'Coffee House',
      subtitle: 'Food & Drink - Today',
      amount: '-50k',
      isIncome: false,
    ),
    _TransactionItem(
      icon: Icons.directions_bus_rounded,
      title: 'Grab Transport',
      subtitle: 'Travel - Yesterday',
      amount: '-80k',
      isIncome: false,
    ),
    _TransactionItem(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Monthly Salary',
      subtitle: 'Income - Oct 28',
      amount: '+15m',
      isIncome: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          children: [
            const _HomeHeader(),
            const SizedBox(height: 20),
            const _BalanceCard(),
            const SizedBox(height: 14),
            const _QuickActions(),
            const SizedBox(height: 18),
            const _AiInsightsCard(),
            const SizedBox(height: 18),
            const _BudgetHealthCard(),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Recent Transactions',
              actionLabel: 'View All',
              onActionPressed: () => context.go(AppRoutes.transactions),
            ),
            const SizedBox(height: 10),
            ..._transactions.map(
              (transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TransactionTile(transaction: transaction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.person_rounded,
            size: 22,
            color: colors.onSecondaryContainer,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'FlowFi',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: const Color(0xFF49672A)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
        ),
        PopupMenuButton<_AccountAction>(
          tooltip: 'Account',
          icon: const Icon(Icons.account_circle_outlined),
          onSelected: (action) async {
            switch (action) {
              case _AccountAction.signOut:
                final confirmed = await confirmDestructiveAction(
                  context,
                  title: 'Sign out?',
                  message: 'You will need to log in again to use FlowFi.',
                  actionLabel: 'Sign out',
                );
                if (!confirmed || !context.mounted) {
                  return;
                }
                try {
                  await ref.read(authControllerProvider.notifier).signOut();
                } catch (_) {
                  if (context.mounted) {
                    showGenericMutationError(context);
                  }
                }
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _AccountAction.signOut,
              child: Text('Sign out'),
            ),
          ],
        ),
      ],
    );
  }
}

enum _AccountAction { signOut }

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF123B16),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL BALANCE',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFFC9EE9F),
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '+5,000,000 VND',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFC9EE9F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  size: 15,
                  color: Color(0xFF123B16),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '+2.4% this month',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFFC9EE9F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.add_rounded,
            label: 'Add',
            onTap: () => context.go(AppRoutes.transactions),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.sell_outlined,
            label: 'Tags',
            onTap: () => showFlowFiFormSheet<void>(
              context: context,
              title: 'Manage tags',
              child: const TagManagerSheet(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.document_scanner_outlined,
            label: 'Scan',
            onTap: () => showFlowFiFormSheet<void>(
              context: context,
              title: 'Scan receipt',
              child: const ImageTransactionImportSheet(),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7E5DC)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7EF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF49672A)),
              ),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiInsightsCard extends StatelessWidget {
  const _AiInsightsCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'AI Insights',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: Color(0xFF8BAE66),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 320;
              final chartSize = isCompact
                  ? constraints.maxWidth.clamp(72.0, 96.0)
                  : 96.0;

              final chart = _InsightChart(size: chartSize);
              final insightText = _InsightText(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                highlightColor: Theme.of(context).colorScheme.primary,
                textAlign: isCompact ? TextAlign.center : TextAlign.start,
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    chart,
                    const SizedBox(height: 14),
                    insightText,
                  ],
                );
              }

              return Row(
                children: [
                  chart,
                  const SizedBox(width: 18),
                  Expanded(child: insightText),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InsightChart extends StatelessWidget {
  const _InsightChart({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: 0.65,
              strokeWidth: 10,
              backgroundColor: Color(0xFFD7DED0),
              valueColor: AlwaysStoppedAnimation(Color(0xFF49672A)),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FOOD',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF757872),
                ),
              ),
              Text(
                '65%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B211A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightText extends StatelessWidget {
  const _InsightText({
    required this.textStyle,
    required this.highlightColor,
    required this.textAlign,
  });

  final TextStyle? textStyle;
  final Color highlightColor;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Your spending on ',
        children: [
          const TextSpan(
            text: 'Dining Out',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const TextSpan(text: ' is '),
          TextSpan(
            text: '12%',
            style: TextStyle(
              color: highlightColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const TextSpan(text: ' lower than last month. Keep it up!'),
        ],
      ),
      textAlign: textAlign,
      style: textStyle,
    );
  }
}

class _BudgetHealthCard extends StatelessWidget {
  const _BudgetHealthCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      color: const Color(0xFFFFF6EB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget Health', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          const _BudgetProgress(
            label: 'Shopping',
            valueLabel: '80% used',
            value: 0.80,
          ),
          const SizedBox(height: 12),
          const _BudgetProgress(
            label: 'Entertainment',
            valueLabel: '35% used',
            value: 0.35,
          ),
        ],
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({
    required this.label,
    required this.valueLabel,
    required this.value,
  });

  final String label;
  final String valueLabel;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            Text(
              valueLabel,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: const Color(0xFF757872)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: value,
            backgroundColor: const Color(0xFFE4DED4),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF49672A)),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        TextButton(
          onPressed: onActionPressed,
          child: Text(
            actionLabel,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: const Color(0xFF49672A)),
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final _TransactionItem transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E5DC)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.isIncome
                  ? const Color(0xFF49672A)
                  : const Color(0xFFF3F7E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.icon,
              color: transaction.isIncome
                  ? Colors.white
                  : const Color(0xFF49672A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF757872),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            transaction.amount,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: transaction.isIncome
                  ? const Color(0xFF49672A)
                  : const Color(0xFF1B211A),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child, this.color = Colors.white});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E5DC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1B211A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TransactionItem {
  const _TransactionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
}
