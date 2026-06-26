import 'package:flowfi_fe/core/auth/auth_session_manager.dart';
import 'package:flowfi_fe/core/auth/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps access token in memory and refresh token in storage', () async {
    final storage = FakeTokenStorage();
    final manager = AuthSessionManager(storage);

    await manager.saveSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );

    expect(manager.accessToken, 'access-token');
    expect(await storage.readRefreshToken(), 'refresh-token');
  });

  test('clears both in-memory and persisted tokens', () async {
    final storage = FakeTokenStorage();
    final manager = AuthSessionManager(storage);
    await manager.saveSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );

    await manager.clear();

    expect(manager.accessToken, isNull);
    expect(await storage.readRefreshToken(), isNull);
  });

  test(
    'loads refresh token from storage without persisting access token',
    () async {
      final storage = FakeTokenStorage()..refreshToken = 'refresh-token';
      final manager = AuthSessionManager(storage);

      final token = await manager.readRefreshToken();

      expect(token, 'refresh-token');
      expect(manager.accessToken, isNull);
    },
  );
}

class FakeTokenStorage implements TokenStorage {
  String? refreshToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearRefreshToken() async {
    refreshToken = null;
  }
}
