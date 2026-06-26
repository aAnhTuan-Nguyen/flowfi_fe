import 'package:dio/dio.dart';

import '../../domain/entities/auth_user.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthRemoteSession> login({
    required String email,
    required String password,
  });

  Future<AuthRemoteSession> register({
    required String email,
    required String password,
    String? fullName,
  });

  Future<AuthRemoteSession> refresh(String refreshToken);

  Future<RemoteUser> me();

  Future<void> logout(String? refreshToken);
}

final class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  DioAuthRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<AuthRemoteSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, Object?>>(
      'auth/login',
      data: {'email': email, 'password': password},
      options: Options(extra: const {'skipAuth': true}),
    );
    return AuthRemoteSession.fromJson(response.data ?? {});
  }

  @override
  Future<AuthRemoteSession> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _dio.post<Map<String, Object?>>(
      'auth/register',
      data: {
        'email': email,
        'password': password,
        if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
      },
      options: Options(extra: const {'skipAuth': true}),
    );
    return AuthRemoteSession.fromJson(response.data ?? {});
  }

  @override
  Future<AuthRemoteSession> refresh(String refreshToken) async {
    final response = await _dio.post<Map<String, Object?>>(
      'auth/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(extra: const {'skipAuth': true}),
    );
    return AuthRemoteSession.fromJson(response.data ?? {});
  }

  @override
  Future<RemoteUser> me() async {
    final response = await _dio.get<Map<String, Object?>>('users/me');
    return RemoteUser.fromJson(response.data ?? {});
  }

  @override
  Future<void> logout(String? refreshToken) async {
    final data = refreshToken == null ? null : {'refreshToken': refreshToken};
    await _dio.post<void>('auth/logout', data: data);
  }
}

final class AuthRemoteSession {
  const AuthRemoteSession({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  final String accessToken;
  final String refreshToken;
  final RemoteUser? user;

  factory AuthRemoteSession.fromJson(Map<String, Object?> json) {
    final session = AuthSessionModel.fromJson(json);
    final source = _unwrapData(json);
    final userJson = source['user'];
    return AuthRemoteSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      user: userJson is Map<String, Object?>
          ? RemoteUser.fromJson(userJson)
          : userJson is Map
          ? RemoteUser.fromJson(Map<String, Object?>.from(userJson))
          : null,
    );
  }
}

final class RemoteUser {
  const RemoteUser({
    required this.id,
    required this.email,
    this.fullName,
    required this.currencyCode,
  });

  final String id;
  final String email;
  final String? fullName;
  final String currencyCode;

  factory RemoteUser.fromJson(Map<String, Object?> json) {
    final model = UserModel.fromJson(json);
    return RemoteUser(
      id: model.id,
      email: model.email,
      fullName: model.fullName,
      currencyCode: model.currencyCode,
    );
  }

  AuthUser toDomain() {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName,
      currencyCode: currencyCode,
    ).toDomain();
  }
}

Map<String, Object?> _unwrapData(Map<String, Object?> json) {
  final data = json['data'];
  if (data is Map<String, Object?>) {
    return data;
  }
  if (data is Map) {
    return Map<String, Object?>.from(data);
  }
  return json;
}
