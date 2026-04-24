class ApiEndpoints {
  // Auth
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';

  // Exploration
  static const String explorationRegister = '/exploration';
  static const String explorationProgress = '/exploration/progress';
  static const String explorationMap = '/exploration/map';
  static const String explorationLast = '/exploration/last';

  // Treasures
  static const String treasuresNearby = '/treasures/nearby';
  static const String treasuresRadar = '/treasures/radar';
  static const String treasuresStatsClaims = '/treasures/stats/claims';
  static String treasureById(String id) => '/treasures/$id';
  static String treasureClaim(String id) => '/treasures/$id/claim';
  static String treasureWallOfFame(String id) => '/treasures/$id/wall-of-fame';
}
