import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../core/auth/auth_session_manager.dart';
import '../core/auth/token_storage.dart';
import '../core/local/flowfi_database.dart';
import '../core/local/flowfi_local_store.dart';
import '../core/network/auth_interceptor.dart';
import '../core/network/dio_client.dart';
import '../core/sync/network_status_service.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/bootstrap_auth_session_use_case.dart';
import '../features/auth/domain/usecases/sign_in_use_case.dart';
import '../features/auth/domain/usecases/sign_out_use_case.dart';
import '../features/auth/domain/usecases/sign_up_use_case.dart';
import '../features/auth/domain/usecases/update_profile_use_case.dart';
import '../features/ai_processing/data/datasources/ai_processing_remote_data_source.dart';
import '../features/ai_processing/data/repositories/ai_processing_repository_impl.dart';
import '../features/ai_processing/domain/repositories/ai_processing_repository.dart';
import '../features/budgets/data/datasources/budget_remote_data_source.dart';
import '../features/budgets/data/repositories/budget_repository_impl.dart';
import '../features/budgets/domain/repositories/budget_repository.dart';
import '../features/goals/data/datasources/goal_remote_data_source.dart';
import '../features/goals/data/repositories/goal_repository_impl.dart';
import '../features/goals/domain/repositories/goal_repository.dart';
import '../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../features/notifications/data/repositories/notification_repository_impl.dart';
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/sync/data/datasources/sync_remote_data_source.dart';
import '../features/sync/data/offline_sync_service.dart';
import '../features/tags/data/datasources/tag_remote_data_source.dart';
import '../features/tags/data/repositories/tag_repository_impl.dart';
import '../features/tags/domain/repositories/tag_repository.dart';
import '../features/transactions/data/datasources/transaction_remote_data_source.dart';
import '../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/wallets/data/datasources/wallet_remote_data_source.dart';
import '../features/wallets/data/repositories/wallet_repository_impl.dart';
import '../features/wallets/domain/repositories/wallet_repository.dart';

final GetIt serviceLocator = GetIt.instance;

