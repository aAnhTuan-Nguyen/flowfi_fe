import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
import '../../../sync/sync_status_provider.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../../wallets/domain/entities/wallet.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
import '../../../budgets/presentation/providers/budgets_provider.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_provider.dart';

class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({super.key, this.transaction});

  final Transaction? transaction;

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late final TextEditingController _descriptionController;
  String? _walletId;
  String? _tagId;
  late MoneyFlowType _type;
  late DateTime _date;
  bool _isSubmitting = false;
  bool _showNote = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _titleController = TextEditingController(text: transaction?.title ?? '');
    _amountController = TextEditingController(text: transaction?.amount ?? '');
    _merchantController = TextEditingController(
      text: transaction?.merchantName ?? '',
    );
    _descriptionController = TextEditingController(
      text: transaction?.description ?? '',
    );
    _type = transaction?.type == MoneyFlowType.unknown
        ? MoneyFlowType.expense
        : transaction?.type ?? MoneyFlowType.expense;
    _date = transaction?.date ?? DateTime.now();
    _showNote = _descriptionController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _merchantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final tags = ref.watch(tagsProvider);

    return wallets.when(
      loading: () => const FlowFiInlineLoading(label: 'Đang tải ví'),
      error: (_, _) => const Text('Không tải được ví.'),
      data: (walletItems) => tags.when(
        loading: () => const FlowFiInlineLoading(label: 'Đang tải danh mục'),
        error: (_, _) => const Text('Không tải được danh mục.'),
        data: (tagItems) {
          if (walletItems.isEmpty || tagItems.isEmpty) {
            return const Text(
              'Tạo ít nhất một ví và một danh mục trước khi thêm giao dịch.',
            );
          }
          _walletId ??= _initialId(
            widget.transaction?.walletId,
            walletItems.map((wallet) => wallet.id),
          );
          
          final filteredTagItems = tagItems.where((tag) => tag.type == _type).toList();
          if (filteredTagItems.isNotEmpty) {
            _tagId ??= _initialId(
              widget.transaction?.tagId,
              filteredTagItems.map((tag) => tag.id),
            );
            if (!filteredTagItems.any((tag) => tag.id == _tagId)) {
              _tagId = filteredTagItems.first.id;
            }
          } else {
            _tagId = null;
          }

          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loại giao dịch',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _type = MoneyFlowType.income;
                                  _tagId = null;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _type == MoneyFlowType.income
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Thu',
                                  style: TextStyle(
                                    color: _type == MoneyFlowType.income
                                        ? Theme.of(context).colorScheme.surface
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _type = MoneyFlowType.expense;
                                  _tagId = null;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _type == MoneyFlowType.expense
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Chi',
                                  style: TextStyle(
                                    color: _type == MoneyFlowType.expense
                                        ? Theme.of(context).colorScheme.surface
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.transaction == null)
                  FlowFiSelectField<String>(
                    label: 'Ví',
                    value: _walletId,
                    items: [
                      for (final wallet in walletItems)
                        FlowFiSelectItem(
                          value: wallet.id,
                          label: wallet.name,
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                    ],
                    onChanged: (value) => setState(() => _walletId = value),
                  )
                else
                  _ReadOnlyField(
                    label: 'Ví',
                    value: _walletName(_walletId, walletItems),
                  ),
                const SizedBox(height: 12),
                FlowFiSelectField<String>(
                  label: 'Danh mục',
                  value: _tagId,
                  items: [
                    for (final tag in filteredTagItems)
                      FlowFiSelectItem(
                        value: tag.id,
                        label: tag.name,
                        icon: tag.name.toLowerCase().contains('ăn')
                            ? Icons.local_cafe_outlined
                            : Icons.label_outlined,
                      ),
                  ],
                  onChanged: (value) => setState(() => _tagId = value),
                ),
                const SizedBox(height: 12),
                FlowFiTextField(
                  label: 'Tên giao dịch',
                  hint: 'Nhập tên giao dịch',
                  controller: _titleController,
                  validator: requiredText,
                ),
                const SizedBox(height: 12),
                FlowFiTextField(
                  label: 'Số tiền',
                  hint: 'Nhập số tiền',
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: requiredAmount,
                ),
                const SizedBox(height: 24),
                const _DashedDivider(),
                const SizedBox(height: 24),
                if (_showNote)
                  FlowFiTextField(
                    label: 'Ghi chú',
                    controller: _descriptionController,
                    maxLines: 2,
                  )
                else
                  InkWell(
                    onTap: () => setState(() => _showNote = true),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Thêm ghi chú',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                FlowFiButton(
                  label: widget.transaction == null
                      ? 'Tạo giao dịch'
                      : 'Lưu thay đổi',
                  icon: Icons.check_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _walletId == null ||
        _tagId == null) {
      return;
    }
    setState(() => _isSubmitting = true);
    final typeLabel = _type == MoneyFlowType.income ? 'thu' : 'chi';
    try {
      final notifier = ref.read(transactionsProvider.notifier);
      if (widget.transaction == null) {
        await notifier.createTransaction(
          walletId: _walletId!,
          tagId: _tagId!,
          title: _titleController.text.trim(),
          amount: _amountController.text.trim(),
          type: _type,
          date: _date,
          status: TransactionStatus.confirmed,
          inputMethod: TransactionInputMethod.manual,
          merchantName: emptyToNull(_merchantController.text.trim()),
          description: emptyToNull(_descriptionController.text.trim()),
        );
      } else {
        await notifier.updateTransaction(
          widget.transaction!.id,
          tagId: _tagId,
          title: _titleController.text.trim(),
          amount: _amountController.text.trim(),
          type: _type,
          date: _date,
          merchantName: emptyToNull(_merchantController.text.trim()),
          description: emptyToNull(_descriptionController.text.trim()),
        );
      }

      ref.invalidate(syncStatusProvider);
      ref.invalidate(notificationsProvider);
      ref.invalidate(walletsProvider);
      ref.invalidate(budgetsProvider);
      ref.invalidate(monthlyBudgetDetailsProvider);
      ref.invalidate(annualBudgetSummaryProvider);
      ref.invalidate(monthlyTransactionsProvider);
      final isNew = widget.transaction == null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isNew
                      ? Icons.check_circle_rounded
                      : Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isNew
                        ? 'Giao dịch $typeLabel đã được tạo'
                        : 'Giao dịch đã được cập nhật',
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        showGenericMutationError(context);
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colors.onSurface),
          ),
        ],
      ),
    );
  }
}

String _initialId(String? preferredId, Iterable<String> availableIds) {
  if (preferredId != null && availableIds.contains(preferredId)) {
    return preferredId;
  }
  return availableIds.first;
}

String _walletName(String? walletId, Iterable<Wallet> wallets) {
  for (final wallet in wallets) {
    if (wallet.id == walletId) {
      return wallet.name;
    }
  }
  return 'Ví hiện tại';
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
