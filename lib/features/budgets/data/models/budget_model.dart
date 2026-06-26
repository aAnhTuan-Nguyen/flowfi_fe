import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/budget.dart';

final class BudgetModel {
  const BudgetModel({
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

  factory BudgetModel.fromJson(JsonMap json) {
    return BudgetModel(
      id: json['id']?.toString() ?? '',
      tagId: _readNestedId(json, 'tagId', 'tag'),
      amount: json['budgetAmount']?.toString() ?? '0',
      month: _readInt(json['month']),
      year: _readInt(json['year']),
      warningThresholdPercent: _readInt(json['warningThresholdPercent']),
      tagName: _readNestedName(json['tag']),
    );
  }

  Budget toDomain() {
    return Budget(
      id: id,
      tagId: tagId,
      amount: amount,
      month: month,
      year: year,
      warningThresholdPercent: warningThresholdPercent,
      tagName: tagName,
    );
  }
}

int _readInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _readNestedName(Object? value) {
  if (value is Map<String, Object?>) {
    return value['name']?.toString();
  }
  if (value is Map) {
    return value['name']?.toString();
  }
  return null;
}

String? _readNestedId(JsonMap json, String topLevelKey, String nestedKey) {
  final topLevelValue = json[topLevelKey]?.toString();
  if (topLevelValue != null && topLevelValue.isNotEmpty) {
    return topLevelValue;
  }
  final nestedValue = json[nestedKey];
  if (nestedValue is Map<String, Object?>) {
    return nestedValue['id']?.toString();
  }
  if (nestedValue is Map) {
    return nestedValue['id']?.toString();
  }
  return null;
}
