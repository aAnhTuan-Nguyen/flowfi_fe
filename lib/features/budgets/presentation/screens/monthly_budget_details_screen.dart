import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/budget.dart';
import '../../domain/entities/monthly_budget_details.dart';
import '../providers/budgets_provider.dart';
import 'budget_target_screen.dart';

const _green = Color(0xFF3D752D);
const _red = Color(0xFFE43E3E);
const _palette = [
  Color(0xFF4A7E35),
  Color(0xFF6750C7),
  Color(0xFF2E8588),
  Color(0xFFFF9A24),
  Color(0xFFE04747),
  Color(0xFFB8B8B8),
];

class MonthlyBudgetDetailsScreen extends ConsumerStatefulWidget {
  const MonthlyBudgetDetailsScreen({
    super.key,
    required this.month,
    required this.year,
    required this.budgets,
  });

  final int month;
  final int year;
  final List<Budget> budgets;

  @override
  ConsumerState<MonthlyBudgetDetailsScreen> createState() =>
      _MonthlyBudgetDetailsScreenState();
}

class _MonthlyBudgetDetailsScreenState
    extends ConsumerState<MonthlyBudgetDetailsScreen> {
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    _month = widget.month;
    _year = widget.year;
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(
      monthlyBudgetDetailsProvider((month: _month, year: _year)),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Chi tiết tháng $_month'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Chỉnh sửa Target',
            onPressed: _editTarget,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          monthlyBudgetDetailsProvider((month: _month, year: _year)).future,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            Center(
              child: _MonthPicker(
                month: _month,
                year: _year,
                onSelected: _selectMonth,
              ),
            ),
            const SizedBox(height: 16),
            details.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => _ErrorCard(
                onRetry: () => ref.invalidate(
                  monthlyBudgetDetailsProvider((month: _month, year: _year)),
                ),
              ),
              data: (value) => _DetailsContent(details: value),
            ),
          ],
        ),
      ),
    );
  }

  void _selectMonth(int month) => setState(() => _month = month);

  Future<void> _editTarget() async {
    final budgets = widget.budgets
        .where((budget) => budget.month == _month && budget.year == _year)
        .toList();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            BudgetTargetScreen(month: _month, year: _year, budgets: budgets),
      ),
    );
    ref.invalidate(monthlyBudgetDetailsProvider((month: _month, year: _year)));
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({required this.details});

  final MonthlyBudgetDetails details;

  @override
  Widget build(BuildContext context) {
    final remaining = _minorUnits(details.remainingAmount);
    final isSaving = remaining >= BigInt.zero;
    final differencePercent = details.targetAmount == '0.00'
        ? 0
        : (100 - details.percentUsed).abs().round();

    return Column(
      children: [
        _SummaryCard(
          details: details,
          isSaving: isSaving,
          differencePercent: differencePercent,
        ),
        const SizedBox(height: 12),
        _OverviewCard(details: details),
        const SizedBox(height: 12),
        _CategorySpendingCard(details: details),
        const SizedBox(height: 12),
        _TargetComparisonCard(categories: details.categories),
        const SizedBox(height: 12),
        _InsightCard(details: details, isSaving: isSaving),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.details,
    required this.isSaving,
    required this.differencePercent,
  });
  final MonthlyBudgetDetails details;
  final bool isSaving;
  final int differencePercent;

  @override
  Widget build(BuildContext context) {
    final progress = (details.percentUsed / 100).clamp(0.0, 1.0);
    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSaving ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$differencePercent%  ${isSaving ? 'Tiết kiệm' : 'Vượt mức'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSaving ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isSaving
                      ? 'Bạn đã chi tiêu thấp hơn mục tiêu trong tháng này.'
                      : 'Chi tiêu tháng này đang cao hơn mục tiêu.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Metric(
                label: 'Mục tiêu',
                value: details.targetAmount,
                icon: Icons.track_changes_rounded,
              ),
              const _MetricDivider(),
              _Metric(
                label: 'Đã chi',
                value: details.spentAmount,
                icon: Icons.circle,
              ),
              const _MetricDivider(),
              _Metric(
                label: isSaving ? 'Tiết kiệm' : 'Vượt mức',
                value: _absoluteAmount(details.remainingAmount),
                icon: Icons.eco_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        color: isSaving ? _green : _red,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${details.percentUsed.round()}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bạn đã chi ${details.percentUsed.round()}% mục tiêu'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      color: isSaving ? _green : _red,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${_formatMoney(details.spentAmount)}đ / ${_formatMoney(details.targetAmount)}đ',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: _green),
            const SizedBox(width: 6),
            Flexible(child: Text(label)),
          ],
        ),
        const SizedBox(height: 7),
        FittedBox(
          child: Text(
            '${_formatMoney(value)}đ',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
        ),
      ],
    ),
  );
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();
  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 54, child: VerticalDivider(width: 22));
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.details});
  final MonthlyBudgetDetails details;
  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tổng quan tháng', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            _OverviewItem(
              icon: Icons.receipt_long_outlined,
              label: 'Giao dịch',
              value: '${details.transactionCount}',
            ),
            const SizedBox(width: 8),
            _OverviewItem(
              icon: Icons.category_outlined,
              label: 'Danh mục cao nhất',
              value: details.topCategoryName ?? '—',
            ),
            const SizedBox(width: 8),
            _OverviewItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Ví dùng nhiều nhất',
              value: details.topWalletName ?? '—',
            ),
          ],
        ),
      ],
    ),
  );
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _green, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 13),
          ),
        ],
      ),
    ),
  );
}

