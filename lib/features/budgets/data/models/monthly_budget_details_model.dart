import '../../../../core/finance/decimal_money.dart';
import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/monthly_budget_details.dart';

final class MonthlyBudgetDetailsModel {
  const MonthlyBudgetDetailsModel(this.value);

  final MonthlyBudgetDetails value;

  factory MonthlyBudgetDetailsModel.fromJson(JsonMap json) {
    final rawCategories = json['categories'];
    final categories = rawCategories is List ? rawCategories : const [];
    final parsedCategories = [
      for (final item in categories)
        if (item is Map) _category(item),
    ];
    return MonthlyBudgetDetailsModel(
      MonthlyBudgetDetails(
        month: _int(json['month']),
        year: _int(json['year']),
        targetAmount: json['targetAmount']?.toString() ?? '0',
        spentAmount: json['spentAmount']?.toString() ?? '0',
        remainingAmount: json['remainingAmount']?.toString() ?? '0',
        percentUsed: _double(json['percentUsed']),
        transactionCount: _int(json['transactionCount']),
        topCategoryName: json['topCategoryName']?.toString(),
        topWalletName: json['topWalletName']?.toString(),
        categories: _groupUnbudgetedCategories(parsedCategories),
      ),
    );
  }
}

MonthlyBudgetCategoryDetail _category(Map<dynamic, dynamic> item) {
  final rawUnbudgetedCategories = item['unbudgetedCategories'];
  final unbudgetedCategories = rawUnbudgetedCategories is List
      ? rawUnbudgetedCategories
      : const [];
  return MonthlyBudgetCategoryDetail(
    tagId: item['tagId']?.toString() ?? '',
    tagName: item['tagName']?.toString() ?? 'Khác',
    targetAmount: item['targetAmount']?.toString() ?? '0',
    spentAmount: item['spentAmount']?.toString() ?? '0',
    percentOfSpend: _double(item['percentOfSpend']),
    variancePercent: _double(item['variancePercent']),
    unbudgetedCategories: [
      for (final detail in unbudgetedCategories)
        if (detail is Map)
          MonthlyBudgetUnbudgetedCategoryDetail(
            tagId: detail['tagId']?.toString() ?? '',
            tagName: detail['tagName']?.toString() ?? 'Khác',
            spentAmount: detail['spentAmount']?.toString() ?? '0',
          ),
    ],
  );
}

List<MonthlyBudgetCategoryDetail> _groupUnbudgetedCategories(
  List<MonthlyBudgetCategoryDetail> categories,
) {
  final configured = <MonthlyBudgetCategoryDetail>[];
  final unbudgeted = <MonthlyBudgetCategoryDetail>[];
  for (final category in categories) {
    if (parseMoneyMinorUnits(category.targetAmount) > BigInt.zero) {
      configured.add(category);
    } else {
      unbudgeted.add(category);
    }
  }
  if (unbudgeted.isEmpty) {
    return configured;
  }

  var spentMinorUnits = BigInt.zero;
  var percentOfSpend = 0.0;
  final details = <MonthlyBudgetUnbudgetedCategoryDetail>[];
  for (final category in unbudgeted) {
    spentMinorUnits += parseMoneyMinorUnits(category.spentAmount);
    percentOfSpend += category.percentOfSpend;
    if (category.unbudgetedCategories.isNotEmpty) {
      details.addAll(category.unbudgetedCategories);
    } else {
      details.add(
        MonthlyBudgetUnbudgetedCategoryDetail(
          tagId: category.tagId,
          tagName: category.tagName,
          spentAmount: category.spentAmount,
        ),
      );
    }
  }
  details.sort(
    (left, right) => parseMoneyMinorUnits(
      right.spentAmount,
    ).compareTo(parseMoneyMinorUnits(left.spentAmount)),
  );

  return [
    ...configured,
    MonthlyBudgetCategoryDetail(
      tagId: '__other__',
      tagName: 'Khác',
      targetAmount: '0',
      spentAmount: formatMoneyMinorUnits(spentMinorUnits),
      percentOfSpend: percentOfSpend,
      variancePercent: 0,
      unbudgetedCategories: details,
    ),
  ];
}

int _int(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
double _double(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
