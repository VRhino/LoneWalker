class ApiEndpoints {
  // Auth
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authVerify = '/auth/verify';

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

  // Ranking
  static const String rankingGlobal = '/ranking/global';
  static const String rankingWeekly = '/ranking/weekly';
  static const String rankingPosition = '/ranking/position';
  static String rankingDistrict(String id) => '/ranking/district/$id';

  // Landmarks
  static const String landmarks = '/landmarks';
  static const String landmarksApproved = '/landmarks/approved';
  static String landmarkById(String id) => '/landmarks/$id';
  static String landmarkVotes(String id) => '/landmarks/$id/votes';
  static String landmarkComments(String id) => '/landmarks/$id/comments';

  // Medals
  static const String medals = '/medals';
  static const String medalsUnlocked = '/medals/my';
}
