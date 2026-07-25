import '../../../../core/finance/decimal_money.dart';
import '../../../../core/finance/money_flow_type.dart';
import 'transaction.dart';

enum ExpenseTrendPeriod { sevenDays, weekly }

final class ExpenseTrendPoint {
  const ExpenseTrendPoint({
    required this.start,
    required this.amountMinorUnits,
  });

  final DateTime start;
  final BigInt amountMinorUnits;
}

final class ExpenseTrend {
  const ExpenseTrend({
    required this.points,
    required this.currentTotalMinorUnits,
    required this.previousTotalMinorUnits,
    required this.changePercent,
  });

  final List<ExpenseTrendPoint> points;
  final BigInt currentTotalMinorUnits;
  final BigInt previousTotalMinorUnits;
  final double changePercent;
}

ExpenseTrend buildExpenseTrend(
  Iterable<Transaction> transactions, {
  required DateTime now,
  required ExpenseTrendPeriod period,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final currentMonday = today.subtract(Duration(days: today.weekday - 1));
  final dailyExpense = <DateTime, BigInt>{};
  for (final transaction in transactions) {
    final date = transaction.date;
    if (date == null ||
        transaction.status != TransactionStatus.confirmed ||
        transaction.type != MoneyFlowType.expense) {
      continue;
    }
    final day = DateTime(date.year, date.month, date.day);
    dailyExpense.update(
      day,
      (value) => value + parseMoneyMinorUnits(transaction.amount),
      ifAbsent: () => parseMoneyMinorUnits(transaction.amount),
    );
  }

  return switch (period) {
    ExpenseTrendPeriod.sevenDays => _dailyTrend(dailyExpense, currentMonday),
    ExpenseTrendPeriod.weekly => _weeklyTrend(dailyExpense, currentMonday),
  };
}

ExpenseTrend _dailyTrend(
  Map<DateTime, BigInt> dailyExpense,
  DateTime currentMonday,
) {
  final points = [
    for (var day = 0; day < 7; day++)
      ExpenseTrendPoint(
        start: currentMonday.add(Duration(days: day)),
        amountMinorUnits:
            dailyExpense[currentMonday.add(Duration(days: day))] ?? BigInt.zero,
      ),
  ];
  final previousMonday = currentMonday.subtract(const Duration(days: 7));
  final previousTotal = _sumRange(dailyExpense, previousMonday, currentMonday);
  return _trend(points, previousTotal);
}

ExpenseTrend _weeklyTrend(
  Map<DateTime, BigInt> dailyExpense,
  DateTime currentMonday,
) {
  final visibleStart = currentMonday.subtract(const Duration(days: 42));
  final points = [
    for (var week = 0; week < 7; week++)
      ExpenseTrendPoint(
        start: visibleStart.add(Duration(days: week * 7)),
        amountMinorUnits: _sumRange(
          dailyExpense,
          visibleStart.add(Duration(days: week * 7)),
          visibleStart.add(Duration(days: (week + 1) * 7)),
        ),
      ),
  ];
  final previousStart = visibleStart.subtract(const Duration(days: 49));
  final previousTotal = _sumRange(dailyExpense, previousStart, visibleStart);
  return _trend(points, previousTotal);
}

ExpenseTrend _trend(List<ExpenseTrendPoint> points, BigInt previousTotal) {
  final currentTotal = points.fold<BigInt>(
    BigInt.zero,
    (sum, point) => sum + point.amountMinorUnits,
  );
  final changePercent = previousTotal == BigInt.zero
      ? currentTotal == BigInt.zero
            ? 0.0
            : 100.0
      : ((currentTotal - previousTotal).toDouble() / previousTotal.toDouble()) *
            100;
  return ExpenseTrend(
    points: points,
    currentTotalMinorUnits: currentTotal,
    previousTotalMinorUnits: previousTotal,
    changePercent: changePercent,
  );
}

BigInt _sumRange(
  Map<DateTime, BigInt> dailyExpense,
  DateTime from,
  DateTime toExclusive,
) {
  var sum = BigInt.zero;
  for (
    var day = from;
    day.isBefore(toExclusive);
    day = day.add(const Duration(days: 1))
  ) {
    sum += dailyExpense[day] ?? BigInt.zero;
  }
  return sum;
}
