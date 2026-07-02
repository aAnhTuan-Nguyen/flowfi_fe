import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/budget.dart';
import '../providers/budgets_provider.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  _BudgetView _selectedView = _BudgetView.budgets;

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetsProvider);
    final goals = ref.watch(goalsProvider);

    return FlowFiFeatureScaffold(
      icon: Icons.savings_rounded,
      title: 'Ngân sách',
      subtitle: 'Theo dõi hạn mức tháng và tiến độ tiết kiệm.',
      onRefresh: () async {
        await ref.read(budgetsProvider.notifier).reload();
        await ref.read(goalsProvider.notifier).reload();
      },
      actions: [
        FlowFiButton(
          label: 'Ngân sách',
          onPressed: () => _showBudgetForm(context),
          icon: Icons.add_rounded,
          fullWidth: false,
        ),
        FlowFiIconButton(
          onPressed: () => _showGoalForm(context),
          icon: Icons.flag_outlined,
          tooltip: 'Thêm mục tiêu',
        ),
      ],
      child: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlowFiSegmentedFilter<_BudgetView>(
              values: _BudgetView.values,
              selected: _selectedView,
              labelBuilder: _budgetViewLabel,
              onSelected: (view) => setState(() => _selectedView = view),
            ),
            const SizedBox(height: 10),
            if (_selectedView == _BudgetView.budgets)
              _BudgetSection(
                budgets: budgets,
                onRetry: () => ref.read(budgetsProvider.notifier).reload(),
                onEdit: (budget) => _showBudgetForm(context, budget: budget),
              )
            else
              _GoalSection(
                goals: goals,
                onRetry: () => ref.read(goalsProvider.notifier).reload(),
                onEdit: (goal) => _showGoalForm(context, goal: goal),
                onUpdateProgress: (goal) =>
                    _showGoalForm(context, goal: goal, progress: true),
              ),
          ],
        ),
      ),
    );
  }

  void _showBudgetForm(BuildContext context, {Budget? budget}) {
    showFlowFiFormSheet<void>(
      context: context,
      title: budget == null ? 'Thêm ngân sách' : 'Sửa ngân sách',
      child: _BudgetForm(budget: budget),
    );
  }

  void _showGoalForm(
    BuildContext context, {
    Goal? goal,
    bool progress = false,
  }) {
    showFlowFiFormSheet<void>(
      context: context,
      title: progress
          ? 'Cập nhật tiến độ'
          : goal == null
          ? 'Thêm mục tiêu'
          : 'Sửa mục tiêu',
      child: progress ? _GoalProgressForm(goal: goal!) : _GoalForm(goal: goal),
    );
  }
}

enum _BudgetView { budgets, goals }

String _budgetViewLabel(_BudgetView view) {
  return switch (view) {
    _BudgetView.budgets => 'Ngân sách',
    _BudgetView.goals => 'Mục tiêu',
  };
}

class _BudgetSection extends StatelessWidget {
  const _BudgetSection({
    required this.budgets,
    required this.onRetry,
    required this.onEdit,
  });

  final AsyncValue<List<Budget>> budgets;
  final VoidCallback onRetry;
  final ValueChanged<Budget> onEdit;

