import '../../../../core/finance/money_flow_type.dart';
import '../../../../core/network/api_list_parser.dart';
import '../../domain/entities/tag.dart';

final class TagModel {
  const TagModel({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
  });

  final String id;
  final String name;
  final MoneyFlowType type;
  final bool isDefault;

  factory TagModel.fromJson(JsonMap json) {
    return TagModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: moneyFlowTypeFromApi(json['type']),
      isDefault: json['isDefault'] == true,
    );
  }

  Tag toDomain() {
    return Tag(id: id, name: name, type: type, isDefault: isDefault);
  }
}
