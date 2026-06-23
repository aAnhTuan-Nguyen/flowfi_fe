import 'package:dio/dio.dart';
import 'package:flowfi_fe/core/network/dio_client.dart';
import 'package:flowfi_fe/core/storage/secure_storage.dart';
import 'package:flowfi_fe/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => serviceLocator.reset());
  tearDown(() => serviceLocator.reset());

  test('configures core dependencies exactly once', () {
    configureDependencies();
    configureDependencies();

    expect(serviceLocator.isRegistered<SecureStorageService>(), isTrue);
    expect(serviceLocator.isRegistered<DioClient>(), isTrue);
    expect(serviceLocator.isRegistered<Dio>(), isTrue);
    expect(serviceLocator<SecureStorageService>(),
        same(serviceLocator<SecureStorageService>()));
    expect(serviceLocator<DioClient>(), same(serviceLocator<DioClient>()));
    expect(serviceLocator<Dio>(), same(serviceLocator<Dio>()));
  });
}
