import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../../features/map/data/datasources/map_remote_datasource.dart';

class SyncService {
  final AppDatabase db;
  final MapRemoteDataSource remoteDataSource;

  SyncService({required this.db, required this.remoteDataSource});

  Future<void> flush() async {
    final pending = await db.getPendingExplorations();
    if (pending.isEmpty) return;

    debugPrint('[SyncService] Flushing ${pending.length} queued explorations');

    for (final item in pending) {
      try {
        await remoteDataSource.registerExploration(
          latitude: item.latitude,
          longitude: item.longitude,
          accuracy: item.accuracy,
          speed: item.speed,
        );
        await db.deleteFromQueue(item.id);
      } catch (e) {
        debugPrint('[SyncService] Failed to sync item ${item.id}: $e');
        break; // stop on first failure — retry on next online event
      }
    }
  }
}
