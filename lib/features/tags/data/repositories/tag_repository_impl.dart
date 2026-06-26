import '../../../../core/finance/money_flow_type.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_remote_data_source.dart';

final class TagRepositoryImpl implements TagRepository {
  const TagRepositoryImpl(this._remoteDataSource);

  final TagRemoteDataSource _remoteDataSource;

  @override
  Future<List<Tag>> listTags({int page = 1, int limit = 50}) async {
    final models = await _remoteDataSource.listTags(page: page, limit: limit);
    return models.map((model) => model.toDomain()).toList(growable: false);
  }

  @override
  Future<Tag> createTag({
    required String name,
    required MoneyFlowType type,
    String? clientId,
  }) async {
    return (await _remoteDataSource.createTag(
      name: name,
      type: type,
      clientId: clientId,
    )).toDomain();
  }

  @override
  Future<void> deleteTag(String id) {
    return _remoteDataSource.deleteTag(id);
  }

  @override
  Future<Tag> updateTag(
    String id, {
    String? name,
    MoneyFlowType? type,
    String? clientId,
  }) async {
    return (await _remoteDataSource.updateTag(
      id,
      name: name,
      type: type,
      clientId: clientId,
    )).toDomain();
  }
}
