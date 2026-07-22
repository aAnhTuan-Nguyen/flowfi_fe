import 'package:flutter/material.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../shared/presentation/widgets/feature_states.dart';
import '../../domain/entities/transaction.dart';

enum TransactionFilter { all, income, expense }

extension TransactionFilterLabel on TransactionFilter {
  String get label {
    return switch (this) {
      TransactionFilter.all => 'Tất cả',
      TransactionFilter.income => 'Thu',
      TransactionFilter.expense => 'Chi',
    };
  }

  bool matches(Transaction transaction) {
    return switch (this) {
      TransactionFilter.all => true,
      TransactionFilter.income => transaction.type == MoneyFlowType.income,
      TransactionFilter.expense => transaction.type == MoneyFlowType.expense,
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
    return FlowFiSegmentedFilter<TransactionFilter>(
      values: TransactionFilter.values,
      selected: selected,
      labelBuilder: (filter) => filter.label,
      onSelected: onSelected,
    );
  }
}
