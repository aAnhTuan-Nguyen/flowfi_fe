import 'package:flowfi_fe/app/app_theme.dart';
import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/tags/domain/entities/tag.dart';
import 'package:flowfi_fe/features/tags/domain/repositories/tag_repository.dart';
import 'package:flowfi_fe/features/tags/presentation/providers/tags_provider.dart';
import 'package:flowfi_fe/features/tags/presentation/widgets/tag_manager_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tag manager creates a category through the tags provider', (
    tester,
  ) async {
    final repository = _RecordingTagRepository();
    await _pumpTagManager(tester, repository);

    await tester.tap(find.text('Thêm danh mục'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('tag-name-field')),
        matching: find.byType(EditableText),
      ),
      'Utilities',
    );
    await tester.tap(find.text('Tạo danh mục'));
    await tester.pumpAndSettle();

    expect(repository.createdName, 'Utilities');
    expect(repository.createdType, MoneyFlowType.expense);
  });

  testWidgets('tag manager filters and searches loaded categories', (
    tester,
  ) async {
    final repository = _RecordingTagRepository();
    await _pumpTagManager(tester, repository);

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tag-filter-income')));
    await tester.pump();

    expect(find.text('Food'), findsNothing);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('1 danh mục'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tag-filter-all')));
    await tester.enterText(find.byKey(const Key('tag-search-field')), 'food');
    await tester.pump();

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
  });
}

Future<void> _pumpTagManager(
  WidgetTester tester,
  TagRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [tagRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: TagManagerSheet(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
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
        isDefault: true,
      ),
      Tag(
        id: 'tag-2',
        name: 'Salary',
        type: MoneyFlowType.income,
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
