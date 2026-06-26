import 'package:dio/dio.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../auth/auth_session_manager.dart';

final class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._dio, this._sessionManager, this._authRemoteDataSource);

  final Dio _dio;
  final AuthSessionManager _sessionManager;
  final AuthRemoteDataSource _authRemoteDataSource;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['skipAuth'] == true) {
      handler.next(options);
      return;
    }
    final accessToken = _sessionManager.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        err.requestOptions.extra['skipAuth'] != true;
    if (!shouldRefresh) {
      handler.next(err);
      return;
    }

    final refreshToken = await _sessionManager.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      final session = await _authRemoteDataSource.refresh(refreshToken);
      await _sessionManager.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer ${session.accessToken}';
      handler.resolve(await _dio.fetch<dynamic>(requestOptions));
    } on DioException {
      await _sessionManager.clear();
      handler.next(err);
    }
  }
}
