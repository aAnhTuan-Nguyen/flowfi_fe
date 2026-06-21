import 'package:flowfi_fe/features/example/domain/entities/example_item.dart';
import 'package:flowfi_fe/features/example/domain/repositories/example_repository.dart';

class FakeExampleRepository implements ExampleRepository {
  FakeExampleRepository(this._load);

  final Future<List<ExampleItem>> Function() _load;
  int callCount = 0;

  @override
  Future<List<ExampleItem>> getItems() {
    callCount++;
    return _load();
  }
}
