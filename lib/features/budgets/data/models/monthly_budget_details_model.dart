import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/monthly_budget_details.dart';

final class MonthlyBudgetDetailsModel {
  const MonthlyBudgetDetailsModel(this.value);

  final MonthlyBudgetDetails value;

  factory MonthlyBudgetDetailsModel.fromJson(JsonMap json) {
    final rawCategories = json['categories'];
    final categories = rawCategories is List ? rawCategories : const [];
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
        categories: [
          for (final item in categories)
            if (item is Map)
              MonthlyBudgetCategoryDetail(
                tagId: item['tagId']?.toString() ?? '',
                tagName: item['tagName']?.toString() ?? 'Khác',
                targetAmount: item['targetAmount']?.toString() ?? '0',
                spentAmount: item['spentAmount']?.toString() ?? '0',
                percentOfSpend: _double(item['percentOfSpend']),
                variancePercent: _double(item['variancePercent']),
              ),
        ],
      ),
    );
  }
}

int _int(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
double _double(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
