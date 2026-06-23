import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/app_config.dart';
import '../../routes/app_router.dart';

/// Dio HTTP client configured for FlowFi API
/// Backend integration: replace base URL and add auth interceptor when ready
class DioClient {
  DioClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {}, // suppress in production
      ),
    ]);
  }

  late final Dio _dio;
  final FlutterSecureStorage _storage;

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.delete(key: AppConstants.keyAccessToken);
      _storage.delete(key: AppConstants.keyRefreshToken);

      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        context.go(AppRoutes.login);
      }
    }
    handler.next(err);
  }
}