class _CategorySpendingCard extends StatelessWidget {
  const _CategorySpendingCard({required this.details});
  final MonthlyBudgetDetails details;
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiêu theo danh mục',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          if (details.categories.isEmpty)
            const Text('Chưa có chi tiêu trong tháng này.')
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final chart = SizedBox(
                  width: 150,
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 45,
                      sectionsSpace: 2,
                      sections: [
                        for (
                          var index = 0;
                          index < details.categories.length;
                          index++
                        )
                          PieChartSectionData(
                            value: details.categories[index].percentOfSpend,
                            title: '',
                            radius: 22,
                            color: _palette[index % _palette.length],
                          ),
                      ],
                    ),
                  ),
                );
                final legend = Column(
                  children: [
                    for (
                      var index = 0;
                      index < details.categories.length;
                      index++
                    )
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _palette[index % _palette.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(details.categories[index].tagName),
                            ),
                            Text(
                              '${_formatMoney(details.categories[index].spentAmount)}đ',
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 34,
                              child: Text(
                                '${details.categories[index].percentOfSpend.round()}%',
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
                if (constraints.maxWidth < 430) {
                  return Column(
                    children: [chart, const SizedBox(height: 8), legend],
                  );
                }
                return Row(
                  children: [
                    chart,
                    const SizedBox(width: 16),
                    Expanded(child: legend),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TargetComparisonCard extends StatelessWidget {
  const _TargetComparisonCard({required this.categories});
  final List<MonthlyBudgetCategoryDetail> categories;
  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('So với target', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (categories.isEmpty)
          const Text('Chưa có dữ liệu so sánh.')
        else
          for (final category in categories.where(
            (item) => _minorUnits(item.targetAmount) > BigInt.zero,
          ))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      category.tagName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: (_moneyRatio(
                        category.spentAmount,
                        category.targetAmount,
                      )).clamp(0, 1),
                      minHeight: 7,
                      color: category.variancePercent > 0 ? _red : _green,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${_formatMoney(category.spentAmount)}đ',
                      textAlign: TextAlign.end,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${category.variancePercent > 0 ? '+' : ''}${category.variancePercent.round()}%',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: category.variancePercent > 0 ? _red : _green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    ),
  );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.details, required this.isSaving});
  final MonthlyBudgetDetails details;
  final bool isSaving;
  @override
  Widget build(BuildContext context) {
    final exceeded = details.categories
        .where((item) => item.variancePercent > 0)
        .map((item) => item.tagName)
        .take(2)
        .join(' và ');
    final text = isSaving
        ? exceeded.isEmpty
              ? 'Bạn đang kiểm soát chi tiêu tốt trong tháng ${details.month}. Hãy duy trì kế hoạch hiện tại.'
              : 'Bạn vẫn nằm trong Target tháng ${details.month}, nhưng $exceeded đang cao hơn kế hoạch.'
        : 'Bạn đã vượt Target tháng ${details.month}. Hãy xem lại các danh mục chi tiêu cao để điều chỉnh.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: _green,
            child: Icon(Icons.auto_awesome_outlined),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insight tháng',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: _green),
                ),
                const SizedBox(height: 4),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({
    required this.month,
    required this.year,
    required this.onSelected,
  });
  final int month;
  final int year;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
    initialValue: month,
    onSelected: onSelected,
    itemBuilder: (_) => [
      for (var value = 1; value <= 12; value++)
        PopupMenuItem(value: value, child: Text('Tháng $value / $year')),
    ],
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_month_outlined, size: 20),
          const SizedBox(width: 9),
          Text('T$month $year'),
          const SizedBox(width: 9),
          const Icon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(19),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      children: [
        const Text('Không tải được chi tiết tháng.'),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    ),
  );
}

BigInt _minorUnits(String value) {
  final normalized = value.replaceAll(RegExp(r'[^0-9.-]'), '');
  final negative = normalized.startsWith('-');
  final parts = normalized.replaceFirst('-', '').split('.');
  final whole = BigInt.tryParse(parts.first) ?? BigInt.zero;
  final minor = parts.length > 1 ? '${parts[1]}00'.substring(0, 2) : '00';
  final result =
      whole * BigInt.from(100) + (BigInt.tryParse(minor) ?? BigInt.zero);
  return negative ? -result : result;
}

String _formatMoney(String value) => _formatMinorUnits(_minorUnits(value));
String _absoluteAmount(String value) {
  final absolute = _minorUnits(value).abs();
  final major = absolute ~/ BigInt.from(100);
  final minor = (absolute % BigInt.from(100)).toString().padLeft(2, '0');
  return '$major.$minor';
}

String _formatMinorUnits(BigInt value) {
  final digits = (value ~/ BigInt.from(100)).toString();
  return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
}

double _moneyRatio(String spent, String target) {
  final denominator = _minorUnits(target);
  if (denominator <= BigInt.zero) return 0;
  return ((_minorUnits(spent) * BigInt.from(10000)) ~/ denominator).toInt() /
      10000;
}
