import '../entities/example_item.dart';
import '../repositories/example_repository.dart';

class GetExampleItemsUseCase {
  const GetExampleItemsUseCase(this._repository);

  final ExampleRepository _repository;

  Future<List<ExampleItem>> call() => _repository.getItems();
}
