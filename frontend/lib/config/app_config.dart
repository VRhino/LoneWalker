/// Application Configuration
/// Centralized configuration for the LoneWalker app
class AppConfig {
  // App Information
  static const String appName = 'LoneWalker';
  static const String appVersion = '0.1.0';
  static const String appBuild = '1';

  // Environment
  static const String environment = String.fromEnvironment(
    'FLUTTER_ENVIRONMENT',
    defaultValue: 'development',
  );

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://localhost:3000',
  );

  // Feature Flags
  static const bool enableDebugLogging = !bool.fromEnvironment(
    'DART_DEFINE_PRODUCTION',
    defaultValue: false,
  );

  // Map Configuration
  static const double mapDefaultZoom = 15.0;
  static const double fogOfWarRadius = 75.0; // meters — radius cleared per GPS point
  static const double treasureRadiusActivation = 75.0; // meters — proximity to show treasure
  static const double treasureRadiusClaim = 10.0; // meters — proximity to claim

  // Radar
  static const double radarDisplayRadiusMeters = 1000.0; // max distance shown on radar screen

  // Default map location (fallback when GPS is unavailable)
  static const double defaultLatitude = 40.4168; // Madrid, Spain
  static const double defaultLongitude = -3.7038;

  // Search radius
  static const int defaultSearchRadiusMeters = 5000;

  // Speeds & Velocities
  static const double speedLimitKmh = 20.0; // Max speed for exploration
  static const double gpsAccuracyThreshold = 50.0; // meters

  // GPS
  static const double defaultGpsAccuracyEstimate = 10.0; // used when real accuracy is unknown

  // Timing
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationUpdateInterval = Duration(seconds: 5);
  static const Duration mapRefreshInterval = Duration(seconds: 10);
  static const Duration positionRequestTimeout = Duration(seconds: 10);

  // UI Configuration
  static const String fontFamily = 'Poppins';

  static String getEnvironmentString() {
    switch (environment) {
      case 'production':
        return 'Production';
      case 'staging':
        return 'Staging';
      default:
        return 'Development';
    }
  }

  static bool isProduction() => environment == 'production';
  static bool isStaging() => environment == 'staging';
  static bool isDevelopment() => environment == 'development';
}