  @override
  Widget build(BuildContext context) {
    return budgets.when(
      loading: () => const _InlineLoading(),
      error: (_, _) => _InlineError(onRetry: onRetry),
      data: (items) => items.isEmpty
          ? const _InlineEmpty(message: 'Chưa có ngân sách.')
          : Column(
              children: [
                _BudgetChartCard(budgets: items),
                const SizedBox(height: 10),
                for (final budget in items) ...[
                  _BudgetCard(budget: budget, onEdit: () => onEdit(budget)),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _GoalSection extends StatelessWidget {
  const _GoalSection({
    required this.goals,
    required this.onRetry,
    required this.onEdit,
    required this.onUpdateProgress,
  });

  final AsyncValue<List<Goal>> goals;
  final VoidCallback onRetry;
  final ValueChanged<Goal> onEdit;
  final ValueChanged<Goal> onUpdateProgress;

  @override
  Widget build(BuildContext context) {
    return goals.when(
      loading: () => const _InlineLoading(),
      error: (_, _) => _InlineError(onRetry: onRetry),
      data: (items) => items.isEmpty
          ? const _InlineEmpty(message: 'Chưa có mục tiêu.')
          : Column(
              children: [
                for (final goal in items) ...[
                  _GoalCard(
                    goal: goal,
                    onEdit: () => onEdit(goal),
                    onUpdateProgress: () => onUpdateProgress(goal),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _BudgetChartCard extends StatelessWidget {
  const _BudgetChartCard({required this.budgets});

  final List<Budget> budgets;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final total = budgets.fold<BigInt>(
      BigInt.zero,
      (sum, budget) => sum + _minorUnits(budget.amount),
    );

    return FlowFiCard(
      color: colors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân bổ tháng này',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            '${budgets.length} hạn mức đang theo dõi',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 34,
                        sectionsSpace: 2,
                        startDegreeOffset: -90,
                        sections: [
                          for (var index = 0; index < budgets.length; index++)
                            PieChartSectionData(
                              value: _chartValue(budgets[index], total),
                              title: '',
                              radius: 18,
                              color: _chartColor(index),
                            ),
                        ],
                      ),
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${budgets.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'mục',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    for (var index = 0; index < budgets.length; index++) ...[
                      FlowFiLegendRow(
                        color: _chartColor(index),
                        label: budgets[index].tagName ?? 'Ngân sách',
                        value: budgets[index].amount,
                      ),
                      if (index != budgets.length - 1)
                        const SizedBox(height: 8),
                    ],
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

class _BudgetCard extends ConsumerWidget {
  const _BudgetCard({required this.budget, required this.onEdit});

  final Budget budget;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlowFiCard(
      child: Row(
        children: [
          const _IconBadge(icon: Icons.pie_chart_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budget.tagName ?? 'Ngân sách tháng',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  'Tháng ${budget.month}/${budget.year} · Cảnh báo ${budget.warningThresholdPercent}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FlowFiAmountText(amount: budget.amount, align: TextAlign.end),
          FlowFiActionMenu(
            tooltip: 'Tùy chọn ngân sách',
            actions: [
              FlowFiMenuAction(
                label: 'Sửa',
                icon: Icons.edit_rounded,
                onSelected: onEdit,
              ),
              FlowFiMenuAction(
                label: 'Xóa',
                icon: Icons.delete_outline_rounded,
                destructive: true,
                onSelected: () => _deleteBudget(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBudget(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Xóa ngân sách?',
      message: 'Hạn mức này sẽ bị xóa khỏi FlowFi.',
    );
    if (confirmed) {
      try {
        await ref.read(budgetsProvider.notifier).deleteBudget(budget.id);
      } catch (_) {
        if (context.mounted) {
          showGenericMutationError(context);
        }
      }
    }
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({
    required this.goal,
    required this.onEdit,
    required this.onUpdateProgress,
  });

  final Goal goal;
  final VoidCallback onEdit;
  final VoidCallback onUpdateProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlowFiCard(
      color: FlowFiColors.warmSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconBadge(icon: Icons.flag_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FlowFiStatusBadge(label: _goalStatusLabel(goal.status)),
              FlowFiActionMenu(
                tooltip: 'Tùy chọn mục tiêu',
                actions: [
                  FlowFiMenuAction(
                    label: 'Sửa',
                    icon: Icons.edit_rounded,
                    onSelected: onEdit,
                  ),
                  FlowFiMenuAction(
                    label: 'Cập nhật tiến độ',
                    icon: Icons.trending_up_rounded,
                    onSelected: onUpdateProgress,
                  ),
                  FlowFiMenuAction(
                    label: 'Xóa',
                    icon: Icons.delete_outline_rounded,
                    destructive: true,
                    onSelected: () => _deleteGoal(context, ref),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          FlowFiProgressBar(value: _goalProgress(goal)),
          const SizedBox(height: 8),
          Text(
            '${goal.currentAmount} / ${goal.targetAmount}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Xóa mục tiêu?',
      message: 'Mục tiêu này sẽ bị xóa khỏi FlowFi.',
    );
    if (confirmed) {
      try {
        await ref.read(goalsProvider.notifier).deleteGoal(goal.id);
      } catch (_) {
        if (context.mounted) {
          showGenericMutationError(context);
        }
      }
    }
  }
}

class _BudgetForm extends ConsumerStatefulWidget {
  const _BudgetForm({this.budget});

  final Budget? budget;

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
    final now = DateTime.now();
    _amountController = TextEditingController(
      text: widget.budget?.amount ?? '',
    );
    _monthController = TextEditingController(
      text: (widget.budget?.month ?? now.month).toString(),
    );
    _yearController = TextEditingController(
      text: (widget.budget?.year ?? now.year).toString(),
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
      loading: () => const _InlineLoading(),
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

class _GoalForm extends ConsumerStatefulWidget {
  const _GoalForm({this.goal});

  final Goal? goal;

  @override
  ConsumerState<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<_GoalForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _currentController;
  String? _walletId;
  DateTime? _deadline;
  late GoalStatus _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetController = TextEditingController(
      text: widget.goal?.targetAmount ?? '',
    );
    _currentController = TextEditingController(
      text: widget.goal?.currentAmount ?? '',
    );
    _deadline = widget.goal?.deadline;
    _walletId = widget.goal?.walletId;
    _status = widget.goal?.status == GoalStatus.unknown
        ? GoalStatus.active
        : widget.goal?.status ?? GoalStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    return wallets.when(
      loading: () => const _InlineLoading(),
      error: (_, _) => const Text('Không tải được ví.'),
      data: (items) {
        final currentWalletId = items.any((wallet) => wallet.id == _walletId)
            ? _walletId
            : null;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlowFiSelectField<String>(
                label: 'Ví liên kết',
                value: currentWalletId ?? '',
                items: [
                  const FlowFiSelectItem<String>(
                    value: '',
                    label: 'Không chọn',
                  ),
                  for (final wallet in items)
                    FlowFiSelectItem<String>(
                      value: wallet.id,
                      label: wallet.name,
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                ],
                onChanged: (value) => setState(() {
                  _walletId = value == null || value.isEmpty ? null : value;
                }),
              ),
              const SizedBox(height: 12),
              FlowFiTextField(
                label: 'Tên mục tiêu',
                controller: _nameController,
                validator: requiredText,
              ),
              const SizedBox(height: 12),
              FlowFiTextField(
                label: 'Số tiền mục tiêu',
                controller: _targetController,
                validator: requiredAmount,
              ),
              const SizedBox(height: 12),
              FlowFiTextField(
                label: 'Đã tiết kiệm',
                controller: _currentController,
                validator: optionalAmount,
              ),
              const SizedBox(height: 12),
              FlowFiSelectField<GoalStatus>(
                label: 'Trạng thái',
                value: _status,
                items: const [
                  FlowFiSelectItem(
                    value: GoalStatus.active,
                    label: 'Đang theo dõi',
                    icon: Icons.flag_outlined,
                  ),
                  FlowFiSelectItem(
                    value: GoalStatus.completed,
                    label: 'Hoàn thành',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  FlowFiSelectItem(
                    value: GoalStatus.cancelled,
                    label: 'Đã hủy',
                    icon: Icons.cancel_outlined,
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              FlowFiDateField(
                label: 'Hạn hoàn thành',
                value: _deadline == null
                    ? 'Không chọn'
                    : _dateLabel(_deadline!),
                onTap: _pickDeadline,
              ),
              const SizedBox(height: 18),
              FlowFiForuiButton(
                label: widget.goal == null ? 'Tạo mục tiêu' : 'Lưu thay đổi',
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

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _deadline ?? DateTime.now(),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final notifier = ref.read(goalsProvider.notifier);
      final current = emptyToNull(_currentController.text.trim());
      if (widget.goal == null) {
        await notifier.createGoal(
          walletId: _walletId,
          name: _nameController.text.trim(),
          targetAmount: _targetController.text.trim(),
          currentAmount: current,
          deadline: _deadline,
          status: _status,
        );
      } else {
        await notifier.updateGoal(
          widget.goal!.id,
          walletId: _walletId,
          name: _nameController.text.trim(),
          targetAmount: _targetController.text.trim(),
          currentAmount: current,
          deadline: _deadline,
          status: _status,
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

class _GoalProgressForm extends ConsumerStatefulWidget {
  const _GoalProgressForm({required this.goal});

  final Goal goal;

  @override
  ConsumerState<_GoalProgressForm> createState() => _GoalProgressFormState();
}

class _GoalProgressFormState extends ConsumerState<_GoalProgressForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _currentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentController = TextEditingController(text: widget.goal.currentAmount);
  }

  @override
  void dispose() {
    _currentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlowFiTextField(
            label: 'Đã tiết kiệm',
            controller: _currentController,
            validator: requiredAmount,
          ),
          const SizedBox(height: 18),
          FlowFiForuiButton(
            label: 'Cập nhật tiến độ',
            icon: Icons.check_rounded,
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(goalsProvider.notifier)
          .updateGoalProgress(
            widget.goal.id,
            currentAmount: _currentController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        showGenericMutationError(context);
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FlowFiIconBadge(
      icon: icon,
      tone: FlowFiTone.info,
      size: 42,
      radius: 14,
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const FlowFiInlineLoading();
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FlowFiInlineError(
      message: 'Không tải được dữ liệu.',
      onRetry: onRetry,
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return FlowFiCard(
      color: FlowFiColors.warmSurface,
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

double _goalProgress(Goal goal) {
  final current = _minorUnits(goal.currentAmount);
  final target = _minorUnits(goal.targetAmount);
  if (target <= BigInt.zero) {
    return 0;
  }
  final percent = (current * BigInt.from(10000)) ~/ target;
  final clamped = _clampBigInt(percent, BigInt.zero, BigInt.from(10000));
  return clamped.toInt() / 10000;
}

BigInt _clampBigInt(BigInt value, BigInt min, BigInt max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}

BigInt _minorUnits(String value) {
  final parts = value.split('.');
  final whole = BigInt.tryParse(parts.first.replaceAll(RegExp(r'[^0-9-]'), ''));
  if (whole == null) {
    return BigInt.zero;
  }
  final cents = parts.length > 1
      ? parts[1].padRight(2, '0').substring(0, 2)
      : '00';
  return whole * BigInt.from(100) + BigInt.parse(cents);
}

String _goalStatusLabel(GoalStatus status) {
  return switch (status) {
    GoalStatus.active => 'Đang theo dõi',
    GoalStatus.completed => 'Hoàn thành',
    GoalStatus.cancelled => 'Đã hủy',
    GoalStatus.unknown => 'Không rõ',
  };
}

double _chartValue(Budget budget, BigInt total) {
  if (total <= BigInt.zero) {
    return 1;
  }
  final amount = _minorUnits(budget.amount);
  if (amount <= BigInt.zero) {
    return 0.1;
  }
  return amount.toDouble();
}

Color _chartColor(int index) {
  return FlowFiColors.chartPalette[index % FlowFiColors.chartPalette.length];
}

String _dateLabel(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String? _intRange(String? value, int min, int max) {
  final parsed = int.tryParse(value?.trim() ?? '');
  if (parsed == null || parsed < min || parsed > max) {
    return 'Enter $min-$max';
  }
  return null;
}
