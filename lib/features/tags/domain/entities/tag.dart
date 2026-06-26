import '../../../../core/finance/money_flow_type.dart';

final class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
  });

  final String id;
  final String name;
  final MoneyFlowType type;
  final bool isDefault;
}
