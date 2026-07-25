import 'package:flowfi_fe/features/budgets/data/models/monthly_budget_details_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups legacy unbudgeted categories into Khác with details', () {
    final details = MonthlyBudgetDetailsModel.fromJson({
      'month': 7,
      'year': 2026,
      'targetAmount': '10000000.00',
      'spentAmount': '10680000.00',
      'remainingAmount': '-680000.00',
      'percentUsed': 106.8,
      'transactionCount': 3,
      'categories': [
        {
          'tagId': 'food',
          'tagName': 'Ăn uống',
          'targetAmount': '10000000.00',
          'spentAmount': '10000000.00',
          'percentOfSpend': 93.63,
          'variancePercent': 0,
        },
        {
          'tagId': 'shopping',
          'tagName': 'Mua sắm',
          'targetAmount': '0.00',
          'spentAmount': '500000.00',
          'percentOfSpend': 4.68,
          'variancePercent': 0,
        },
        {
          'tagId': 'entertainment',
          'tagName': 'Giải trí',
          'targetAmount': '0.00',
          'spentAmount': '180000.00',
          'percentOfSpend': 1.69,
          'variancePercent': 0,
        },
      ],
    }).value;

    expect(details.categories, hasLength(2));
    final other = details.categories.last;
    expect(other.tagName, 'Khác');
    expect(other.spentAmount, '680000');
    expect(other.unbudgetedCategories.map((item) => item.tagName), [
      'Mua sắm',
      'Giải trí',
    ]);
  });
}
