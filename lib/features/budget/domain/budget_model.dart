import 'package:equatable/equatable.dart';

class BudgetModel extends Equatable {
  const BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.spent,
  });

  final String id;
  final String category;
  final double limit;
  final double spent;

  double get usagePercent => limit > 0 ? spent / limit : 0;
  bool get isWarning => usagePercent >= 0.8;

  @override
  List<Object?> get props => [id, category, limit, spent];
}
