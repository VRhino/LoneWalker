import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('ExplorationQueueEntry')
class ExplorationQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get accuracy => real()();
  RealColumn get speed => real()();
  DateTimeColumn get recordedAt => dateTime()();
}

@DataClassName('CachedFogArea')
class CachedFogAreas extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get exploredAt => text()();
  DateTimeColumn get cachedAt => dateTime()();
}

@DriftDatabase(tables: [ExplorationQueue, CachedFogAreas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // --- Exploration queue ---

  Future<List<ExplorationQueueEntry>> getPendingExplorations() =>
      select(explorationQueue).get();

  Future<void> queueExploration({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
  }) =>
      into(explorationQueue).insert(ExplorationQueueCompanion.insert(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        speed: speed,
        recordedAt: DateTime.now(),
      ));

  Future<void> deleteFromQueue(int id) =>
      (delete(explorationQueue)..where((t) => t.id.equals(id))).go();

  Future<int> getPendingCount() async {
    final rows = await select(explorationQueue).get();
    return rows.length;
  }

  // --- Fog cache ---
  // Uses Dart 3 records so callers don't need to import generated types.

  Future<void> replaceFogCache(
    List<({double lat, double lng, DateTime exploredAt})> areas,
  ) =>
      transaction(() async {
        await delete(cachedFogAreas).go();
        for (final area in areas) {
          await into(cachedFogAreas).insert(CachedFogAreasCompanion.insert(
            latitude: area.lat,
            longitude: area.lng,
            exploredAt: area.exploredAt.toIso8601String(),
            cachedAt: DateTime.now(),
          ));
        }
      });

  Future<List<({double lat, double lng, DateTime exploredAt})>>
      getCachedFogAreas() async {
    final rows = await select(cachedFogAreas).get();
    return rows
        .map((r) => (
              lat: r.latitude,
              lng: r.longitude,
              exploredAt: DateTime.tryParse(r.exploredAt) ?? DateTime.now(),
            ))
        .toList();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'lonewalker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
