abstract final class AppConfig {
  // cái này hard code thôi máy ai ip sao tự thay
  static const apiBaseUrl = 'http://localhost:8080'; 
  // Này mai mốt clear api chạy qua qpi gateway nào rồi thay
  // static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
}
