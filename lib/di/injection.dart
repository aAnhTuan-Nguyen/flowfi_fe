import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../core/network/dio_client.dart';
import '../features/example/data/datasources/example_data_source.dart';
import '../features/example/data/repositories/example_repository_impl.dart';
import '../features/example/domain/repositories/example_repository.dart';
import '../features/example/domain/usecases/get_example_items_use_case.dart';

final GetIt serviceLocator = GetIt.instance;

void configureDependencies() {
  if (!serviceLocator.isRegistered<Dio>()) {
    serviceLocator.registerLazySingleton<Dio>(createDioClient);
  }
  if (!serviceLocator.isRegistered<ExampleDataSource>()) {
    serviceLocator.registerLazySingleton<ExampleDataSource>(
      ExampleInMemoryDataSource.new,
    );
  }
  if (!serviceLocator.isRegistered<ExampleRepository>()) {
    serviceLocator.registerLazySingleton<ExampleRepository>(
      () => ExampleRepositoryImpl(serviceLocator<ExampleDataSource>()),
    );
  }
  if (!serviceLocator.isRegistered<GetExampleItemsUseCase>()) {
    serviceLocator.registerLazySingleton<GetExampleItemsUseCase>(
      () => GetExampleItemsUseCase(serviceLocator<ExampleRepository>()),
    );
  }
}
