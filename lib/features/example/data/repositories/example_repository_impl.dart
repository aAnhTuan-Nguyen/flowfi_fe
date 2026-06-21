import '../../domain/entities/example_item.dart';
import '../../domain/repositories/example_repository.dart';
import '../datasources/example_data_source.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  const ExampleRepositoryImpl(this._dataSource);

  final ExampleDataSource _dataSource;

  @override
  Future<List<ExampleItem>> getItems() async {
    final models = await _dataSource.getItems();
    return models.map((model) => model.toEntity()).toList(growable: false);
  }
}
