import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/tags/domain/entities/tag.dart';
import 'package:flowfi_fe/features/tags/domain/repositories/tag_repository.dart';
import 'package:flowfi_fe/features/tags/presentation/providers/tags_provider.dart';
import 'package:flowfi_fe/features/tags/presentation/widgets/tag_manager_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tag manager create form calls the tags provider', (
    tester,
  ) async {
    final repository = _RecordingTagRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tagRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: Scaffold(body: TagManagerSheet())),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Add tag'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Utilities');
    await tester.tap(find.text('Create tag'));
    await tester.pumpAndSettle();

    expect(repository.createdName, 'Utilities');
    expect(repository.createdType, MoneyFlowType.expense);
  });
}

final class _RecordingTagRepository implements TagRepository {
  String? createdName;
  MoneyFlowType? createdType;

  @override
  Future<List<Tag>> listTags({int page = 1, int limit = 50}) async {
    return const [
      Tag(
        id: 'tag-1',
        name: 'Food',
        type: MoneyFlowType.expense,
        isDefault: false,
      ),
    ];
  }

  @override
  Future<Tag> createTag({
    required String name,
    required MoneyFlowType type,
    String? clientId,
  }) async {
    createdName = name;
    createdType = type;
    return Tag(id: 'tag-new', name: name, type: type, isDefault: false);
  }

  @override
  Future<void> deleteTag(String id) async {}

  @override
  Future<Tag> updateTag(
    String id, {
    String? name,
    MoneyFlowType? type,
    String? clientId,
  }) async {
    return Tag(
      id: id,
      name: name ?? 'Food',
      type: type ?? MoneyFlowType.expense,
      isDefault: false,
    );
  }
}
