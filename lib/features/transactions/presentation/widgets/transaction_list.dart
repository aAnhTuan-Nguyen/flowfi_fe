import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/feature_states.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_card.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.transactions,
    required this.onEdit,
    this.isFiltered = false,
  });

  final List<Transaction> transactions;
  final ValueChanged<Transaction> onEdit;
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return FlowFiInlineEmptyState(
        icon: Icons.receipt_long_rounded,
        title: isFiltered ? 'Không có giao dịch phù hợp' : 'Chưa có giao dịch',
        message: isFiltered
            ? 'Đổi bộ lọc để xem các giao dịch khác.'
            : 'Nhấn dấu cộng để nhập nhanh, scan hóa đơn hoặc dùng voice.',
      );
    }

    return Column(
      children: [
        for (final transaction in transactions) ...[
          TransactionCard(
            transaction: transaction,
            onEdit: () => onEdit(transaction),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
