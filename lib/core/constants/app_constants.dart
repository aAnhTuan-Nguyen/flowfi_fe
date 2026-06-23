/// FlowFi App Constants
abstract final class AppConstants {
  // ─── App Info ─────────────────────────────────────────────────
  static const String appName = 'FlowFi';
  static const String appVersion = '1.0.0';

  // ─── API ──────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ─── Storage Keys ─────────────────────────────────────────────
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';

  // ─── UI ───────────────────────────────────────────────────────
  static const double cardBorderRadius = 20.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 12.0;
  static const double containerMargin = 20.0;
  static const double columnGutter = 16.0;

  // ─── Spacing (8px baseline grid) ──────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // ─── Animation ────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 700);
  static const Duration splashDuration = Duration(seconds: 2);
}
