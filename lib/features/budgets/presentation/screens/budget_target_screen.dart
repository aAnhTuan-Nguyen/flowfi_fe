import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../core/finance/decimal_money.dart';
import '../../../../core/finance/money_flow_type.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../../tags/presentation/widgets/tag_manager_sheet.dart';
import '../../domain/entities/budget.dart';
import '../providers/budgets_provider.dart';

const _targetGreen = Color(0xFF3F752F);
const _targetCanvas = Color(0xFFFFFAF6);

class BudgetTargetScreen extends ConsumerStatefulWidget {
  const BudgetTargetScreen({
    super.key,
    required this.month,
    required this.year,
    required this.budgets,
  });

  final int month;
  final int year;
  final List<Budget> budgets;

  @override
  ConsumerState<BudgetTargetScreen> createState() => _BudgetTargetScreenState();
}

class _BudgetTargetScreenState extends ConsumerState<BudgetTargetScreen> {
  late int _month;
  late int _year;
  late int _warningThreshold;
  late Map<String, String> _allocations;
  late Map<String, String> _savedAllocations;
  bool _saving = false;
  bool _allowPop = false;
  bool _discardDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _month = widget.month;
    _year = widget.year;
    _warningThreshold =
        widget.budgets.firstOrNull?.warningThresholdPercent ?? 80;
    _allocations = {
      for (final budget in widget.budgets)
        if (budget.tagId != null) budget.tagId!: budget.amount,
    };
    _savedAllocations = Map<String, String>.of(_allocations);
  }

  bool get _hasUnsavedChanges =>
      !_sameAllocations(_allocations, _savedAllocations);

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagsProvider);
    final allocated = _allocations.values.fold(
      BigInt.zero,
      (sum, value) => sum + _minorUnits(value),
    );
    final allocationCount = _allocations.values
        .where((value) => _minorUnits(value) > BigInt.zero)
        .length;

    return PopScope<Object?>(
      canPop: _allowPop || (!_hasUnsavedChanges && !_saving),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_saving) unawaited(_requestExit());
      },
      child: Scaffold(
        backgroundColor: _targetCanvas,
        appBar: AppBar(
          backgroundColor: _targetCanvas,
          leading: IconButton(
            key: const Key('target-back-button'),
            onPressed: _saving ? null : _requestExit,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Thiết lập Target'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip:
                  'Target là tổng hạn mức chi tiêu của tháng và được phân bổ theo danh mục.',
              onPressed: _showHelp,
              icon: const Icon(Icons.help_outline_rounded),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Đặt mục tiêu chi tiêu cho tháng $_month / $_year',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF716C66)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: _MonthPicker(
                          month: _month,
                          year: _year,
                          onChanged: _changeMonth,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TargetSummary(
                        allocated: allocated,
                        allocationCount: allocationCount,
                      ),
                      const SizedBox(height: 12),
                      const _TargetExplanation(),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Phân bổ theo danh mục',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          TextButton.icon(
                            key: const Key('add-target-category'),
                            onPressed: () => showCreateTagForm(context),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Thêm danh mục'),
                            style: TextButton.styleFrom(
                              foregroundColor: _targetGreen,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      tags.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, _) => const Text('Không tải được danh mục.'),
                        data: (items) => _CategoryList(
                          tags: items
                              .where((tag) => tag.type == MoneyFlowType.expense)
                              .toList(),
                          allocations: _allocations,
                          onEdit: _editAllocation,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14172015),
                      blurRadius: 18,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('target-cancel-button'),
                        onPressed: _saving ? null : _requestExit,
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Lưu Target'),
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

  Future<void> _requestExit() async {
    if (!await _confirmDiscardChanges()) return;
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<bool> _confirmDiscardChanges({
    String message =
        'Bạn có thay đổi Target chưa được lưu. Nếu rời khỏi trang, các thay đổi này sẽ bị mất.',
  }) async {
    if (!_hasUnsavedChanges) return true;
    if (_discardDialogVisible) return false;

    _discardDialogVisible = true;
    try {
      return await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Thay đổi chưa được lưu'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Tiếp tục chỉnh sửa'),
                ),
                FilledButton(
                  key: const Key('discard-target-changes'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(dialogContext).colorScheme.error,
                    foregroundColor: Theme.of(
                      dialogContext,
                    ).colorScheme.onError,
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Bỏ thay đổi'),
                ),
              ],
            ),
          ) ??
          false;
    } finally {
      _discardDialogVisible = false;
    }
  }

  bool _sameAllocations(
    Map<String, String> current,
    Map<String, String> saved,
  ) {
    final keys = <String>{...current.keys, ...saved.keys};
    for (final key in keys) {
      if (_minorUnits(current[key] ?? '') != _minorUnits(saved[key] ?? '')) {
        return false;
      }
    }
    return true;
  }

  Future<void> _changeMonth(({int month, int year}) value) async {
    if (_hasUnsavedChanges) {
      final discard = await _confirmDiscardChanges(
        message:
            'Bạn có thay đổi Target chưa được lưu. Nếu chuyển tháng, các thay đổi này sẽ bị mất.',
      );
      if (!discard || !mounted) return;
    }
    setState(() {
      _month = value.month;
      _year = value.year;
      final allBudgets =
          ref.read(budgetsProvider).asData?.value ?? widget.budgets;
      final targetBudgets = allBudgets.where(
        (b) => b.month == _month && b.year == _year,
      );
      _allocations = {
        for (final budget in targetBudgets)
          if (budget.tagId != null) budget.tagId!: budget.amount,
      };
      _savedAllocations = Map<String, String>.of(_allocations);
    });
  }

  Future<void> _editAllocation(Tag tag) async {
    final value = await _askAmount(tag.name, _allocations[tag.id] ?? '');
    if (value == null) return;
    setState(() {
      if (_minorUnits(value) <= BigInt.zero) {
        _allocations.remove(tag.id);
      } else {
        _allocations[tag.id] = value;
      }
    });
  }

  Future<String?> _askAmount(String title, String initialValue) async {
    return showDialog<String>(
      context: context,
      builder: (_) => _AmountDialog(title: title, initialValue: initialValue),
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thiết lập Target'),
        content: const Text(
          'Đặt tổng hạn mức chi tiêu của tháng, sau đó phân bổ một phần hoặc toàn bộ hạn mức cho từng danh mục.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final allocated = _allocations.values.fold(
      BigInt.zero,
      (sum, value) => sum + _minorUnits(value),
    );
    if (allocated <= BigInt.zero) {
      _showMessage('Hãy phân bổ ngân sách cho ít nhất một danh mục.');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(budgetsProvider.notifier)
          .saveTarget(
            month: _month,
            year: _year,
            warningThresholdPercent: _warningThreshold,
            allocations: [
              for (final entry in _allocations.entries)
                BudgetAllocation(tagId: entry.key, amount: entry.value),
            ],
          );

      ref.invalidate(
        monthlyBudgetDetailsProvider((month: _month, year: _year)),
      );
      ref.invalidate(annualBudgetSummaryProvider(_year));

      if (mounted) {
        setState(() {
          _savedAllocations = Map<String, String>.of(_allocations);
          _saving = false;
          _allowPop = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pop((month: _month, year: _year));
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        showGenericMutationError(context);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({required this.title, required this.initialValue});

  final String title;
  final String initialValue;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final editableAmount = normalizeEditableMoneyAmount(widget.initialValue);
    _controller = TextEditingController(text: editableAmount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || editableAmount.isEmpty) {
        return;
      }
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: editableAmount.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          TextInputFormatter.withFunction((oldValue, newValue) {
            return RegExp(r'^\d*(\.\d{0,2})?$').hasMatch(newValue.text)
                ? newValue
                : oldValue;
          }),
        ],
        decoration: const InputDecoration(labelText: 'Số tiền'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            normalizeEditableMoneyAmount(_controller.text),
          ),
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({
    required this.month,
    required this.year,
    required this.onChanged,
  });
  final int month;
  final int year;
  final ValueChanged<({int month, int year})> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      initialValue: month,
      onSelected: (value) => onChanged((month: value, year: year)),
      itemBuilder: (_) => [
        for (var value = 1; value <= 12; value++)
          PopupMenuItem(value: value, child: Text('Tháng $value / $year')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE7E1DB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_outlined, size: 18),
            const SizedBox(width: 8),
            Text('T$month $year'),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}

class _TargetSummary extends StatelessWidget {
  const _TargetSummary({
    required this.allocated,
    required this.allocationCount,
  });
  final BigInt allocated;
  final int allocationCount;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ngân sách mục tiêu'),
          const SizedBox(height: 5),
          Text(
            '${_formatMinorUnits(allocated)}đ',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: _targetGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Tự động tính từ tổng các danh mục bên dưới',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.calculate_outlined,
                size: 18,
                color: _targetGreen,
              ),
              const SizedBox(width: 7),
              Text(
                allocationCount == 0
                    ? 'Chưa có danh mục được phân bổ'
                    : 'Tổng cộng từ $allocationCount danh mục đã phân bổ',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: _targetGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetExplanation extends StatelessWidget {
  const _TargetExplanation();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7E5CD)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE8F2E1),
            foregroundColor: _targetGreen,
            child: Icon(Icons.auto_awesome_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cách tính Target',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _targetGreen,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Target tháng bằng tổng ngân sách bạn phân bổ cho các danh mục.',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF687063),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.tags,
    required this.allocations,
    required this.onEdit,
  });
  final List<Tag> tags;
  final Map<String, String> allocations;
  final ValueChanged<Tag> onEdit;
  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const _SurfaceCard(child: Text('Chưa có danh mục chi tiêu.'));
    }
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < tags.length; index++) ...[
            Material(
              color: Colors.transparent,
              child: ListTile(
                dense: true,
                onTap: () => onEdit(tags[index]),
                leading: CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFFEAF2E5),
                  foregroundColor: _targetGreen,
                  child: Icon(_categoryIcon(tags[index].name), size: 18),
                ),
                title: Text(tags[index].name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      allocations[tags[index].id] == null
                          ? '—'
                          : '${_formatMoney(allocations[tags[index].id]!)}đ',
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: _targetGreen),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
              ),
            ),
            if (index < tags.length - 1) const Divider(height: 1, indent: 54),
          ],
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      boxShadow: [
        BoxShadow(
          color: Color(0x0E172015),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: child,
  );
}

BigInt _minorUnits(String value) {
  final normalized = value.replaceAll(RegExp(r'[^0-9.]'), '');
  final parts = normalized.split('.');
  final whole = BigInt.tryParse(parts.first) ?? BigInt.zero;
  final minor = parts.length > 1 ? '${parts[1]}00'.substring(0, 2) : '00';
  return whole * BigInt.from(100) + BigInt.tryParse(minor)!;
}

String _formatMoney(String value) => _formatMinorUnits(_minorUnits(value));

String _formatMinorUnits(BigInt value) {
  final digits = (value ~/ BigInt.from(100)).toString();
  return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
}

IconData _categoryIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('ăn') || lower.contains('food')) {
    return Icons.restaurant_rounded;
  }
  if (lower.contains('chuyển') || lower.contains('transport')) {
    return Icons.directions_car_rounded;
  }
  if (lower.contains('hóa') || lower.contains('bill')) {
    return Icons.receipt_long_rounded;
  }
  if (lower.contains('mua') || lower.contains('shop')) {
    return Icons.shopping_bag_outlined;
  }
  if (lower.contains('giải') || lower.contains('game')) {
    return Icons.sports_esports_outlined;
  }
  return Icons.more_horiz_rounded;
}
