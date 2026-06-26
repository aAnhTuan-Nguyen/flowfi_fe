import 'token_storage.dart';

final class AuthSessionManager {
  AuthSessionManager(this._tokenStorage);

  final TokenStorage _tokenStorage;
  String? _accessToken;

  String? get accessToken => _accessToken;

  Future<String?> readRefreshToken() {
    return _tokenStorage.readRefreshToken();
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    await _tokenStorage.saveRefreshToken(refreshToken);
  }

  void updateAccessToken(String accessToken) {
    _accessToken = accessToken;
  }

  Future<void> clear() async {
    _accessToken = null;
    await _tokenStorage.clearRefreshToken();
  }
}
