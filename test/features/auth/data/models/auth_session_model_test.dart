import 'package:flowfi_fe/features/auth/data/models/auth_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses top-level access and refresh tokens', () {
    final session = AuthSessionModel.fromJson({
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
    });

    expect(session.accessToken, 'access-token');
    expect(session.refreshToken, 'refresh-token');
  });

  test('parses tokens wrapped in a data object', () {
    final session = AuthSessionModel.fromJson({
      'data': {'accessToken': 'access-token', 'refreshToken': 'refresh-token'},
    });

    expect(session.accessToken, 'access-token');
    expect(session.refreshToken, 'refresh-token');
  });

  test('throws format exception when a token is missing', () {
    expect(
      () => AuthSessionModel.fromJson({'accessToken': 'access-token'}),
      throwsA(isA<FormatException>()),
    );
  });
}
