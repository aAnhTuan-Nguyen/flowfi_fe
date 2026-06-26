enum MoneyFlowType { income, expense, unknown }

extension MoneyFlowTypeApi on MoneyFlowType {
  String get apiValue {
    return switch (this) {
      MoneyFlowType.income => 'Income',
      MoneyFlowType.expense => 'Expense',
      MoneyFlowType.unknown => 'Unknown',
    };
  }
}

MoneyFlowType moneyFlowTypeFromApi(Object? value) {
  return switch (value) {
    'Income' => MoneyFlowType.income,
    'Expense' => MoneyFlowType.expense,
    _ => MoneyFlowType.unknown,
  };
}
