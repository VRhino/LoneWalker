import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lonewalker/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  group('ExplorationQueue', () {
    test('queueExploration + getPendingExplorations returns the entry',
        () async {
      await db.queueExploration(
        latitude: 40.416775,
        longitude: -3.703790,
        accuracy: 5.0,
        speed: 0.0,
      );

      final pending = await db.getPendingExplorations();
      expect(pending.length, 1);
      expect(pending.first.latitude, closeTo(40.416775, 0.0001));
      expect(pending.first.longitude, closeTo(-3.703790, 0.0001));
    });

    test('deleteFromQueue removes the entry', () async {
      await db.queueExploration(
        latitude: 1.0,
        longitude: 2.0,
        accuracy: 10.0,
        speed: 0.0,
      );
      final pending = await db.getPendingExplorations();
      expect(pending.length, 1);

      await db.deleteFromQueue(pending.first.id);

      final afterDelete = await db.getPendingExplorations();
      expect(afterDelete, isEmpty);
    });

    test('getPendingCount returns correct count', () async {
      expect(await db.getPendingCount(), 0);

      await db.queueExploration(
        latitude: 1.0,
        longitude: 2.0,
        accuracy: 5.0,
        speed: 1.0,
      );
      await db.queueExploration(
        latitude: 3.0,
        longitude: 4.0,
        accuracy: 5.0,
        speed: 1.0,
      );

      expect(await db.getPendingCount(), 2);
    });
  });

  group('CachedFogAreas', () {
    test('replaceFogCache + getCachedFogAreas round-trips values', () async {
      final now = DateTime.now().toUtc();
      final areas = [
        (lat: 40.0, lng: -3.0, exploredAt: now),
        (
          lat: 41.0,
          lng: -4.0,
          exploredAt: now.subtract(const Duration(days: 1))
        ),
      ];

      await db.replaceFogCache(areas);
      final cached = await db.getCachedFogAreas();

      expect(cached.length, 2);
      expect(cached[0].lat, closeTo(40.0, 0.0001));
      expect(cached[1].lng, closeTo(-4.0, 0.0001));
    });

    test('replaceFogCache replaces previous cache atomically', () async {
      final t1 = DateTime.utc(2025, 1, 1);
      await db.replaceFogCache([(lat: 1.0, lng: 1.0, exploredAt: t1)]);
      await db.replaceFogCache([(lat: 2.0, lng: 2.0, exploredAt: t1)]);

      final cached = await db.getCachedFogAreas();
      expect(cached.length, 1);
      expect(cached.first.lat, closeTo(2.0, 0.0001));
    });

    test('getCachedFogAreas returns empty list when cache is empty', () async {
      final cached = await db.getCachedFogAreas();
      expect(cached, isEmpty);
    });
  });
}
