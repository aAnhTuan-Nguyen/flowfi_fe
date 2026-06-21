import 'package:flowfi_fe/features/example/domain/entities/example_item.dart';
import 'package:flowfi_fe/features/example/domain/usecases/get_example_items_use_case.dart';
import 'package:flowfi_fe/features/example/presentation/providers/example_items_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers/fake_example_repository.dart';

void main() {
  test('loads example items through the use case', () async {
    const expected = [ExampleItem(id: 'one', title: 'Loaded item')];
    final repository = FakeExampleRepository(() async => expected);
    final container = _createContainer(repository);

    final result = await container.read(exampleItemsProvider.future);

    expect(result, same(expected));
    expect(repository.callCount, 1);
  });

  test('publishes an async error when loading fails', () async {
    final failure = StateError('example failed');
    final repository = FakeExampleRepository(() async => throw failure);
    final container = _createContainer(repository);

    await expectLater(
      container.read(exampleItemsProvider.future),
      throwsA(same(failure)),
    );

    expect(container.read(exampleItemsProvider).hasError, isTrue);
  });

  test('reload fetches the latest example items', () async {
    var current = const [ExampleItem(id: 'one', title: 'First result')];
    final repository = FakeExampleRepository(() async => current);
    final container = _createContainer(repository);
    await container.read(exampleItemsProvider.future);
    current = const [ExampleItem(id: 'two', title: 'Reloaded result')];

    await container.read(exampleItemsProvider.notifier).reload();

    expect(
      container.read(exampleItemsProvider).requireValue.single.title,
      'Reloaded result',
    );
    expect(repository.callCount, 2);
  });
}

ProviderContainer _createContainer(FakeExampleRepository repository) {
  final container = ProviderContainer(
    overrides: [
      getExampleItemsUseCaseProvider.overrideWithValue(
        GetExampleItemsUseCase(repository),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}
