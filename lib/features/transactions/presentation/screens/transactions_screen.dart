import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_provider.dart';
import '../../../shared/presentation/widgets/feature_states.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  _TransactionFilter _filter = _TransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    return FlowFiFeatureScaffold(
      icon: Icons.receipt_long_rounded,
      title: 'Transactions',
      subtitle: 'Review the latest confirmed and draft entries.',
      onRefresh: () => ref.read(transactionsProvider.notifier).reload(),
      actions: [
        FilledButton.icon(
          onPressed: () => _showTransactionForm(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add'),
        ),
        IconButton.outlined(
          onPressed: () => _showTagManager(context),
          icon: const Icon(Icons.sell_outlined),
          tooltip: 'Manage tags',
        ),
      ],
      child: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final filter in _TransactionFilter.values)
                  FilterChip(
                    label: Text(_filterLabel(filter)),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            transactions.when(
              loading: () => const _InlineLoading(),
              error: (_, _) => _InlineError(
                onRetry: () => ref.read(transactionsProvider.notifier).reload(),
              ),
              data: (items) {
                final filtered = items.where(_matchesFilter).toList();
                if (filtered.isEmpty) {
                  return const FlowFiCard(
                    color: Color(0xFFFFF6EB),
                    child: Text('No transactions match this view.'),
                  );
                }
                return Column(
                  children: [
                    for (final transaction in filtered) ...[
                      _TransactionCard(
                        transaction: transaction,
                        onEdit: () => _showTransactionForm(
                          context,
                          transaction: transaction,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(Transaction transaction) {
    return switch (_filter) {
      _TransactionFilter.all => true,
      _TransactionFilter.income => transaction.type == MoneyFlowType.income,
      _TransactionFilter.expense => transaction.type == MoneyFlowType.expense,
      _TransactionFilter.draft => transaction.status == TransactionStatus.draft,
      _TransactionFilter.confirmed =>
        transaction.status == TransactionStatus.confirmed,
    };
  }

  void _showTransactionForm(BuildContext context, {Transaction? transaction}) {
    showFlowFiFormSheet<void>(
      context: context,
      title: transaction == null ? 'Add transaction' : 'Edit transaction',
      child: _TransactionForm(transaction: transaction),
    );
  }

  void _showTagManager(BuildContext context) {
    showFlowFiFormSheet<void>(
      context: context,
      title: 'Manage tags',
      child: const _TagManager(),
    );
  }
}

enum _TransactionFilter { all, income, expense, draft, confirmed }

String _filterLabel(_TransactionFilter filter) {
  return switch (filter) {
    _TransactionFilter.all => 'All',
    _TransactionFilter.income => 'Income',
    _TransactionFilter.expense => 'Expense',
    _TransactionFilter.draft => 'Draft',
    _TransactionFilter.confirmed => 'Confirmed',
  };
}

class _TransactionForm extends ConsumerStatefulWidget {
  const _TransactionForm({this.transaction});

  final Transaction? transaction;

  @override
  ConsumerState<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late final TextEditingController _descriptionController;
  String? _walletId;
  String? _tagId;
  late MoneyFlowType _type;
  late TransactionStatus _status;
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
    _status = transaction?.status == TransactionStatus.unknown
        ? TransactionStatus.draft
        : transaction?.status ?? TransactionStatus.draft;
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
      loading: () => const _InlineLoading(),
      error: (_, _) => const Text('Could not load wallets.'),
      data: (walletItems) => tags.when(
        loading: () => const _InlineLoading(),
        error: (_, _) => const Text('Could not load tags.'),
        data: (tagItems) {
          if (walletItems.isEmpty || tagItems.isEmpty) {
            return const Text(
              'Create at least one wallet and one tag before adding transactions.',
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
                DropdownButtonFormField<String>(
                  initialValue: _walletId,
                  decoration: const InputDecoration(labelText: 'Wallet'),
                  items: [
                    for (final wallet in walletItems)
                      DropdownMenuItem(
                        value: wallet.id,
                        child: Text(wallet.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _walletId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _tagId,
                  decoration: const InputDecoration(labelText: 'Tag'),
                  items: [
                    for (final tag in tagItems)
                      DropdownMenuItem(value: tag.id, child: Text(tag.name)),
                  ],
                  onChanged: (value) => setState(() => _tagId = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: requiredText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: requiredAmount,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<MoneyFlowType>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: const [
                          DropdownMenuItem(
                            value: MoneyFlowType.expense,
                            child: Text('Expense'),
                          ),
                          DropdownMenuItem(
                            value: MoneyFlowType.income,
                            child: Text('Income'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _type = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<TransactionStatus>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: TransactionStatus.draft,
                            child: Text('Draft'),
                          ),
                          DropdownMenuItem(
                            value: TransactionStatus.confirmed,
                            child: Text('Confirmed'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _status = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(_formatDate(_date)),
                  trailing: const Icon(Icons.calendar_month_rounded),
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: _merchantController,
                  decoration: const InputDecoration(labelText: 'Merchant'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: Text(
                      widget.transaction == null
                          ? 'Create transaction'
                          : 'Save',
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
          status: _status,
          merchantName: emptyToNull(_merchantController.text.trim()),
          description: emptyToNull(_descriptionController.text.trim()),
        );
      } else {
        await notifier.updateTransaction(
          widget.transaction!.id,
          walletId: _walletId,
          tagId: _tagId,
          title: _titleController.text.trim(),
          amount: _amountController.text.trim(),
          type: _type,
          date: _date,
          status: _status,
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

String _initialId(String? preferredId, Iterable<String> availableIds) {
  if (preferredId != null && availableIds.contains(preferredId)) {
    return preferredId;
  }
  return availableIds.first;
}

class _TagManager extends ConsumerWidget {
  const _TagManager();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);
    return tags.when(
      loading: () => const _InlineLoading(),
      error: (_, _) =>
          _InlineError(onRetry: () => ref.read(tagsProvider.notifier).reload()),
      data: (items) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showFlowFiFormSheet<void>(
                context: context,
                title: 'Add tag',
                child: const _TagForm(),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add tag'),
            ),
          ),
          const SizedBox(height: 12),
          for (final tag in items)
            ListTile(
              title: Text(tag.name),
              subtitle: Text(
                tag.type == MoneyFlowType.income ? 'Income' : 'Expense',
              ),
              trailing: PopupMenuButton<_TagAction>(
                onSelected: (action) async {
                  switch (action) {
                    case _TagAction.edit:
                      await showFlowFiFormSheet<void>(
                        context: context,
                        title: 'Edit tag',
                        child: _TagForm(tag: tag),
                      );
                    case _TagAction.delete:
                      final confirmed = await confirmDestructiveAction(
                        context,
                        title: 'Delete tag?',
                        message: 'This removes the tag from FlowFi.',
                      );
                      if (confirmed) {
                        try {
                          await ref
                              .read(tagsProvider.notifier)
                              .deleteTag(tag.id);
                        } catch (_) {
                          if (context.mounted) {
                            showGenericMutationError(context);
                          }
                        }
                      }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: _TagAction.edit, child: Text('Edit')),
                  PopupMenuItem(
                    value: _TagAction.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum _TagAction { edit, delete }

class _TagForm extends ConsumerStatefulWidget {
  const _TagForm({this.tag});

  final Tag? tag;

  @override
  ConsumerState<_TagForm> createState() => _TagFormState();
}

class _TagFormState extends ConsumerState<_TagForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late MoneyFlowType _type;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name ?? '');
    _type = widget.tag?.type == MoneyFlowType.income
        ? MoneyFlowType.income
        : MoneyFlowType.expense;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: requiredText,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MoneyFlowType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: const [
              DropdownMenuItem(
                value: MoneyFlowType.expense,
                child: Text('Expense'),
              ),
              DropdownMenuItem(
                value: MoneyFlowType.income,
                child: Text('Income'),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(widget.tag == null ? 'Create tag' : 'Save'),
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
      if (widget.tag == null) {
        await ref
            .read(tagsProvider.notifier)
            .createTag(name: _nameController.text.trim(), type: _type);
      } else {
        await ref
            .read(tagsProvider.notifier)
            .updateTag(
              widget.tag!.id,
              name: _nameController.text.trim(),
              type: _type,
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

class _TransactionCard extends ConsumerWidget {
  const _TransactionCard({required this.transaction, required this.onEdit});

  final Transaction transaction;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == MoneyFlowType.income;
    final amountPrefix = isIncome ? '+' : '-';

    return FlowFiCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFF49672A)
                  : const Color(0xFFFFF1E3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isIncome
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: isIncome ? Colors.white : const Color(0xFF49672A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _transactionMeta(transaction),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF757872),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$amountPrefix${transaction.amount}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isIncome
                  ? const Color(0xFF49672A)
                  : const Color(0xFF1B211A),
            ),
            textAlign: TextAlign.end,
          ),
          PopupMenuButton<_TransactionAction>(
            tooltip: 'Transaction actions',
            onSelected: (action) async {
              switch (action) {
                case _TransactionAction.edit:
                  onEdit();
                case _TransactionAction.confirm:
                  try {
                    await ref
                        .read(transactionsProvider.notifier)
                        .confirmTransaction(transaction.id);
                  } catch (_) {
                    if (context.mounted) {
                      showGenericMutationError(context);
                    }
                  }
                case _TransactionAction.delete:
                  final confirmed = await confirmDestructiveAction(
                    context,
                    title: 'Delete transaction?',
                    message: 'This removes the transaction from FlowFi.',
                  );
                  if (confirmed) {
                    try {
                      await ref
                          .read(transactionsProvider.notifier)
                          .deleteTransaction(transaction.id);
                    } catch (_) {
                      if (context.mounted) {
                        showGenericMutationError(context);
                      }
                    }
                  }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _TransactionAction.edit,
                child: Text('Edit'),
              ),
              if (transaction.status == TransactionStatus.draft)
                const PopupMenuItem(
                  value: _TransactionAction.confirm,
                  child: Text('Confirm draft'),
                ),
              const PopupMenuItem(
                value: _TransactionAction.delete,
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _TransactionAction { edit, confirm, delete }

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

String _transactionMeta(Transaction transaction) {
  final date = transaction.date;
  final dateLabel = date == null
      ? 'No date'
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  final status = switch (transaction.status) {
    TransactionStatus.draft => 'Draft',
    TransactionStatus.confirmed => 'Confirmed',
    TransactionStatus.unknown => 'Unknown',
  };
  return '$dateLabel - $status';
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
