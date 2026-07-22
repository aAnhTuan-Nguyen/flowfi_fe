final class AnnualBudgetMonthSummary {
  const AnnualBudgetMonthSummary({
    required this.month,
    required this.targetAmount,
    required this.spentAmount,
    required this.percentUsed,
    required this.exceededPercent,
  });

  final int month;
  final String targetAmount;
  final String spentAmount;
  final double percentUsed;
  final double exceededPercent;

  bool get isExceeded => exceededPercent > 0;
}
