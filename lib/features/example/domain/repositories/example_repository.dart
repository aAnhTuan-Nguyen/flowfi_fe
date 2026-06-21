import '../entities/example_item.dart';

abstract interface class ExampleRepository {
  Future<List<ExampleItem>> getItems();
}
