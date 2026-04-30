import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lonewalker/core/database/app_database.dart';
import 'package:lonewalker/core/services/sync_service.dart';
import 'package:lonewalker/features/map/data/datasources/map_remote_datasource.dart';
import 'package:lonewalker/features/map/data/models/map_models.dart';

import '../../helpers/test_fakes.dart';

class _TrackingMapDataSource extends MapRemoteDataSource {
  int registerCallCount = 0;
  int? failOnCallNumber;

  _TrackingMapDataSource() : super(apiClient: FakeApiClient());

  @override
  Future<ExplorationStatsModel> registerExploration({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
  }) async {
    registerCallCount++;
    if (failOnCallNumber != null && registerCallCount >= failOnCallNumber!) {
      throw Exception('Simulated network failure');
    }
    return testStats;
  }

  @override
  Future<ExplorationStatsModel> getExplorationProgress() async => testStats;

  @override
  Future<Map<String, dynamic>> getMapWithFog({
    required double latitude,
    required double longitude,
    required double radius,
  }) async =>
      {};
}

void main() {
  late AppDatabase db;
  late _TrackingMapDataSource fakeRemote;
  late SyncService syncService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fakeRemote = _TrackingMapDataSource();
    syncService = SyncService(db: db, remoteDataSource: fakeRemote);
  });

  tearDown(() => db.close());

  test('flush with empty queue does not call registerExploration', () async {
    await syncService.flush();

    expect(fakeRemote.registerCallCount, 0);
  });

  test('flush sends all queued items and clears the queue', () async {
    await db.queueExploration(
        latitude: 40.0, longitude: -3.0, accuracy: 5.0, speed: 0.0);
    await db.queueExploration(
        latitude: 41.0, longitude: -4.0, accuracy: 5.0, speed: 0.0);
    await db.queueExploration(
        latitude: 42.0, longitude: -5.0, accuracy: 5.0, speed: 0.0);

    await syncService.flush();

    expect(fakeRemote.registerCallCount, 3);
    expect(await db.getPendingCount(), 0);
  });

  test('flush stops on first failure and leaves remaining items in queue',
      () async {
    await db.queueExploration(
        latitude: 40.0, longitude: -3.0, accuracy: 5.0, speed: 0.0);
    await db.queueExploration(
        latitude: 41.0, longitude: -4.0, accuracy: 5.0, speed: 0.0);
    await db.queueExploration(
        latitude: 42.0, longitude: -5.0, accuracy: 5.0, speed: 0.0);

    fakeRemote.failOnCallNumber = 2; // second call throws

    await syncService.flush();

    expect(
        fakeRemote.registerCallCount, 2); // attempted 2nd call before failing
    expect(await db.getPendingCount(), 2); // first removed, 2 remain
  });
}
