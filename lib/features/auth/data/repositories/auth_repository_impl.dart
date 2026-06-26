import 'package:dio/dio.dart';

import '../../../../core/auth/auth_session_manager.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._sessionManager);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthSessionManager _sessionManager;

  @override
  Future<AuthUser?> bootstrap() async {
    final refreshToken = await _sessionManager.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }
    try {
      final session = await _remoteDataSource.refresh(refreshToken);
      await _sessionManager.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      return session.user?.toDomain() ??
          (await _remoteDataSource.me()).toDomain();
    } on DioException {
      await _sessionManager.clear();
      return null;
    }
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final session = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    return _saveSessionAndUser(session);
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final session = await _remoteDataSource.register(
      email: email,
      password: password,
      fullName: fullName,
    );
    return _saveSessionAndUser(session);
  }

  @override
  Future<void> signOut() async {
    final refreshToken = await _sessionManager.readRefreshToken();
    try {
      await _remoteDataSource.logout(refreshToken);
    } finally {
      await _sessionManager.clear();
    }
  }

  Future<AuthUser> _saveSessionAndUser(AuthRemoteSession session) async {
    await _sessionManager.saveSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    return session.user?.toDomain() ??
        (await _remoteDataSource.me()).toDomain();
  }
}
