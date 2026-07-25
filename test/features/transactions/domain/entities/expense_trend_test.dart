import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/transactions/domain/entities/expense_trend.dart';
import 'package:flowfi_fe/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds Monday-to-Sunday expense bars and compares previous week', () {
    final currentAmounts = [
      '1500000',
      '2200000',
      '900000',
      '2750000',
      '1800000',
      '1100000',
      '950000',
    ];
    final transactions = [
      for (var day = 0; day < currentAmounts.length; day++)
        _expense(
          'current-$day',
          currentAmounts[day],
          DateTime(2026, 7, 20 + day),
        ),
      _expense('previous', '10000000', DateTime(2026, 7, 13)),
      Transaction(
        id: 'income',
        title: 'Income is ignored',
        amount: '50000000',
        type: MoneyFlowType.income,
        date: DateTime(2026, 7, 23),
        status: TransactionStatus.confirmed,
        inputMethod: TransactionInputMethod.manual,
      ),
    ];

    final trend = buildExpenseTrend(
      transactions,
      now: DateTime(2026, 7, 23),
      period: ExpenseTrendPeriod.sevenDays,
    );

    expect(trend.points, hasLength(7));
    expect(trend.points.first.start, DateTime(2026, 7, 20));
    expect(trend.points.last.start, DateTime(2026, 7, 26));
    expect(trend.points[3].amountMinorUnits, BigInt.from(275000000));
    expect(trend.currentTotalMinorUnits, BigInt.from(1120000000));
    expect(trend.previousTotalMinorUnits, BigInt.from(1000000000));
    expect(trend.changePercent, closeTo(12, 0.001));
  });

  test('weekly mode returns seven weekly expense totals', () {
    final trend = buildExpenseTrend(
      [
        _expense('current', '3000000', DateTime(2026, 7, 20)),
        _expense('six-weeks-ago', '1000000', DateTime(2026, 6, 8)),
        _expense('previous-period', '2000000', DateTime(2026, 6, 1)),
      ],
      now: DateTime(2026, 7, 23),
      period: ExpenseTrendPeriod.weekly,
    );

    expect(trend.points, hasLength(7));
    expect(trend.points.first.amountMinorUnits, BigInt.from(100000000));
    expect(trend.points.last.amountMinorUnits, BigInt.from(300000000));
    expect(trend.currentTotalMinorUnits, BigInt.from(400000000));
    expect(trend.previousTotalMinorUnits, BigInt.from(200000000));
  });
}

Transaction _expense(String id, String amount, DateTime date) {
  return Transaction(
    id: id,
    title: id,
    amount: amount,
    type: MoneyFlowType.expense,
    date: date,
    status: TransactionStatus.confirmed,
    inputMethod: TransactionInputMethod.manual,
  );
}
