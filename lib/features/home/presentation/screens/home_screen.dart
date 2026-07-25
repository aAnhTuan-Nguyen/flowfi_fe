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
                transactions: ref.watch(monthlyTransactionsProvider(currentDate)),
                currency: currency,
                now: currentDate,
              ),
              const SizedBox(height: 18),
              _SpendingChartCard(transactions: ref.watch(monthlyTransactionsProvider(currentDate))),
              const SizedBox(height: 18),
              _CashFlowTrendCard(transactions: ref.watch(monthlyTransactionsProvider(currentDate))),
              const SizedBox(height: 18),
              _InsightNudge(transactions: transactions),
              const SizedBox(height: 18),
              _RecentTransactions(
                transactions: transactions,
                currency: currency,
              ),
              const SizedBox(height: 18),
              _YearlyStatsCard(
                currency: currency,
                now: currentDate,
              ),
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
  const _MonthSnapshot({
    required this.transactions,
    required this.currency,
    required this.now,
  });

  final AsyncValue<List<Transaction>> transactions;
  final String currency;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return transactions.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải thống kê'),
      error: (_, _) => const FlowFiCard(child: Text('Không tải được thống kê.')),
      data: (items) {
        final monthlyExpenses = items
            .where(
              (transaction) =>
                  transaction.type == MoneyFlowType.expense &&
                  transaction.status == TransactionStatus.confirmed &&
                  _isSameMonth(transaction.date, now),
            )
            .fold<BigInt>(
              BigInt.zero,
              (sum, transaction) => sum + _parseWholeAmount(transaction.amount),
            );
        final monthlyIncome = items
            .where(
              (transaction) =>
                  transaction.type == MoneyFlowType.income &&
                  transaction.status == TransactionStatus.confirmed &&
                  _isSameMonth(transaction.date, now),
            )
            .fold<BigInt>(
              BigInt.zero,
              (sum, transaction) => sum + _parseWholeAmount(transaction.amount),
            );

        return Row(
          children: [
            Expanded(
              child: _MiniMetricCard(
                label: 'Chi tiêu tháng này',
                value: _formatMoney(monthlyExpenses, currency),
                icon: Icons.trending_down_rounded,
                tone: _MetricTone.expense,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniMetricCard(
                label: 'Thu nhập tháng này',
                value: _formatMoney(monthlyIncome, currency),
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

class _SpendingChartCard extends StatelessWidget {
  const _SpendingChartCard({required this.transactions});

  final AsyncValue<List<Transaction>> transactions;

  @override
  Widget build(BuildContext context) {
    return transactions.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải biểu đồ'),
      error: (_, _) => const FlowFiCard(child: Text('Không tải được biểu đồ.')),
      data: (items) {
        final confirmed = items
            .where(
              (transaction) =>
                  transaction.status == TransactionStatus.confirmed,
            )
            .toList(growable: false);
        final income = _sumByType(confirmed, MoneyFlowType.income);
        final expense = _sumByType(confirmed, MoneyFlowType.expense);
        final hasData = income > BigInt.zero || expense > BigInt.zero;

        if (!hasData) {
          return const FlowFiInlineEmptyState(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Chưa có dữ liệu biểu đồ',
            message: 'Thêm giao dịch đầu tiên để xem tỷ lệ thu chi.',
          );
        }

        return FlowFiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dòng tiền',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.insights_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 36,
                          borderData: FlBorderData(show: false),
                          sections: [
                            if (expense > BigInt.zero)
                              _chartSection(
                                context,
                                value: expense,
                                title: 'Chi',
                                color: FlowFiColors.expense,
                              ),
                            if (income > BigInt.zero)
                              _chartSection(
                                context,
                                value: income,
                                title: 'Thu',
                                color: FlowFiColors.income,
                              ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendRow(
                            color: FlowFiColors.expense,
                            label: 'Chi tiêu',
                            value: _compactAmount(expense),
                          ),
                          const SizedBox(height: 10),
                          _LegendRow(
                            color: FlowFiColors.income,
                            label: 'Thu nhập',
                            value: _compactAmount(income),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

class _CashFlowTrendCard extends StatelessWidget {
  const _CashFlowTrendCard({required this.transactions});

  final AsyncValue<List<Transaction>> transactions;

  @override
  Widget build(BuildContext context) {
    return transactions.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải dòng tiền'),
      error: (_, _) =>
          const FlowFiCard(child: Text('Không tải được dòng tiền.')),
      data: (items) {
        final daily = <DateTime, BigInt>{};
        for (final transaction in items) {
          if (transaction.status != TransactionStatus.confirmed ||
              transaction.date == null) {
            continue;
          }
          final date = transaction.date!;
          final day = DateTime(date.year, date.month, date.day);
          daily.update(
            day,
            (value) => value + _signedAmount(transaction),
            ifAbsent: () => _signedAmount(transaction),
          );
        }

        final entries = daily.entries.toList()
          ..sort((left, right) => left.key.compareTo(right.key));
        final visible = entries.length > 5
            ? entries.sublist(entries.length - 5)
            : entries;

        if (visible.isEmpty) {
          return const FlowFiInlineEmptyState(
            icon: Icons.bar_chart_rounded,
            title: 'Chưa có dòng tiền',
            message: 'Giao dịch đã xác nhận sẽ tạo biểu đồ theo ngày.',
          );
        }

        final maxValue = visible
            .map((entry) => _absBigInt(entry.value))
            .fold<BigInt>(BigInt.one, (max, value) => value > max ? value : max)
            .toDouble();

        return FlowFiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dòng tiền gần đây',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const FlowFiStatusBadge(
                    label: 'Theo ngày',
                    icon: Icons.calendar_today_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: maxValue * 1.2,
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= visible.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _shortDate(visible[index].key),
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var index = 0; index < visible.length; index++)
                        BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: _absBigInt(visible[index].value).toDouble(),
                              width: 18,
                              borderRadius: BorderRadius.circular(9),
                              color: visible[index].value >= BigInt.zero
                                  ? FlowFiColors.income
                                  : FlowFiColors.expense,
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
  const _YearlyStatsCard({
    required this.currency,
    required this.now,
  });

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

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          tone: tone ?? (percentUsedHundred >= threshold ? FlowFiTone.warning : FlowFiTone.positive),
        ),
      ],
    );
  }
}

PieChartSectionData _chartSection(
  BuildContext context, {
  required BigInt value,
  required String title,
  required Color color,
}) {
  return PieChartSectionData(
    value: value.toDouble(),
    title: title,
    radius: 44,
    color: color,
    titleStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
      color: FlowFiColors.onStrong,
      fontWeight: FontWeight.w800,
    ),
  );
}

BigInt _sumByType(List<Transaction> transactions, MoneyFlowType type) {
  return transactions
      .where((transaction) => transaction.type == type)
      .fold<BigInt>(
        BigInt.zero,
        (sum, transaction) => sum + _parseWholeAmount(transaction.amount),
      );
}

BigInt _signedAmount(Transaction transaction) {
  final amount = _parseWholeAmount(transaction.amount);
  return transaction.type == MoneyFlowType.income ? amount : -amount;
}

BigInt _absBigInt(BigInt value) {
  return value < BigInt.zero ? -value : value;
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

String _compactAmount(BigInt value) {
  if (value >= BigInt.from(1000000)) {
    final millions = value ~/ BigInt.from(1000000);
    return '${millions}m';
  }
  if (value >= BigInt.from(1000)) {
    final thousands = value ~/ BigInt.from(1000);
    return '${thousands}k';
  }
  return value.toString();
}

String _shortDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

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

bool _isSameMonth(DateTime? date, DateTime now) {
  return date != null && date.month == now.month && date.year == now.year;
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
