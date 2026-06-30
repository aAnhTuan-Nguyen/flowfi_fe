import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai_processing/presentation/widgets/image_transaction_import_sheet.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../tags/presentation/widgets/tag_manager_sheet.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_provider.dart';
import '../widgets/transaction_filter_bar.dart';
import '../widgets/transaction_form_sheet.dart';
import '../widgets/transaction_list.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionFilter _filter = TransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    return FlowFiFeatureScaffold(
      icon: Icons.receipt_long_rounded,
      title: 'Giao dịch',
      subtitle: 'Duyệt giao dịch mới, nháp và đã xác nhận.',
      onRefresh: () => ref.read(transactionsProvider.notifier).reload(),
      actions: [
        IconButton.outlined(
          onPressed: () => _showImageImport(context),
          icon: const Icon(Icons.document_scanner_rounded),
          tooltip: 'Quét hóa đơn',
        ),
        FilledButton.icon(
          onPressed: () => _showTransactionForm(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Thêm'),
        ),
        IconButton.outlined(
          onPressed: () => _showTagManager(context),
          icon: const Icon(Icons.sell_outlined),
          tooltip: 'Quản lý danh mục',
        ),
      ],
      child: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TransactionFilterBar(
              selected: _filter,
              onSelected: (filter) => setState(() => _filter = filter),
            ),
            const SizedBox(height: 12),
            transactions.when(
              loading: () =>
                  const FlowFiInlineLoading(label: 'Đang tải giao dịch'),
              error: (_, _) => _InlineError(
                onRetry: () => ref.read(transactionsProvider.notifier).reload(),
              ),
              data: (items) => TransactionList(
                transactions: items.where(_filter.matches).toList(),
                isFiltered: _filter != TransactionFilter.all,
                onEdit: (transaction) =>
                    _showTransactionForm(context, transaction: transaction),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionForm(BuildContext context, {Transaction? transaction}) {
    showFlowFiFormSheet<void>(
      context: context,
      title: transaction == null ? 'Thêm giao dịch' : 'Sửa giao dịch',
      child: TransactionFormSheet(transaction: transaction),
    );
  }

  void _showTagManager(BuildContext context) {
    showFlowFiFormSheet<void>(
      context: context,
      title: 'Quản lý danh mục',
      child: const TagManagerSheet(),
    );
  }

  void _showImageImport(BuildContext context) {
    showFlowFiFormSheet<void>(
      context: context,
      title: 'Quét hóa đơn',
      child: const ImageTransactionImportSheet(),
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
          const Expanded(child: Text('Không tải được giao dịch.')),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
