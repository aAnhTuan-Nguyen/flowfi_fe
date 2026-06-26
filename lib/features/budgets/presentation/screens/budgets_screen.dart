import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/budget.dart';
import '../providers/budgets_provider.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetsProvider);
    final goals = ref.watch(goalsProvider);

    return FlowFiFeatureScaffold(
      icon: Icons.savings_rounded,
      title: 'Budgets',
      subtitle: 'Watch monthly limits and savings progress.',
      onRefresh: () async {
        await ref.read(budgetsProvider.notifier).reload();
        await ref.read(goalsProvider.notifier).reload();
      },
      actions: [
        FilledButton.icon(
          onPressed: () => _showBudgetForm(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Budget'),
        ),
        IconButton.outlined(
          onPressed: () => _showGoalForm(context),
          icon: const Icon(Icons.flag_outlined),
          tooltip: 'Add goal',
        ),
      ],
      child: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: 'Monthly Limits',
              onRetry: () => ref.read(budgetsProvider.notifier).reload(),
            ),
            const SizedBox(height: 10),
            budgets.when(
              loading: () => const _InlineLoading(),
              error: (_, _) => _InlineError(
                onRetry: () => ref.read(budgetsProvider.notifier).reload(),
              ),
              data: (items) => items.isEmpty
                  ? const _InlineEmpty(message: 'No budgets found.')
                  : Column(
                      children: [
                        for (final budget in items) ...[
                          _BudgetCard(
                            budget: budget,
                            onEdit: () =>
                                _showBudgetForm(context, budget: budget),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 14),
            _SectionTitle(
              title: 'Goals',
              onRetry: () => ref.read(goalsProvider.notifier).reload(),
            ),
            const SizedBox(height: 10),
            goals.when(
              loading: () => const _InlineLoading(),
              error: (_, _) => _InlineError(
                onRetry: () => ref.read(goalsProvider.notifier).reload(),
              ),
              data: (items) => items.isEmpty
                  ? const _InlineEmpty(message: 'No goals found.')
                  : Column(
                      children: [
                        for (final goal in items) ...[
                          _GoalCard(
                            goal: goal,
                            onEdit: () => _showGoalForm(context, goal: goal),
                            onUpdateProgress: () => _showGoalForm(
                              context,
                              goal: goal,
                              progress: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetForm(BuildContext context, {Budget? budget}) {
    showFlowFiFormSheet<void>(
      context: context,
      title: budget == null ? 'Add budget' : 'Edit budget',
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
          ? 'Update progress'
          : goal == null
          ? 'Add goal'
          : 'Edit goal',
      child: progress ? _GoalProgressForm(goal: goal!) : _GoalForm(goal: goal),
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
                  budget.tagName ?? 'Monthly budget',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  '${budget.month}/${budget.year} - Warn at ${budget.warningThresholdPercent}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF757872),
                  ),
                ),
              ],
            ),
          ),
          Text(budget.amount, style: Theme.of(context).textTheme.titleMedium),
          PopupMenuButton<_CardAction>(
            onSelected: (action) async {
              switch (action) {
                case _CardAction.edit:
                  onEdit();
                case _CardAction.delete:
                  final confirmed = await confirmDestructiveAction(
                    context,
                    title: 'Delete budget?',
                    message: 'This removes the budget from FlowFi.',
                  );
                  if (confirmed) {
                    try {
                      await ref
                          .read(budgetsProvider.notifier)
                          .deleteBudget(budget.id);
                    } catch (_) {
                      if (context.mounted) {
                        showGenericMutationError(context);
                      }
                    }
                  }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: _CardAction.edit, child: Text('Edit')),
              PopupMenuItem(value: _CardAction.delete, child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
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
      color: const Color(0xFFFFF6EB),
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
              Text(_goalStatusLabel(goal.status)),
              PopupMenuButton<_GoalAction>(
                onSelected: (action) async {
                  switch (action) {
                    case _GoalAction.edit:
                      onEdit();
                    case _GoalAction.progress:
                      onUpdateProgress();
                    case _GoalAction.delete:
                      final confirmed = await confirmDestructiveAction(
                        context,
                        title: 'Delete goal?',
                        message: 'This removes the goal from FlowFi.',
                      );
                      if (confirmed) {
                        try {
                          await ref
                              .read(goalsProvider.notifier)
                              .deleteGoal(goal.id);
                        } catch (_) {
                          if (context.mounted) {
                            showGenericMutationError(context);
                          }
                        }
                      }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: _GoalAction.edit, child: Text('Edit')),
                  PopupMenuItem(
                    value: _GoalAction.progress,
                    child: Text('Update progress'),
                  ),
                  PopupMenuItem(
                    value: _GoalAction.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: _goalProgress(goal),
              backgroundColor: const Color(0xFFE4DED4),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF49672A)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${goal.currentAmount} saved of ${goal.targetAmount}',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: const Color(0xFF757872)),
          ),
        ],
      ),
    );
  }
}

enum _CardAction { edit, delete }

enum _GoalAction { edit, progress, delete }

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
      error: (_, _) => const Text('Could not load tags.'),
      data: (items) {
        final currentTagId = items.any((tag) => tag.id == _tagId)
            ? _tagId
            : null;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: currentTagId,
                decoration: const InputDecoration(labelText: 'Tag optional'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No tag'),
                  ),
                  for (final tag in items)
                    DropdownMenuItem<String?>(
                      value: tag.id,
                      child: Text(tag.name),
                    ),
                ],
                onChanged: (value) => setState(() => _tagId = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: requiredAmount,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _monthController,
                      decoration: const InputDecoration(labelText: 'Month'),
                      validator: (value) => _intRange(value, 1, 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(labelText: 'Year'),
                      validator: (value) => _intRange(value, 2000, 9999),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _thresholdController,
                decoration: const InputDecoration(
                  labelText: 'Warning threshold',
                ),
                validator: (value) => _intRange(value, 1, 100),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Text(widget.budget == null ? 'Create budget' : 'Save'),
                ),
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
      error: (_, _) => const Text('Could not load wallets.'),
      data: (items) {
        final currentWalletId = items.any((wallet) => wallet.id == _walletId)
            ? _walletId
            : null;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: currentWalletId,
                decoration: const InputDecoration(labelText: 'Wallet optional'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No wallet'),
                  ),
                  for (final wallet in items)
                    DropdownMenuItem<String?>(
                      value: wallet.id,
                      child: Text(wallet.name),
                    ),
                ],
                onChanged: (value) => setState(() => _walletId = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetController,
                decoration: const InputDecoration(labelText: 'Target amount'),
                validator: requiredAmount,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currentController,
                decoration: const InputDecoration(labelText: 'Current amount'),
                validator: optionalAmount,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<GoalStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(
                    value: GoalStatus.active,
                    child: Text('Active'),
                  ),
                  DropdownMenuItem(
                    value: GoalStatus.completed,
                    child: Text('Completed'),
                  ),
                  DropdownMenuItem(
                    value: GoalStatus.cancelled,
                    child: Text('Cancelled'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Deadline optional'),
                subtitle: Text(
                  _deadline == null ? 'No deadline' : _dateLabel(_deadline!),
                ),
                trailing: const Icon(Icons.calendar_month_rounded),
                onTap: _pickDeadline,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Text(widget.goal == null ? 'Create goal' : 'Save'),
                ),
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
          TextFormField(
            controller: _currentController,
            decoration: const InputDecoration(labelText: 'Current amount'),
            validator: requiredAmount,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: const Text('Update progress'),
            ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onRetry});

  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        IconButton(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1DA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: const Color(0xFF49672A), size: 22),
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FlowFiCard(
      child: Row(
        children: [
          const Expanded(child: Text('Could not load this section.')),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return FlowFiCard(
      color: const Color(0xFFFFF6EB),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF757872)),
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
    GoalStatus.active => 'Active',
    GoalStatus.completed => 'Done',
    GoalStatus.cancelled => 'Cancelled',
    GoalStatus.unknown => 'Unknown',
  };
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
