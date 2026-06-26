import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<String?> readRefreshToken();

  Future<void> saveRefreshToken(String refreshToken);

  Future<void> clearRefreshToken();
}

final class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  static const _refreshTokenKey = 'flowfi.refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) {
    return _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> clearRefreshToken() {
    return _storage.delete(key: _refreshTokenKey);
  }
}
