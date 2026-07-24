import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
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
    final month = ref.watch(transactionsMonthProvider);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          ref.read(transactionsProvider.notifier).loadMore();
        }
        return false;
      },
      child: FlowFiFeatureScaffold(
      icon: Icons.receipt_long_rounded,
      title: 'Giao dịch',
      subtitle: 'Duyệt giao dịch mới, nháp và đã xác nhận.',
      onRefresh: () => ref.read(transactionsProvider.notifier).reload(),
      actions: [
        FlowFiButton(
          label: '',
          onPressed: () => _showTransactionForm(context),
          icon: Icons.add_rounded,
          fullWidth: false,
        ),
        FlowFiIconButton(
          onPressed: () => _showTagManager(context),
          icon: Icons.sell_outlined,
          tooltip: 'Quản lý danh mục',
        ),
      ],
      child: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    ref.read(transactionsMonthProvider.notifier).setMonth(
                        DateTime(month.year, month.month - 1));
                  },
                ),
                Text(
                  'Tháng ${month.month}/${month.year}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    ref.read(transactionsMonthProvider.notifier).setMonth(
                        DateTime(month.year, month.month + 1));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
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
    ));
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
          FlowFiButton(
            label: 'Thử lại',
            onPressed: onRetry,
            fullWidth: false,
            variant: FlowFiButtonVariant.ghost,
          ),
        ],
      ),
    );
  }
}
