import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/annual_budget_summary.dart';

final class AnnualBudgetMonthSummaryModel {
  const AnnualBudgetMonthSummaryModel(this.value);

  final AnnualBudgetMonthSummary value;

  factory AnnualBudgetMonthSummaryModel.fromJson(JsonMap json) {
    return AnnualBudgetMonthSummaryModel(
      AnnualBudgetMonthSummary(
        month: _int(json['month']),
        targetAmount: json['targetAmount']?.toString() ?? '0',
        spentAmount: json['spentAmount']?.toString() ?? '0',
        percentUsed: _double(json['percentUsed']),
        exceededPercent: _double(json['exceededPercent']),
      ),
    );
  }
}

int _int(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
double _double(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
