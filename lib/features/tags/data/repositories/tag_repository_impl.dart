// ignore_for_file: prefer_initializing_formals

import '../../../../core/finance/money_flow_type.dart';
import '../../../../core/local/flowfi_local_store.dart';
import '../../../../core/sync/network_status_service.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_remote_data_source.dart';

final class TagRepositoryImpl implements TagRepository {
  const TagRepositoryImpl(
    this._remoteDataSource, {
    FlowFiLocalStore? localStore,
    NetworkStatusService? networkStatus,
  }) : _localStore = localStore,
       _networkStatus = networkStatus;

  final TagRemoteDataSource _remoteDataSource;
  final FlowFiLocalStore? _localStore;
  final NetworkStatusService? _networkStatus;

  @override
  Future<List<Tag>> listTags({int page = 1, int limit = 50}) async {
    if (!await _hasNetwork()) {
      return _localStore?.readTags() ?? const [];
    }
    try {
      final models = await _remoteDataSource.listTags(page: page, limit: limit);
      final tags = models
          .map((model) => model.toDomain())
          .toList(growable: false);
      await _localStore?.cacheTags(tags);
      return tags;
    } catch (_) {
      final cached = await _localStore?.readTags();
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
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

  Future<bool> _hasNetwork() async {
    return await _networkStatus?.hasNetwork() ?? true;
  }
}
