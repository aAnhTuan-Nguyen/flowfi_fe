import 'package:flutter/material.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../domain/entities/transaction.dart';

enum TransactionFilter { all, income, expense, draft, confirmed }

extension TransactionFilterLabel on TransactionFilter {
  String get label {
    return switch (this) {
      TransactionFilter.all => 'Tất cả',
      TransactionFilter.income => 'Thu',
      TransactionFilter.expense => 'Chi',
      TransactionFilter.draft => 'Nháp',
      TransactionFilter.confirmed => 'Đã xác nhận',
    };
  }

  bool matches(Transaction transaction) {
    return switch (this) {
      TransactionFilter.all => true,
      TransactionFilter.income => transaction.type == MoneyFlowType.income,
      TransactionFilter.expense => transaction.type == MoneyFlowType.expense,
      TransactionFilter.draft => transaction.status == TransactionStatus.draft,
      TransactionFilter.confirmed =>
        transaction.status == TransactionStatus.confirmed,
    };
  }
}

class TransactionFilterBar extends StatelessWidget {
  const TransactionFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final TransactionFilter selected;
  final ValueChanged<TransactionFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in TransactionFilter.values) ...[
            ChoiceChip(
              label: Text(filter.label),
              selected: selected == filter,
              onSelected: (_) => onSelected(filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
