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
  static const double fogOfWarRadius = 75.0; // meters
  static const double treasureRadiusActivation = 75.0; // meters
  static const double treasureRadiusClaim = 10.0; // meters

  // Speeds & Velocities
  static const double speedLimitKmh = 20.0; // Max speed for exploration
  static const double gpsAccuracyThreshold = 50.0; // meters

  // Timing
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationUpdateInterval = Duration(seconds: 5);
  static const Duration mapRefreshInterval = Duration(seconds: 10);

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
