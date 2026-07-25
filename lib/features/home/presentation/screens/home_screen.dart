import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../../routes/app_routes.dart';
import '../../../budgets/presentation/providers/budgets_provider.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
import '../../../transactions/domain/entities/expense_trend.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../wallets/domain/entities/wallet.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
import '../current_date_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).reload();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationsProvider.notifier).reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Object?>(notificationsProvider, (_, _) {});

    final auth = ref.watch(authControllerProvider).value;
    final wallets = ref.watch(walletsProvider);
    final transactions = ref.watch(transactionsProvider);

    final currentDate = ref.watch(currentDateProvider);
    final currency = auth?.user?.currencyCode ?? 'VND';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(walletsProvider.notifier).reload(),
            ref.read(transactionsProvider.notifier).reload(),
            ref.read(budgetsProvider.notifier).reload(),
            ref.read(notificationsProvider.notifier).reload(),
          ]);
          ref.invalidate(monthlyTransactionsProvider(currentDate));
          ref.invalidate(monthlyTransactionSummaryProvider(currentDate));
          ref.invalidate(expenseTrendTransactionsProvider(currentDate));
          ref.invalidate(annualTransactionsProvider(currentDate.year));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(user: auth?.user),
              const SizedBox(height: 18),
              _BalanceOverview(wallets: wallets, currency: currency),
              const SizedBox(height: 12),
              _MonthSnapshot(
                summary: ref.watch(
                  monthlyTransactionSummaryProvider(currentDate),
                ),
                currency: currency,
              ),
              const SizedBox(height: 18),
              _ExpenseTrendCard(
                transactions: ref.watch(
                  expenseTrendTransactionsProvider(currentDate),
                ),
                now: currentDate,
                currency: currency,
              ),
              const SizedBox(height: 18),
              _InsightNudge(transactions: transactions),
              const SizedBox(height: 18),
              _RecentTransactions(
                transactions: transactions,
                currency: currency,
              ),
              const SizedBox(height: 18),
              _YearlyStatsCard(currency: currency, now: currentDate),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final name = _firstName(user?.fullName);

    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount =
        notificationsAsync.value?.where((n) => !n.isRead).length ?? 0;

    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, $name',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Hôm nay mình xem tiền thật nhanh.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Badge(
          isLabelVisible: unreadCount > 0,
          label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
          backgroundColor: colors.error,
          child: FlowFiIconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: Icons.notifications_none_rounded,
            tooltip: 'Thông báo',
            variant: FlowFiButtonVariant.ghost,
          ),
        ),
        FlowFiIconButton(
          onPressed: () => context.push(AppRoutes.profile),
          icon: Icons.account_circle_outlined,
          tooltip: 'Tài khoản',
          variant: FlowFiButtonVariant.ghost,
        ),
      ],
    );
  }
}

class _BalanceOverview extends StatelessWidget {
  const _BalanceOverview({required this.wallets, required this.currency});