void configureDependencies() {
  if (!serviceLocator.isRegistered<Dio>()) {
    serviceLocator.registerLazySingleton<Dio>(createDioClient);
  }
  if (!serviceLocator.isRegistered<FlutterSecureStorage>()) {
    serviceLocator.registerLazySingleton<FlutterSecureStorage>(
      FlutterSecureStorage.new,
    );
  }
  if (!serviceLocator.isRegistered<TokenStorage>()) {
    serviceLocator.registerLazySingleton<TokenStorage>(
      () => SecureTokenStorage(serviceLocator<FlutterSecureStorage>()),
    );
  }
  if (!serviceLocator.isRegistered<AuthSessionManager>()) {
    serviceLocator.registerLazySingleton<AuthSessionManager>(
      () => AuthSessionManager(serviceLocator<TokenStorage>()),
    );
  }
  if (!serviceLocator.isRegistered<FlowFiDatabase>()) {
    serviceLocator.registerLazySingleton<FlowFiDatabase>(FlowFiDatabase.new);
  }
  if (!serviceLocator.isRegistered<FlowFiLocalStore>()) {
    serviceLocator.registerLazySingleton<FlowFiLocalStore>(
      () => FlowFiLocalStore(serviceLocator<FlowFiDatabase>()),
    );
  }
  if (!serviceLocator.isRegistered<NetworkStatusService>()) {
    serviceLocator.registerLazySingleton<NetworkStatusService>(
      ConnectivityNetworkStatusService.new,
    );
  }
  if (!serviceLocator.isRegistered<AuthRemoteDataSource>()) {
    serviceLocator.registerLazySingleton<AuthRemoteDataSource>(
      () => DioAuthRemoteDataSource(serviceLocator<Dio>()),
    );
  }
  if (!serviceLocator.isRegistered<AuthRepository>()) {
    serviceLocator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator<AuthRemoteDataSource>(),
        serviceLocator<AuthSessionManager>(),
      ),
    );
  }
  if (!serviceLocator.isRegistered<BootstrapAuthSessionUseCase>()) {
    serviceLocator.registerLazySingleton<BootstrapAuthSessionUseCase>(
      () => BootstrapAuthSessionUseCase(serviceLocator<AuthRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<SignInUseCase>()) {
    serviceLocator.registerLazySingleton<SignInUseCase>(
      () => SignInUseCase(serviceLocator<AuthRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<SignUpUseCase>()) {
    serviceLocator.registerLazySingleton<SignUpUseCase>(
      () => SignUpUseCase(serviceLocator<AuthRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<SignOutUseCase>()) {
    serviceLocator.registerLazySingleton<SignOutUseCase>(
      () => SignOutUseCase(serviceLocator<AuthRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<UpdateProfileUseCase>()) {
    serviceLocator.registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(serviceLocator<AuthRepository>()),
    );
  }
  if (!serviceLocator.isRegistered<WalletRemoteDataSource>()) {
    serviceLocator.registerLazySingleton<WalletRemoteDataSource>(
      () => DioWalletRemoteDataSource(serviceLocator<Dio>()),
    );
  }
  if (!serviceLocator.isRegistered<WalletRepository>()) {
    serviceLocator.registerLazySingleton<WalletRepository>(
      () => WalletRepositoryImpl(
        serviceLocator<WalletRemoteDataSource>(),
        localStore: serviceLocator<FlowFiLocalStore>(),
        networkStatus: serviceLocator<NetworkStatusService>(),
      ),
    );
  }
  if (!serviceLocator.isRegistered<TagRemoteDataSource>()) {
    serviceLocator.registerLazySingleton<TagRemoteDataSource>(
      () => DioTagRemoteDataSource(serviceLocator<Dio>()),
    );
  }
  if (!serviceLocator.isRegistered<TagRepository>()) {
    serviceLocator.registerLazySingleton<TagRepository>(
      () => TagRepositoryImpl(
        serviceLocator<TagRemoteDataSource>(),
        localStore: serviceLocator<FlowFiLocalStore>(),
        networkStatus: serviceLocator<NetworkStatusService>(),
      ),
    );
  }
  if (!serviceLocator.isRegistered<TransactionRemoteDataSource>()) {
    serviceLocator.registerLazySingleton<TransactionRemoteDataSource>(
      () => DioTransactionRemoteDataSource(serviceLocator<Dio>()),
    );
  }
  if (!serviceLocator.isRegistered<TransactionRepository>()) {
    serviceLocator.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(
        serviceLocator<TransactionRemoteDataSource>(),
        localStore: serviceLocator<FlowFiLocalStore>(),
        networkStatus: serviceLocator<NetworkStatusService>(),
      ),
    );
  }
  if (!serviceLocator.isRegistered<SyncRemoteDataSource>()) {
    serviceLocator.registerLazySingleton<SyncRemoteDataSource>(
      () => DioSyncRemoteDataSource(serviceLocator<Dio>()),
    );
  }
  if (!serviceLocator.isRegistered<OfflineSyncService>()) {
    serviceLocator.registerLazySingleton<OfflineSyncService>(
      () => OfflineSyncService(
        localStore: serviceLocator<FlowFiLocalStore>(),
        remoteDataSource: serviceLocator<SyncRemoteDataSource>(),
        networkStatus: serviceLocator<NetworkStatusService>(),
        deviceIdProvider: () => serviceLocator<FlowFiLocalStore>()
            .readOrCreateDeviceId(() => const Uuid().v4()),
      ),
    );
  }
  if (!serviceLocator.isRegistered<AiProcessingRemoteDataSource>()) {
    serviceLocator.registerLazySingleton<AiProcessingRemoteDataSource>(
      () => DioAiProcessingRemoteDataSource(serviceLocator<Dio>()),
    );
  }
  if (!serviceLocator.isRegistered<AiProcessingRepository>()) {
    serviceLocator.registerLazySingleton<AiProcessingRepository>(
      () => AiProcessingRepositoryImpl(
        serviceLocator<AiProcessingRemoteDataSource>(),
      ),
    );
  }
  if (!serviceLocator.isRegistered<BudgetRemoteDataSource>()) {
    serviceLocator.registerLazySingleton<BudgetRemoteDataSource>(
      () => DioBudgetRemoteDataSource(serviceLocator<Dio>()),
    );
  }
  if (!serviceLocator.isRegistered<BudgetRepository>()) {
    serviceLocator.registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(serviceLocator<BudgetRemoteDataSource>()),
    );
  }
  if (!serviceLocator.isRegistered<GoalRemoteDataSource>()) {
    serviceLocator.registerLazySingleton<GoalRemoteDataSource>(
      () => DioGoalRemoteDataSource(serviceLocator<Dio>()),
    );
  }
  if (!serviceLocator.isRegistered<GoalRepository>()) {
    serviceLocator.registerLazySingleton<GoalRepository>(
      () => GoalRepositoryImpl(serviceLocator<GoalRemoteDataSource>()),
    );
  }
  if (!serviceLocator.isRegistered<NotificationRemoteDataSource>()) {
    serviceLocator.registerLazySingleton<NotificationRemoteDataSource>(
      () => DioNotificationRemoteDataSource(serviceLocator<Dio>()),
    );
  }
  if (!serviceLocator.isRegistered<NotificationRepository>()) {
    serviceLocator.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        serviceLocator<NotificationRemoteDataSource>(),
      ),
    );
  }
  _attachAuthInterceptor();
}

void _attachAuthInterceptor() {
  final dio = serviceLocator<Dio>();
  final alreadyAttached = dio.interceptors.any((interceptor) {
    return interceptor is AuthInterceptor;
  });
  if (alreadyAttached) {
    return;
  }
  dio.interceptors.add(
    AuthInterceptor(
      dio,
      serviceLocator<AuthSessionManager>(),
      serviceLocator<AuthRemoteDataSource>(),
    ),
  );
}
