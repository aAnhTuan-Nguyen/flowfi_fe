import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowfi_fe/core/config/app_config.dart';

void main() {
  tearDown(dotenv.clean);

  test('uses the default API base URL when dotenv is not loaded', () {
    expect(AppConfig.apiBaseUrl, 'http://localhost:3005/api/v1/');
  });

  test('reads the API base URL from dotenv when it is loaded', () {
    dotenv.loadFromString(
      envString: 'API_BASE_URL=https://api.example.com/api/v1/',
    );

    expect(AppConfig.apiBaseUrl, 'https://api.example.com/api/v1/');
  });
}
