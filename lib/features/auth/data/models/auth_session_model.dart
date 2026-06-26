final class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthSessionModel.fromJson(Map<String, Object?> json) {
    final source = _unwrapData(json);
    final accessToken = source['accessToken'];
    final refreshToken = source['refreshToken'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const FormatException('Missing accessToken in auth response.');
    }
    if (refreshToken is! String || refreshToken.isEmpty) {
      throw const FormatException('Missing refreshToken in auth response.');
    }
    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
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
