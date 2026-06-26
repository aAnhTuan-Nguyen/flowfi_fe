final class Budget {
  const Budget({
    required this.id,
    this.tagId,
    required this.amount,
    required this.month,
    required this.year,
    required this.warningThresholdPercent,
    this.tagName,
  });

  final String id;
  final String? tagId;
  final String amount;
  final int month;
  final int year;
  final int warningThresholdPercent;
  final String? tagName;
}
