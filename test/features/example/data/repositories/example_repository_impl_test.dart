import 'package:flowfi_fe/features/example/data/datasources/example_data_source.dart';
import 'package:flowfi_fe/features/example/data/models/example_item_model.dart';
import 'package:flowfi_fe/features/example/data/repositories/example_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps data models to domain entities', () async {
    const models = [ExampleItemModel(id: 'one', title: 'Mapped example item')];
    final repository = ExampleRepositoryImpl(_FakeExampleDataSource(models));

    final result = await repository.getItems();

    expect(result, hasLength(1));
    expect(result.single.id, 'one');
    expect(result.single.title, 'Mapped example item');
  });
}

class _FakeExampleDataSource implements ExampleDataSource {
  const _FakeExampleDataSource(this.items);

  final List<ExampleItemModel> items;

  @override
  Future<List<ExampleItemModel>> getItems() async => items;
}
