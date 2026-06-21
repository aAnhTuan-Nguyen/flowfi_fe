import 'package:flowfi_fe/features/example/data/datasources/example_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'in-memory source exposes the disposable architecture examples',
    () async {
      final dataSource = ExampleInMemoryDataSource();

      final result = await dataSource.getItems();

      expect(result.map((item) => item.title), [
        'Domain boundary',
        'Data boundary',
        'Presentation boundary',
      ]);
    },
  );
}
