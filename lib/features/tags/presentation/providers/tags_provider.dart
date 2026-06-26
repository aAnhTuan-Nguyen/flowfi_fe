import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/finance/money_flow_type.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';

final tagRepositoryProvider = Provider<TagRepository>(
  (ref) => serviceLocator<TagRepository>(),
);

class TagsNotifier extends AsyncNotifier<List<Tag>> {
  @override
  Future<List<Tag>> build() {
    return ref.watch(tagRepositoryProvider).listTags();
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> createTag({
    required String name,
    required MoneyFlowType type,
    String? clientId,
  }) async {
    await ref
        .read(tagRepositoryProvider)
        .createTag(name: name, type: type, clientId: clientId);
    await reload();
  }

  Future<void> updateTag(
    String id, {
    String? name,
    MoneyFlowType? type,
    String? clientId,
  }) async {
    await ref
        .read(tagRepositoryProvider)
        .updateTag(id, name: name, type: type, clientId: clientId);
    await reload();
  }

  Future<void> deleteTag(String id) async {
    await ref.read(tagRepositoryProvider).deleteTag(id);
    await reload();
  }
}

final tagsProvider = AsyncNotifierProvider<TagsNotifier, List<Tag>>(
  TagsNotifier.new,
);
