import 'package:flowfi_fe/features/example/domain/entities/example_item.dart';
import 'package:flowfi_fe/features/example/domain/repositories/example_repository.dart';
import 'package:flowfi_fe/features/example/domain/usecases/get_example_items_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('delegates loading example items to the repository', () async {
    const expected = [ExampleItem(id: 'one', title: 'First example item')];
    final repository = _FakeExampleRepository(expected);
    final useCase = GetExampleItemsUseCase(repository);

    final result = await useCase();

    expect(result, same(expected));
    expect(repository.callCount, 1);
  });
}

class _FakeExampleRepository implements ExampleRepository {
  _FakeExampleRepository(this.items);

  final List<ExampleItem> items;
  int callCount = 0;

  @override
  Future<List<ExampleItem>> getItems() async {
    callCount++;
    return items;
  }
}
