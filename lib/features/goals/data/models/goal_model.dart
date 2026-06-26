import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/goal.dart';

final class GoalModel {
  const GoalModel({
    required this.id,
    this.walletId,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.status,
  });

  final String id;
  final String? walletId;
  final String name;
  final String? description;
  final String targetAmount;
  final String currentAmount;
  final DateTime? deadline;
  final GoalStatus status;

  factory GoalModel.fromJson(JsonMap json) {
    return GoalModel(
      id: json['id']?.toString() ?? '',
      walletId: _readRelationId(json, 'walletId', 'wallet'),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      targetAmount: json['targetAmount']?.toString() ?? '0',
      currentAmount: json['currentAmount']?.toString() ?? '0',
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? ''),
      status: goalStatusFromApi(json['status']),
    );
  }

  Goal toDomain() {
    return Goal(
      id: id,
      walletId: walletId,
      name: name,
      description: description,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      status: status,
    );
  }
}

String? _readRelationId(JsonMap json, String topLevelKey, String nestedKey) {
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
