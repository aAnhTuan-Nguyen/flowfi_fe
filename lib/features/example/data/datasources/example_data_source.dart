import '../models/example_item_model.dart';

abstract interface class ExampleDataSource {
  Future<List<ExampleItemModel>> getItems();
}

class ExampleInMemoryDataSource implements ExampleDataSource {
  const ExampleInMemoryDataSource();

  @override
  Future<List<ExampleItemModel>> getItems() async => const [
    ExampleItemModel(id: 'domain', title: 'Domain boundary'),
    ExampleItemModel(id: 'data', title: 'Data boundary'),
    ExampleItemModel(id: 'presentation', title: 'Presentation boundary'),
  ];
}
