abstract final class AppConfig {
  // Temporary Android emulator backend URL for local development.
  static const apiBaseUrl = 'https://flowfi-be.onrender.com/api/v1/';
  // Switch to an API gateway or environment-provided URL when available.
  // static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
}
