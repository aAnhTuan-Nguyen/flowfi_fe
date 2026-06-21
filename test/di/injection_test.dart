import 'package:dio/dio.dart';
import 'package:flowfi_fe/di/injection.dart';
import 'package:flowfi_fe/features/example/data/datasources/example_data_source.dart';
import 'package:flowfi_fe/features/example/domain/repositories/example_repository.dart';
import 'package:flowfi_fe/features/example/domain/usecases/get_example_items_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => serviceLocator.reset());
  tearDown(() => serviceLocator.reset());

  test('configures the example dependency chain exactly once', () {
    configureDependencies();
    configureDependencies();

    expect(serviceLocator.isRegistered<Dio>(), isTrue);
    expect(serviceLocator.isRegistered<ExampleDataSource>(), isTrue);
    expect(serviceLocator.isRegistered<ExampleRepository>(), isTrue);
    expect(serviceLocator.isRegistered<GetExampleItemsUseCase>(), isTrue);
    expect(serviceLocator<Dio>(), same(serviceLocator<Dio>()));
  });
}
