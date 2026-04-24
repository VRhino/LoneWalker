import 'package:lonewalker/core/network/api_client.dart';
import 'package:lonewalker/core/network/token_manager.dart';
import 'package:lonewalker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lonewalker/features/auth/data/models/user_model.dart';
import 'package:lonewalker/features/map/data/datasources/map_remote_datasource.dart';
import 'package:lonewalker/features/map/data/models/map_models.dart';
import 'package:lonewalker/features/treasure/data/datasources/treasure_remote_datasource.dart';
import 'package:lonewalker/features/treasure/data/models/treasure_model.dart';
import 'package:lonewalker/features/treasure/domain/entities/treasure.dart';

// ─── Test Data ────────────────────────────────────────────────────────────────

final testUser = UserModel(
  id: 'user-1',
  username: 'testuser',
  email: 'test@test.com',
  privacyMode: 'PUBLIC',
  explorationPercent: 5.5,
  totalXp: 100,
  medalsCount: 2,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
);

final testTreasure = TreasureModel(
  id: 'treasure-1',
  title: 'Test Treasure',
  description: 'A test treasure',
  latitude: 40.4168,
  longitude: -3.7038,
  status: TreasureStatus.active,
  rarity: TreasureRarity.common,
  currentUses: 0,
  claimedByUser: false,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
);

const testRadarTreasure = RadarTreasureModel(
  treasureId: 'treasure-1',
  title: 'Radar Treasure',
  latitude: 40.417,
  longitude: -3.704,
  rarity: TreasureRarity.rare,
  distanceMeters: 50.0,
  bearingDegrees: 45.0,
  proximityPercent: 90.0,
  canClaim: false,
);

const testStats = ExplorationStatsModel(
  explorationPercent: 5.5,
  totalXp: 100,
  newAreasCleared: 3.0,
  xpEarned: 50,
  districts: [],
);

// ─── Fake Token Manager ────────────────────────────────────────────────────────

class FakeTokenManager implements TokenManager {
  String? _accessToken;
  String? _refreshToken;

  void setAuthenticated(bool value) {
    _accessToken = value ? 'fake_access_token' : null;
    _refreshToken = value ? 'fake_refresh_token' : null;
  }

  @override
  String? get accessToken => _accessToken;

  @override
  String? get refreshToken => _refreshToken;

  @override
  bool get isAuthenticated => _accessToken != null;

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

// ─── Fake Api Client ──────────────────────────────────────────────────────────

class FakeApiClient extends ApiClient {
  final FakeTokenManager fakeTokenManager;

  FakeApiClient._internal(FakeTokenManager tm)
      : fakeTokenManager = tm,
        super(tokenManager: tm);

  factory FakeApiClient() => FakeApiClient._internal(FakeTokenManager());
}

// ─── Fake Auth DataSource ─────────────────────────────────────────────────────

class FakeAuthRemoteDataSource extends AuthRemoteDataSource {
  bool loginShouldFail = false;
  bool registerShouldFail = false;
  bool logoutShouldFail = false;

  final FakeApiClient _fakeClient;

  FakeAuthRemoteDataSource()
      : _fakeClient = FakeApiClient(),
        super(apiClient: FakeApiClient());

  @override
  ApiClient get apiClient => _fakeClient;

  void setAuthenticated(bool value) =>
      _fakeClient.fakeTokenManager.setAuthenticated(value);

  @override
  Future<({UserModel user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  }) async {
    if (loginShouldFail) throw Exception('Invalid email or password');
    return (
      user: testUser,
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
    );
  }

  @override
  Future<({UserModel user, String accessToken, String refreshToken})> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    if (registerShouldFail) throw Exception('Email or username already exists');
    return (
      user: testUser,
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
    );
  }

  @override
  Future<void> logout() async {
    if (logoutShouldFail) throw Exception('Logout failed');
    await apiClient.logout();
  }
}

// ─── Fake Treasure DataSource ─────────────────────────────────────────────────

class FakeTreasureRemoteDataSource implements TreasureRemoteDataSource {
  List<RadarTreasureModel> radarData = [];
  List<TreasureModel> nearbyTreasures = [];
  TreasureModel? treasureDetail;
  List<TreasureWallOfFameModel> wallOfFame = [];
  Map<String, dynamic>? claimResponse;
  TreasureClaimsStatsModel? claimsStats;
  Exception? errorToThrow;

  @override
  Future<List<RadarTreasureModel>> getRadarData(
    double latitude,
    double longitude,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    return radarData;
  }

  @override
  Future<List<TreasureModel>> getNearby(
    double latitude,
    double longitude, {
    int radius = 5000,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return nearbyTreasures;
  }

  @override
  Future<TreasureModel> getTreasureById(String treasureId) async {
    if (errorToThrow != null) throw errorToThrow!;
    return treasureDetail ?? testTreasure;
  }

  @override
  Future<Map<String, dynamic>> claimTreasure(
    String treasureId,
    double latitude,
    double longitude,
    double accuracyMeters,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    return claimResponse ??
        {
          'treasure': testTreasure.toJson(),
          'xp_earned': 50,
          'message': 'Treasure claimed successfully!',
        };
  }

  @override
  Future<List<TreasureWallOfFameModel>> getWallOfFame(String treasureId) async {
    if (errorToThrow != null) throw errorToThrow!;
    return wallOfFame;
  }

  @override
  Future<TreasureClaimsStatsModel> getClaimsStats() async {
    if (errorToThrow != null) throw errorToThrow!;
    return claimsStats ??
        const TreasureClaimsStatsModel(
          totalClaimed: 5,
          totalXp: 500,
          byRarity: {TreasureRarity.common: 5},
        );
  }
}

// ─── Fake Map DataSource ──────────────────────────────────────────────────────

class FakeMapRemoteDataSource extends MapRemoteDataSource {
  ExplorationStatsModel? statsToReturn;
  Map<String, dynamic>? mapDataToReturn;
  Exception? errorToThrow;

  FakeMapRemoteDataSource() : super(apiClient: FakeApiClient());

  @override
  Future<ExplorationStatsModel> registerExploration({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return statsToReturn ?? testStats;
  }

  @override
  Future<ExplorationStatsModel> getExplorationProgress() async {
    if (errorToThrow != null) throw errorToThrow!;
    return statsToReturn ?? testStats;
  }

  @override
  Future<Map<String, dynamic>> getMapWithFog({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return mapDataToReturn ?? {'tiles': [], 'explored_area': 5.0};
  }
}
