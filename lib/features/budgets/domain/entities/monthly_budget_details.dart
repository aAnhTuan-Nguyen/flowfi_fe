final class MonthlyBudgetDetails {
  const MonthlyBudgetDetails({
    required this.month,
    required this.year,
    required this.targetAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentUsed,
    required this.transactionCount,
    required this.topCategoryName,
    required this.topWalletName,
    required this.categories,
  });

  final int month;
  final int year;
  final String targetAmount;
  final String spentAmount;
  final String remainingAmount;
  final double percentUsed;
  final int transactionCount;
  final String? topCategoryName;
  final String? topWalletName;
  final List<MonthlyBudgetCategoryDetail> categories;
}

final class MonthlyBudgetCategoryDetail {
  const MonthlyBudgetCategoryDetail({
    required this.tagId,
    required this.tagName,
    required this.targetAmount,
    required this.spentAmount,
    required this.percentOfSpend,
    required this.variancePercent,
  });

  final String tagId;
  final String tagName;
  final String targetAmount;
  final String spentAmount;
  final double percentOfSpend;
  final double variancePercent;
}
