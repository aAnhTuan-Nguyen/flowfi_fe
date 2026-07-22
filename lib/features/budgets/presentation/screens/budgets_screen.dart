import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../domain/entities/annual_budget_summary.dart';
import '../../domain/entities/budget.dart';
import '../providers/budgets_provider.dart';
import 'budget_target_screen.dart';
import 'monthly_budget_details_screen.dart';

const _forest = Color(0xFF356B2B);
const _danger = Color(0xFFD9362B);

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetsProvider);
    final annualSummary = ref.watch(annualBudgetSummaryProvider(_selectedYear));

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(budgetsProvider.notifier).reload();
            ref.invalidate(annualBudgetSummaryProvider(_selectedYear));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
                sliver: SliverList.list(
                  children: [
                    _Header(
                      year: _selectedYear,
                      onYearChanged: (year) =>
                          setState(() => _selectedYear = year),
                    ),
                    const SizedBox(height: 28),
                    budgets.when(
                      loading: () => const FlowFiInlineLoading(),
                      error: (_, _) => FlowFiInlineError(
                        message: 'Không tải được dữ liệu ngân sách.',
                        onRetry: () =>
                            ref.read(budgetsProvider.notifier).reload(),
                      ),
                      data: (items) => _AnnualBudgetContent(
                        year: _selectedYear,
                        budgets: items
                            .where((budget) => budget.year == _selectedYear)
                            .toList(),
                        summary: annualSummary.asData?.value ?? [],
                        onOpenTarget: (month) => _openTarget(
                          context,
                          month: month,
                          budgets: items
                              .where(
                                (budget) =>
                                    budget.year == _selectedYear &&
                                    budget.month == month,
                              )
                              .toList(),
                        ),
                        onOpenDetails: (month) => _openDetails(
                          context,
                          month: month,
                          budgets: items
                              .where((budget) => budget.year == _selectedYear)
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTarget(
    BuildContext context, {
    required int month,
    required List<Budget> budgets,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BudgetTargetScreen(
          month: month,
          year: _selectedYear,
          budgets: budgets,
        ),
      ),
    );
    ref.invalidate(annualBudgetSummaryProvider(_selectedYear));
  }

  Future<void> _openDetails(
    BuildContext context, {
    required int month,
    required List<Budget> budgets,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MonthlyBudgetDetailsScreen(
          month: month,
          year: _selectedYear,
          budgets: budgets,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.year, required this.onYearChanged});

  final int year;
  final ValueChanged<int> onYearChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentYear = DateTime.now().year;
    final years = [
      for (var value = currentYear - 3; value <= currentYear + 3; value++)
        value,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ngân sách năm',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Theo dõi mục tiêu chi tiêu theo 12 tháng',
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: year,
              borderRadius: BorderRadius.circular(16),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              style: textTheme.titleMedium?.copyWith(
                color: _forest,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              items: [
                for (final value in years)
                  DropdownMenuItem(value: value, child: Text('$value')),
              ],
              onChanged: (value) {
                if (value != null) onYearChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AnnualBudgetContent extends StatelessWidget {
  const _AnnualBudgetContent({
    required this.year,
    required this.budgets,
    required this.summary,
    required this.onOpenTarget,
    required this.onOpenDetails,
  });

  final int year;
  final List<Budget> budgets;
  final List<AnnualBudgetMonthSummary> summary;
  final ValueChanged<int> onOpenTarget;
  final ValueChanged<int> onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final byMonth = <int, List<Budget>>{};
    for (final budget in budgets) {
      if (budget.tagId != null) {
        byMonth.putIfAbsent(budget.month, () => []).add(budget);
      }
    }
    final totalsByMonth = {
      for (final entry in byMonth.entries)
        entry.key: _sumBudgetAmounts(entry.value),
    };
    final summaryByMonth = {for (final item in summary) item.month: item};

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720 ? 4 : 3;
            final spacing = 12.0;
            final width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (var month = 1; month <= 12; month++)
                  SizedBox(
                    width: width,
                    child: _MonthCard(
                      month: month,
                      year: year,
                      amount: totalsByMonth[month],
                      summary: summaryByMonth[month],
                      onTap: () => byMonth[month] == null
                          ? onOpenTarget(month)
                          : onOpenDetails(month),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        _AnnualChart(
          year: year,
          budgetsByMonth: totalsByMonth,
          summaryByMonth: summaryByMonth,
        ),
      ],
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.year,
    required this.amount,
    required this.summary,
    required this.onTap,
  });

  final int month;
  final int year;
  final String? amount;
  final AnnualBudgetMonthSummary? summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrent = now.month == month && now.year == year;
    final isPast = DateTime(
      year,
      month + 1,
    ).isBefore(DateTime(now.year, now.month + 1));
    final hasBudget = amount != null;
    final isExceeded = summary?.isExceeded ?? false;
    final accentColor = isExceeded ? _danger : _forest;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: isCurrent || isExceeded ? 142 : 116,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isExceeded
                  ? _danger
                  : isCurrent
                  ? _forest
                  : !hasBudget && !isPast
                  ? Theme.of(context).colorScheme.outlineVariant
                  : const Color(0xFFEDE8E3),
              width: isCurrent || isExceeded ? 1.7 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'T$month',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isCurrent || isExceeded
                          ? accentColor
                          : const Color(0xFF514B47),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (hasBudget)
                    Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        color: isExceeded
                            ? Theme.of(context).colorScheme.errorContainer
                            : Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExceeded
                            ? Icons.priority_high_rounded
                            : Icons.check_rounded,
                        color: accentColor,
                        size: 18,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (hasBudget) ...[
                Text(
                  isExceeded
                      ? '+${summary!.exceededPercent.round()}%'
                      : _compactAmount(amount!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accentColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isExceeded
                      ? 'Vượt mức · ${_compactAmount(summary!.spentAmount)}'
                      : isCurrent
                      ? 'Mục tiêu tháng này'
                      : 'Đã thiết lập',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isCurrent || isExceeded) ...[
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: math.min((summary?.percentUsed ?? 100) / 100, 1),
                      minHeight: 7,
                      color: accentColor,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ] else
                Center(
                  child: Column(
                    children: [
                      Icon(
                        isPast
                            ? Icons.calendar_month_outlined
                            : Icons.add_rounded,
                        color: isPast ? const Color(0xFF89847E) : _forest,
                        size: 27,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isPast ? 'Chưa thiết lập' : 'Thiết lập',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: isPast ? const Color(0xFF756F69) : _forest,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnualChart extends StatelessWidget {
  const _AnnualChart({
    required this.year,
    required this.budgetsByMonth,
    required this.summaryByMonth,
  });

  final int year;
  final Map<int, String> budgetsByMonth;
  final Map<int, AnnualBudgetMonthSummary> summaryByMonth;

  @override
  Widget build(BuildContext context) {
    final targetValues = [
      for (var month = 1; month <= 12; month++)
        _amountValue(
          summaryByMonth[month]?.targetAmount ?? budgetsByMonth[month],
        ),
    ];
    final spentValues = [
      for (var month = 1; month <= 12; month++)
        _amountValue(summaryByMonth[month]?.spentAmount),
    ];
    final maxValue = [
      ...targetValues,
      ...spentValues,
    ].fold<double>(0, math.max);
    final chartMax = maxValue <= 0 ? 10.0 : maxValue * 1.25;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 14, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chi tiêu năm $year',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 17),
                ),
              ),
              _ChartLegend(color: const Color(0xFF9BC27F), label: 'Mục tiêu'),
              const SizedBox(width: 10),
              const _ChartLegend(color: _forest, label: 'Đã chi'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 210,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: chartMax,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF20331D),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = group.x + 1;
                      final label = rodIndex == 0 ? 'Mục tiêu' : 'Đã chi';
                      return BarTooltipItem(
                        'T$month\n$label: ${_compactAmount(rod.toY.toStringAsFixed(0))}',
                        TextStyle(
                          color: Theme.of(context).colorScheme.surfaceContainerLowest,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Theme.of(context).colorScheme.outlineVariant, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
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
                      reservedSize: 38,
                      interval: chartMax / 4,
                      getTitlesWidget: (value, meta) => Text(
                        _axisAmount(value),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'T${value.toInt() + 1}',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (var index = 0; index < 12; index++)
                    BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: targetValues[index],
                          width: 7,
                          color: targetValues[index] <= 0
                              ? const Color(0xFFF4F1ED)
                              : const Color(0xFF9BC27F),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          borderSide: targetValues[index] <= 0
                              ? BorderSide(color: Theme.of(context).colorScheme.outlineVariant)
                              : BorderSide.none,
                        ),
                        BarChartRodData(
                          toY: spentValues[index],
                          width: 7,
                          color:
                              spentValues[index] > targetValues[index] &&
                                  targetValues[index] > 0
                              ? _danger
                              : _forest,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                      barsSpace: 2,
                    ),
                ],
              ),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chạm vào từng cột để xem số tiền chi tiết.',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _BudgetForm extends ConsumerStatefulWidget {
  const _BudgetForm({
    required this.budget,
    required this.initialMonth,
    required this.initialYear,
  });

  final Budget? budget;
  final int? initialMonth;
  final int initialYear;

  @override
  ConsumerState<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends ConsumerState<_BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _monthController;
  late final TextEditingController _yearController;
  late final TextEditingController _thresholdController;
  String? _tagId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.budget?.amount ?? '',
    );
    _monthController = TextEditingController(
      text:
          (widget.budget?.month ?? widget.initialMonth ?? DateTime.now().month)
              .toString(),
    );
    _yearController = TextEditingController(
      text: (widget.budget?.year ?? widget.initialYear).toString(),
    );
    _thresholdController = TextEditingController(
      text: (widget.budget?.warningThresholdPercent ?? 80).toString(),
    );
    _tagId = widget.budget?.tagId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagsProvider);
    return tags.when(
      loading: () => const FlowFiInlineLoading(),
      error: (_, _) => const Text('Không tải được danh mục.'),
      data: (items) {
        final currentTagId = items.any((tag) => tag.id == _tagId)
            ? _tagId
            : null;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlowFiSelectField<String>(
                label: 'Danh mục',
                value: currentTagId ?? '',
                items: [
                  const FlowFiSelectItem<String>(
                    value: '',
                    label: 'Không chọn',
                  ),
                  for (final tag in items)
                    FlowFiSelectItem<String>(value: tag.id, label: tag.name),
                ],
                onChanged: (value) => setState(() {
                  _tagId = value == null || value.isEmpty ? null : value;
                }),
              ),
              const SizedBox(height: 12),
              FlowFiTextField(
                label: 'Hạn mức',
                controller: _amountController,
                validator: requiredAmount,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FlowFiTextField(
                      label: 'Tháng',
                      controller: _monthController,
                      validator: (value) => _intRange(value, 1, 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FlowFiTextField(
                      label: 'Năm',
                      controller: _yearController,
                      validator: (value) => _intRange(value, 2000, 9999),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FlowFiTextField(
                label: 'Cảnh báo khi đạt (%)',
                controller: _thresholdController,
                validator: (value) => _intRange(value, 1, 100),
              ),
              const SizedBox(height: 18),
              FlowFiForuiButton(
                label: widget.budget == null ? 'Tạo ngân sách' : 'Lưu thay đổi',
                icon: Icons.check_rounded,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final notifier = ref.read(budgetsProvider.notifier);
      if (widget.budget == null) {
        await notifier.createBudget(
          tagId: _tagId,
          amount: _amountController.text.trim(),
          month: int.parse(_monthController.text.trim()),
          year: int.parse(_yearController.text.trim()),
          warningThresholdPercent: int.parse(_thresholdController.text.trim()),
        );
      } else {
        await notifier.updateBudget(
          widget.budget!.id,
          tagId: _tagId,
          amount: _amountController.text.trim(),
          month: int.parse(_monthController.text.trim()),
          year: int.parse(_yearController.text.trim()),
          warningThresholdPercent: int.parse(_thresholdController.text.trim()),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        showGenericMutationError(context);
        setState(() => _isSubmitting = false);
      }
    }
  }
}

double _amountValue(String? value) {
  if (value == null) return 0;
  final normalized = value.replaceAll(RegExp(r'[^0-9.-]'), '');
  return double.tryParse(normalized) ?? 0;
}

String _axisAmount(double value) {
  if (value == 0) return '0';
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}tỷ';
  }
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(value >= 10000000 ? 0 : 1)}tr';
  }
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
  return value.toStringAsFixed(0);
}

String _sumBudgetAmounts(List<Budget> budgets) {
  final total = budgets.fold<BigInt>(
    BigInt.zero,
    (sum, budget) => sum + _budgetMinorUnits(budget.amount),
  );
  final major = total ~/ BigInt.from(100);
  final minor = (total % BigInt.from(100)).toString().padLeft(2, '0');
  return '$major.$minor';
}

BigInt _budgetMinorUnits(String value) {
  final parts = value.trim().split('.');
  final major =
      BigInt.tryParse(parts.first.replaceAll(RegExp(r'[^0-9]'), '')) ??
      BigInt.zero;
  final minorText = parts.length > 1 ? '${parts[1]}00'.substring(0, 2) : '00';
  return major * BigInt.from(100) + (BigInt.tryParse(minorText) ?? BigInt.zero);
}

String _compactAmount(String value) {
  final amount = _amountValue(value);
  if (amount >= 1000000000) {
    return '${(amount / 1000000000).toStringAsFixed(1)}tỷ';
  }
  if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(1)}tr';
  }
  if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(0)}k';
  }
  return value;
}

String? _intRange(String? value, int min, int max) {
  final parsed = int.tryParse(value?.trim() ?? '');
  if (parsed == null || parsed < min || parsed > max) {
    return 'Nhập giá trị từ $min đến $max';
  }
  return null;
}
