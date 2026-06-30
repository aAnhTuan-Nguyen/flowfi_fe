import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_provider.dart';

class TransactionCard extends ConsumerWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onEdit,
  });

  final Transaction transaction;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isIncome = transaction.type == MoneyFlowType.income;
    final toneColor = isIncome
        ? const Color(0xFF4F6F39)
        : const Color(0xFFB84A3F);

    return FlowFiCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: toneColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: toneColor,
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
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${isIncome ? '+' : '-'}${transaction.amount}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: toneColor),
            textAlign: TextAlign.end,
          ),
          PopupMenuButton<_TransactionAction>(
            tooltip: 'Thao tác giao dịch',
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
                    title: 'Xóa giao dịch?',
                    message: 'Giao dịch này sẽ bị xóa khỏi FlowFi.',
                    actionLabel: 'Xóa giao dịch',
                  );
                  if (!confirmed) {
                    return;
                  }
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
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _TransactionAction.edit,
                child: Text('Sửa'),
              ),
              if (transaction.status == TransactionStatus.draft)
                const PopupMenuItem(
                  value: _TransactionAction.confirm,
                  child: Text('Xác nhận nháp'),
                ),
              const PopupMenuItem(
                value: _TransactionAction.delete,
                child: Text('Xóa'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _TransactionAction { edit, confirm, delete }

String _transactionMeta(Transaction transaction) {
  final date = transaction.date;
  final dateLabel = date == null
      ? 'Không có ngày'
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  final status = switch (transaction.status) {
    TransactionStatus.draft => 'Nháp',
    TransactionStatus.confirmed => 'Đã xác nhận',
    TransactionStatus.unknown => 'Không rõ',
  };
  final input = switch (transaction.inputMethod) {
    TransactionInputMethod.manual => 'Manual',
    TransactionInputMethod.voice => 'Voice',
    TransactionInputMethod.ocr => 'Scan',
    TransactionInputMethod.unknown => 'Không rõ',
  };
  return '$dateLabel · $status · $input';
}
