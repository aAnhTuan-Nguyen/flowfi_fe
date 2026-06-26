import 'package:flowfi_fe/core/auth/auth_session_manager.dart';
import 'package:flowfi_fe/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flowfi_fe/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/auth/auth_session_manager_test.dart';

void main() {
  test('signs in and persists the returned session', () async {
    final sessionManager = AuthSessionManager(FakeTokenStorage());
    final remote = FakeAuthRemoteDataSource();
    final repository = AuthRepositoryImpl(remote, sessionManager);

    final user = await repository.signIn(
      email: 'alex@example.com',
      password: 'password123',
    );

    expect(user.email, 'alex@example.com');
    expect(sessionManager.accessToken, 'access-token');
    expect(await sessionManager.readRefreshToken(), 'refresh-token');
    expect(remote.loginEmail, 'alex@example.com');
  });

  test('signs out remotely and clears local session', () async {
    final sessionManager = AuthSessionManager(FakeTokenStorage());
    await sessionManager.saveSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );
    final remote = FakeAuthRemoteDataSource();
    final repository = AuthRepositoryImpl(remote, sessionManager);

    await repository.signOut();

    expect(remote.logoutRefreshToken, 'refresh-token');
    expect(sessionManager.accessToken, isNull);
    expect(await sessionManager.readRefreshToken(), isNull);
  });
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  String? loginEmail;
  String? logoutRefreshToken;

  @override
  Future<AuthRemoteSession> login({
    required String email,
    required String password,
  }) async {
    loginEmail = email;
    return const AuthRemoteSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      user: RemoteUser(
        id: 'user-1',
        email: 'alex@example.com',
        fullName: 'Alex Morgan',
        currencyCode: 'VND',
      ),
    );
  }

  @override
  Future<AuthRemoteSession> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return login(email: email, password: password);
  }

  @override
  Future<AuthRemoteSession> refresh(String refreshToken) async {
    return const AuthRemoteSession(
      accessToken: 'new-access-token',
      refreshToken: 'new-refresh-token',
      user: RemoteUser(
        id: 'user-1',
        email: 'alex@example.com',
        fullName: 'Alex Morgan',
        currencyCode: 'VND',
      ),
    );
  }

  @override
  Future<RemoteUser> me() async {
    return const RemoteUser(
      id: 'user-1',
      email: 'alex@example.com',
      fullName: 'Alex Morgan',
      currencyCode: 'VND',
    );
  }

  @override
  Future<void> logout(String? refreshToken) async {
    logoutRefreshToken = refreshToken;
  }
}
