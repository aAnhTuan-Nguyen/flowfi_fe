import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static const _defaultApiBaseUrl = 'http://localhost:3005/api/v1/';

  static String get apiBaseUrl {
    if (!dotenv.isInitialized) {
      return _defaultApiBaseUrl;
    }

    return dotenv.get('API_BASE_URL', fallback: _defaultApiBaseUrl);
  }
}
