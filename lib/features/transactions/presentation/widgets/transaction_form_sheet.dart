import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../sync/sync_status_provider.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../../wallets/domain/entities/wallet.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
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
          _tagId ??= _initialId(
            widget.transaction?.tagId,
            tagItems.map((tag) => tag.id),
          );

          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.transaction == null)
                  DropdownButtonFormField<String>(
                    initialValue: _walletId,
                    decoration: const InputDecoration(labelText: 'Ví'),
                    items: [
                      for (final wallet in walletItems)
                        DropdownMenuItem(
                          value: wallet.id,
                          child: Text(wallet.name),
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
                DropdownButtonFormField<String>(
                  initialValue: _tagId,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: [
                    for (final tag in tagItems)
                      DropdownMenuItem(value: tag.id, child: Text(tag.name)),
                  ],
                  onChanged: (value) => setState(() => _tagId = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tên giao dịch'),
                  validator: requiredText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Số tiền'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: requiredAmount,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MoneyFlowType>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Loại'),
                  items: const [
                    DropdownMenuItem(
                      value: MoneyFlowType.expense,
                      child: Text('Chi'),
                    ),
                    DropdownMenuItem(
                      value: MoneyFlowType.income,
                      child: Text('Thu'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _type = value);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ngày'),
                  subtitle: Text(_formatDate(_date)),
                  trailing: const Icon(Icons.calendar_month_rounded),
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: _merchantController,
                  decoration: const InputDecoration(labelText: 'Người bán'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                  maxLines: 2,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: Text(
                      widget.transaction == null
                          ? 'Tạo giao dịch'
                          : 'Lưu thay đổi',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _walletId == null ||
        _tagId == null) {
      return;
    }
    setState(() => _isSubmitting = true);
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
        ref.invalidate(syncStatusProvider);
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
      if (mounted) Navigator.of(context).pop();
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

    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
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

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
