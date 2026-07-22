import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../shared/presentation/widgets/crud_helpers.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../../shared/presentation/widgets/forui_controls.dart';
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
    final isIncome = transaction.type == MoneyFlowType.income;
    final tone = isIncome ? FlowFiTone.positive : FlowFiTone.negative;
    final toneColor = flowFiToneStyle(context, tone).foreground;

    return FlowFiListItemCard(
      icon: isIncome
          ? Icons.arrow_downward_rounded
          : Icons.arrow_upward_rounded,
      tone: tone,
      title: transaction.title,
      subtitle: _transactionMeta(transaction),
      trailing: Text(
        _formatAmount(transaction.amount, isIncome),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: toneColor),
        textAlign: TextAlign.end,
      ),
      action: FlowFiActionMenu(
        tooltip: 'Thao tác giao dịch',
        actions: [
          FlowFiMenuAction(
            label: 'Sửa',
            icon: Icons.edit_rounded,
            onSelected: onEdit,
          ),
          if (transaction.status == TransactionStatus.draft)
            FlowFiMenuAction(
              label: 'Xác nhận nháp',
              icon: Icons.check_circle_outline_rounded,
              onSelected: () => _confirm(context, ref),
            ),
          FlowFiMenuAction(
            label: 'Xóa',
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onSelected: () => _delete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(transactionsProvider.notifier)
          .confirmTransaction(transaction.id);
    } catch (_) {
      if (context.mounted) {
        showGenericMutationError(context);
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
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
  String _formatAmount(String amountStr, bool isIncome) {
    final doubleAmount = double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
    final absAmount = doubleAmount.abs();
    
    String formatted;
    if (absAmount >= 1000000) {
      final inMillions = absAmount / 1000000;
      final str = inMillions.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      formatted = '${str.replaceAll('.', ',')}M ₫';
    } else {
      final intAmount = absAmount.truncate();
      final str = intAmount.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(str[i]);
      }
      formatted = '${buffer.toString()} ₫';
    }
    
    return '${isIncome ? '+' : '-'}$formatted';
  }
}

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
    TransactionInputMethod.manual => 'Thủ công',
    TransactionInputMethod.voice => 'Giọng nói',
    TransactionInputMethod.ocr => 'OCR',
    TransactionInputMethod.unknown => 'Không rõ',
  };
  final pending = transaction.isPendingSync ? ' · Đang chờ đồng bộ' : '';
  return '$dateLabel · $status · $input$pending';
}
