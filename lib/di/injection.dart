import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../core/network/dio_client.dart';
import '../core/storage/secure_storage.dart';

final GetIt serviceLocator = GetIt.instance;

void configureDependencies() {
  // Core services
  if (!serviceLocator.isRegistered<SecureStorageService>()) {
    serviceLocator.registerLazySingleton<SecureStorageService>(
      SecureStorageService.create,
    );
  }

  if (!serviceLocator.isRegistered<DioClient>()) {
    serviceLocator.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  // Override or remove the old dio registration if necessary, or map it to DioClient.dio
  if (!serviceLocator.isRegistered<Dio>()) {
    serviceLocator.registerLazySingleton<Dio>(
      () => serviceLocator<DioClient>().dio,
    );
  }
}
