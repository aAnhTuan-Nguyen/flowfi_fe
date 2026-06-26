import 'package:dio/dio.dart';
import 'package:flowfi_fe/core/auth/auth_session_manager.dart';
import 'package:flowfi_fe/core/auth/token_storage.dart';
import 'package:flowfi_fe/core/network/auth_interceptor.dart';
import 'package:flowfi_fe/di/injection.dart';
import 'package:flowfi_fe/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flowfi_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/bootstrap_auth_session_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flowfi_fe/features/ai_processing/domain/repositories/ai_processing_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => serviceLocator.reset());
  tearDown(() => serviceLocator.reset());

  test('configures the auth dependency chain exactly once', () {
    configureDependencies();
    configureDependencies();

    expect(serviceLocator.isRegistered<Dio>(), isTrue);
    expect(serviceLocator.isRegistered<TokenStorage>(), isTrue);
    expect(serviceLocator.isRegistered<AuthSessionManager>(), isTrue);
    expect(serviceLocator.isRegistered<AuthRemoteDataSource>(), isTrue);
    expect(serviceLocator.isRegistered<AuthRepository>(), isTrue);
    expect(serviceLocator.isRegistered<BootstrapAuthSessionUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<SignInUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<SignUpUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<SignOutUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<AiProcessingRepository>(), isTrue);
    expect(serviceLocator<Dio>(), same(serviceLocator<Dio>()));
    expect(
      serviceLocator<Dio>().interceptors.whereType<AuthInterceptor>().length,
      1,
    );
  });
}