  final AsyncValue<List<Wallet>> wallets;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return wallets.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải số dư'),
      error: (_, _) => const FlowFiCard(child: Text('Không tải được ví.')),
      data: (items) {
        final total = items.fold<BigInt>(
          BigInt.zero,
          (sum, wallet) => sum + _parseWholeAmount(wallet.balance),
        );
        Wallet? defaultWallet;
        for (final wallet in items) {
          if (wallet.isDefault) {
            defaultWallet = wallet;
            break;
          }
        }

        return FlowFiCard(
          color: colors.primary,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng số dư',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onPrimary.withValues(alpha: 0.76),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatMoney(total, currency),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: colors.onPrimary.withValues(alpha: 0.88),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      defaultWallet == null
                          ? '${items.length} ví đang theo dõi'
                          : 'Mặc định: ${defaultWallet.name}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.88),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthSnapshot extends StatelessWidget {
  const _MonthSnapshot({required this.summary, required this.currency});

  final AsyncValue<TransactionSummary> summary;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return summary.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải thống kê'),
      error: (_, _) =>
          const FlowFiCard(child: Text('Không tải được thống kê.')),
      data: (summary) {
        return Row(
          children: [
            Expanded(
              child: _MiniMetricCard(
                label: 'Chi tiêu tháng này',
                value: _formatMoney(
                  _parseWholeAmount(summary.totalExpense),
                  currency,
                ),
                icon: Icons.trending_down_rounded,
                tone: _MetricTone.expense,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniMetricCard(
                label: 'Thu nhập tháng này',
                value: _formatMoney(
                  _parseWholeAmount(summary.totalIncome),
                  currency,
                ),
                icon: Icons.trending_up_rounded,
                tone: _MetricTone.income,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExpenseTrendCard extends StatefulWidget {
  const _ExpenseTrendCard({
    required this.transactions,
    required this.now,
    required this.currency,
  });

  final AsyncValue<List<Transaction>> transactions;
  final DateTime now;
  final String currency;

  @override
  State<_ExpenseTrendCard> createState() => _ExpenseTrendCardState();
}

class _ExpenseTrendCardState extends State<_ExpenseTrendCard> {
  ExpenseTrendPeriod _period = ExpenseTrendPeriod.sevenDays;

  @override
  Widget build(BuildContext context) {
    return widget.transactions.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải chi tiêu'),
      error: (_, _) =>
          const FlowFiCard(child: Text('Không tải được xu hướng chi tiêu.')),
      data: (items) {
        final trend = buildExpenseTrend(
          items,
          now: widget.now,
          period: _period,
        );
        final maxY = _trendAxisMax(trend.points);
        final interval = maxY / 3;

        return FlowFiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _period == ExpenseTrendPeriod.sevenDays
                          ? 'Chi tiêu 7 ngày gần đây'
                          : 'Xu hướng chi tiêu theo tuần',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _TrendPeriodSelector(
                    period: _period,
                    onChanged: (period) => setState(() => _period = period),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              _TrendComparison(
                changePercent: trend.changePercent,
                period: _period,
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 210,
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: maxY,
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.55),
                        strokeWidth: 1,
                        dashArray: [3, 3],
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) =>
                            Theme.of(context).colorScheme.inverseSurface,
                        getTooltipItem: (group, _, rod, _) {
                          final point = trend.points[group.x];
                          final label = _period == ExpenseTrendPeriod.sevenDays
                              ? _fullWeekday(point.start.weekday)
                              : 'Tuần ${_shortDate(point.start)}';
                          return BarTooltipItem(
                            '$label\n${_formatMoney(point.amountMinorUnits ~/ BigInt.from(100), widget.currency)}',
                            Theme.of(context).textTheme.labelMedium!.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onInverseSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 52,
                          interval: interval,
                          getTitlesWidget: (value, meta) => SideTitleWidget(
                            meta: meta,
                            space: 4,
                            child: SizedBox(
                              width: 42,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _millionAxisLabel(value),
                                  maxLines: 1,
                                  softWrap: false,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= trend.points.length) {
                              return const SizedBox.shrink();
                            }
                            final point = trend.points[index];
                            return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: Text(
                                _period == ExpenseTrendPeriod.sevenDays
                                    ? _shortWeekday(point.start.weekday)
                                    : _shortDate(point.start),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var index = 0; index < trend.points.length; index++)
                        BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY:
                                  trend.points[index].amountMinorUnits
                                      .toDouble() /
                                  100,
                              width: 17,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                              color: FlowFiColors.expense,
                            ),
                          ],
                        ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrendPeriodSelector extends StatelessWidget {
  const _TrendPeriodSelector({required this.period, required this.onChanged});

  final ExpenseTrendPeriod period;
  final ValueChanged<ExpenseTrendPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TrendPeriodOption(
            label: '7 ngày',
            selected: period == ExpenseTrendPeriod.sevenDays,
            onTap: () => onChanged(ExpenseTrendPeriod.sevenDays),
          ),
          _TrendPeriodOption(
            label: 'Tuần',
            selected: period == ExpenseTrendPeriod.weekly,
            onTap: () => onChanged(ExpenseTrendPeriod.weekly),
          ),
        ],
      ),
    );
  }
}

class _TrendPeriodOption extends StatelessWidget {
  const _TrendPeriodOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Theme.of(context).colorScheme.surfaceContainerLowest
          : Colors.transparent,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendComparison extends StatelessWidget {
  const _TrendComparison({required this.changePercent, required this.period});

  final double changePercent;
  final ExpenseTrendPeriod period;

  @override
  Widget build(BuildContext context) {
    final rounded = changePercent.abs().round();
    final arrow = changePercent > 0
        ? '↑'
        : changePercent < 0
        ? '↓'
        : '→';
    return Text(
      '$arrow $rounded% so với ${period == ExpenseTrendPeriod.sevenDays ? '7 ngày' : '7 tuần'} trước',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InsightNudge extends StatelessWidget {
  const _InsightNudge({required this.transactions});

  final AsyncValue<List<Transaction>> transactions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FlowFiCard(
      color: colors.surfaceContainerLow,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: transactions.when(
              loading: () => const Text('AI đang chờ dữ liệu giao dịch.'),
              error: (_, _) => const Text('AI sẽ gợi ý khi dữ liệu sẵn sàng.'),
              data: (items) => Text(
                'Dùng dấu cộng ở thanh dưới để nhập nhanh, scan hoặc tạo gợi ý bằng giọng nói.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({
    required this.transactions,
    required this.currency,
  });

  final AsyncValue<List<Transaction>> transactions;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return transactions.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải giao dịch'),
      error: (_, _) =>
          const FlowFiCard(child: Text('Không tải được giao dịch.')),
      data: (items) {
        final recent = sortTransactionsByActivity(
          items.where(
            (transaction) => transaction.status == TransactionStatus.confirmed,
          ),
        ).take(3);
        if (recent.isEmpty) {
          return const FlowFiInlineEmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'Chưa có giao dịch',
            message: 'Nhấn dấu cộng ở thanh dưới để tạo giao dịch đầu tiên.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Giao dịch gần đây',
              actionLabel: 'Xem tất cả',
              onActionPressed: () => context.go(AppRoutes.transactions),
            ),
            const SizedBox(height: 10),
            for (final transaction in recent) ...[
              _TransactionTile(transaction: transaction, currency: currency),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _YearlyStatsCard extends ConsumerWidget {
  const _YearlyStatsCard({required this.currency, required this.now});

  final String currency;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(annualTransactionsProvider(now.year));

    if (transactionsAsync.isLoading) {
      return const FlowFiInlineLoading(label: 'Đang tải thống kê');
    }

    if (transactionsAsync.hasError) {
      return const FlowFiCard(child: Text('Không tải được thống kê.'));
    }

    final transactions = transactionsAsync.value ?? [];

    final confirmed = transactions
        .where((t) => t.status == TransactionStatus.confirmed)
        .toList();

    final expenses = _sumByType(confirmed, MoneyFlowType.expense);
    final income = _sumByType(confirmed, MoneyFlowType.income);

    return FlowFiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê theo năm',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          _BudgetProgress(
            tagName: 'Tổng Thu',
            targetAmount: income,
            spentAmount: income,
            percentUsed: 1.0,
            warningThresholdPercent: 100,
            currency: currency,
            tone: FlowFiTone.positive,
            hideTarget: true,
          ),
          const SizedBox(height: 12),
          _BudgetProgress(
            tagName: 'Tổng Chi',
            targetAmount: expenses,
            spentAmount: expenses,
            percentUsed: 1.0,
            warningThresholdPercent: 100,
            currency: currency,
            tone: FlowFiTone.warning,
            hideTarget: true,
          ),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final _MetricTone tone;

  @override
  Widget build(BuildContext context) {
    final toneColor = tone == _MetricTone.income
        ? FlowFiColors.income
        : FlowFiColors.expense;

    return FlowFiMetricCard(
      label: label,
      value: value,
      icon: icon,
      iconColor: toneColor,
    );
  }
}

enum _MetricTone { income, expense }

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
        FlowFiButton(
          label: actionLabel,
          onPressed: onActionPressed,
          fullWidth: false,
          variant: FlowFiButtonVariant.ghost,
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.currency});

  final Transaction transaction;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == MoneyFlowType.income;
    final colors = Theme.of(context).colorScheme;
    final toneColor = isIncome ? FlowFiColors.income : FlowFiColors.expense;
    final amount = _formatMoney(
      _parseWholeAmount(transaction.amount),
      currency,
    );

    return FlowFiCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: toneColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: toneColor,
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
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _transactionMeta(transaction),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isIncome ? '+' : '-'}$amount',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: toneColor),
          ),
        ],
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({
    required this.tagName,
    required this.targetAmount,
    required this.spentAmount,
    required this.percentUsed,
    required this.warningThresholdPercent,
    required this.currency,
    this.tone,
    this.hideTarget = false,
  });

  final String tagName;
  final BigInt targetAmount;
  final BigInt spentAmount;
  final double percentUsed;
  final int warningThresholdPercent;
  final String currency;
  final FlowFiTone? tone;
  final bool hideTarget;

  @override
  Widget build(BuildContext context) {
    final threshold = warningThresholdPercent.clamp(0, 100);
    final percentUsedHundred = (percentUsed * 100).toInt();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                tagName,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              hideTarget
                  ? _formatMoney(spentAmount, currency)
                  : '${_formatMoney(spentAmount, currency)} / ${_formatMoney(targetAmount, currency)}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FlowFiProgressBar(
          value: percentUsed.clamp(0.0, 1.0),
          tone:
              tone ??
              (percentUsedHundred >= threshold
                  ? FlowFiTone.warning
                  : FlowFiTone.positive),
        ),
      ],
    );
  }
}

BigInt _sumByType(List<Transaction> transactions, MoneyFlowType type) {
  return transactions
      .where((transaction) => transaction.type == type)
      .fold<BigInt>(
        BigInt.zero,
        (sum, transaction) => sum + _parseWholeAmount(transaction.amount),
      );
}

BigInt _parseWholeAmount(String value) {
  final normalized = value.trim().replaceAll(',', '');
  final match = RegExp(r'^-?\d+').firstMatch(normalized);
  if (match == null) {
    return BigInt.zero;
  }
  return BigInt.tryParse(match.group(0)!) ?? BigInt.zero;
}

String _formatMoney(BigInt value, String currency) {
  final negative = value < BigInt.zero;
  final digits = (negative ? -value : value).toString();
  final grouped = _groupDigits(digits);
  return '${negative ? '-' : ''}$grouped $currency';
}

String _shortDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

double _trendAxisMax(List<ExpenseTrendPoint> points) {
  final maxMinorUnits = points.fold<BigInt>(
    BigInt.zero,
    (max, point) => point.amountMinorUnits > max ? point.amountMinorUnits : max,
  );
  final maxWholeUnits = maxMinorUnits ~/ BigInt.from(100);
  const oneMillion = 1000000;
  if (maxWholeUnits <= BigInt.from(oneMillion * 3)) {
    return (oneMillion * 3).toDouble();
  }
  final millions =
      (maxWholeUnits + BigInt.from(oneMillion - 1)) ~/ BigInt.from(oneMillion);
  final rawStep = ((millions + BigInt.from(2)) ~/ BigInt.from(3)).toInt();
  var roundingUnit = 1;
  while (rawStep > roundingUnit * 10) {
    roundingUnit *= 10;
  }
  final roundedStep =
      ((rawStep + roundingUnit - 1) ~/ roundingUnit) * roundingUnit;
  return (roundedStep * oneMillion * 3).toDouble();
}

String _millionAxisLabel(double value) {
  if (value == 0) return '0';
  final millions = value / 1000000;
  return '${millions.round()}M';
}

String _shortWeekday(int weekday) => switch (weekday) {
  DateTime.monday => 'T2',
  DateTime.tuesday => 'T3',
  DateTime.wednesday => 'T4',
  DateTime.thursday => 'T5',
  DateTime.friday => 'T6',
  DateTime.saturday => 'T7',
  _ => 'CN',
};

String _fullWeekday(int weekday) => switch (weekday) {
  DateTime.monday => 'Thứ 2',
  DateTime.tuesday => 'Thứ 3',
  DateTime.wednesday => 'Thứ 4',
  DateTime.thursday => 'Thứ 5',
  DateTime.friday => 'Thứ 6',
  DateTime.saturday => 'Thứ 7',
  _ => 'Chủ nhật',
};

String _groupDigits(String digits) {
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

String _firstName(String? name) {
  final trimmed = name?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return 'bạn';
  }
  return trimmed.split(RegExp(r'\s+')).first;
}

String _transactionMeta(Transaction transaction) {
  final date = transaction.date;
  final dateLabel = date == null
      ? 'Không có ngày'
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  final status = switch (transaction.status) {
    TransactionStatus.draft => 'Nháp',
    TransactionStatus.confirmed => 'Đã xác nhận',
    TransactionStatus.unknown => 'Không rõ',
  };
  return '$dateLabel · $status';
}
