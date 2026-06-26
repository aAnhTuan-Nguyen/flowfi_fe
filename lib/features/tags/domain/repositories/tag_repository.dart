import '../../../../core/finance/money_flow_type.dart';
import '../entities/tag.dart';

abstract interface class TagRepository {
  Future<List<Tag>> listTags({int page = 1, int limit = 50});

  Future<Tag> createTag({
    required String name,
    required MoneyFlowType type,
    String? clientId,
  });

  Future<Tag> updateTag(
    String id, {
    String? name,
    MoneyFlowType? type,
    String? clientId,
  });

  Future<void> deleteTag(String id);
}
