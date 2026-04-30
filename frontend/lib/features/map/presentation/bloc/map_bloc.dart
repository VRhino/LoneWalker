import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../config/app_config.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../data/datasources/map_remote_datasource.dart';
import '../../data/models/map_models.dart';
import '../../domain/entities/map_state.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapRemoteDataSource remoteDataSource;
  final LocationService locationService;
  final AppDatabase? db;
  final ConnectivityService? connectivityService;
  final SyncService? syncService;

  List<ExploredArea> _lastExploredAreas = [];
  ExplorationStats? _lastStats;
  StreamSubscription<Position>? _gpsSub;
  StreamSubscription<bool>? _connectivitySub;
  bool _isSendingEnabled = true;

  MapBloc({
    required this.remoteDataSource,
    required this.locationService,
    this.db,
    this.connectivityService,
    this.syncService,
  }) : super(const MapInitial()) {
    on<InitMapEvent>(_onInitMap);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<LoadFogEvent>(_onLoadFog);
    on<LoadProgressEvent>(_onLoadProgress);
    on<RefreshMapEvent>(_onRefreshMap);
    on<ToggleExplorationSendingEvent>(_onToggleSending);
    on<SyncPendingExplorationsEvent>(_onSyncPending);

    _gpsSub = locationService.positionStream.listen(
      (position) {
        add(UpdateLocationEvent(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          speed: position.speed * 3.6,
        ));
      },
      onError: (_) {},
      cancelOnError: false,
    );

    _connectivitySub = connectivityService?.isOnlineStream.listen((isOnline) {
      if (isOnline) add(const SyncPendingExplorationsEvent());
    });
  }

  @override
  Future<void> close() {
    _gpsSub?.cancel();
    _connectivitySub?.cancel();
    return super.close();
  }

  List<ExploredArea> _parseExploredAreas(Map<String, dynamic> mapData) {
    final fogOfWar = mapData['fog_of_war'] as Map<String, dynamic>?;
    final features = fogOfWar?['features'] as List<dynamic>? ?? [];
    return features
        .whereType<Map<String, dynamic>>()
        .map(ExploredAreaModel.fromGeoJsonFeature)
        .toList();
  }

  Future<void> _saveFogCache(List<ExploredArea> areas) async {
    if (db == null || areas.isEmpty) return;
    await db!.replaceFogCache(
      areas
          .map((a) => (
                lat: a.latitude,
                lng: a.longitude,
                exploredAt: a.exploredAt,
              ))
          .toList(),
    );
  }

  Future<List<ExploredArea>> _loadFogCache() async {
    if (db == null) return const [];
    final cached = await db!.getCachedFogAreas();
    return cached
        .map((c) => ExploredAreaModel(
              latitude: c.lat,
              longitude: c.lng,
              exploredAt: c.exploredAt,
            ))
        .toList();
  }

  Future<void> _onInitMap(
    InitMapEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    try {
      final granted = await locationService.requestPermission();
      if (!granted) throw Exception('Location permission denied');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: AppConfig.positionRequestTimeout,
      );

      locationService.startTracking();

      final userLocation = MapLocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      try {
        final mapData = await remoteDataSource.getMapWithFog(
          latitude: position.latitude,
          longitude: position.longitude,
          radius: AppConfig.defaultSearchRadiusMeters.toDouble(),
        );
        final stats = await remoteDataSource.getExplorationProgress();

        _lastExploredAreas = _parseExploredAreas(mapData);
        _lastStats = stats;

        await _saveFogCache(_lastExploredAreas);

        if (connectivityService?.isOnline == true) {
          add(const SyncPendingExplorationsEvent());
        }

        emit(MapLoaded(
          userLocation: userLocation,
          explorationStats: stats,
          mapData: mapData,
          exploredAreas: _lastExploredAreas,
        ));
      } catch (apiError) {
        // API unavailable — try local fog cache
        final cached = await _loadFogCache();
        if (cached.isNotEmpty) {
          _lastExploredAreas = cached;
          emit(MapLoaded(
            userLocation: userLocation,
            explorationStats: const ExplorationStats(
              explorationPercent: 0,
              totalXp: 0,
              newAreasCleared: 0,
              xpEarned: 0,
              districts: [],
            ),
            mapData: const {},
            exploredAreas: _lastExploredAreas,
          ));
        } else {
          emit(MapError(
              message: apiError.toString().replaceFirst('Exception: ', '')));
        }
      }
    } catch (e) {
      emit(MapError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    final newLocation = MapLocationModel(
      latitude: event.latitude,
      longitude: event.longitude,
      accuracy: event.accuracy,
    );

    emit(LocationUpdated(
      location: newLocation,
      stats: _lastStats ??
          const ExplorationStats(
            explorationPercent: 0,
            totalXp: 0,
            newAreasCleared: 0,
            xpEarned: 0,
            districts: [],
          ),
      exploredAreas: _lastExploredAreas,
    ));

    if (event.speed > AppConfig.speedLimitKmh) {
      emit(SpeedLimitExceeded(
        currentSpeed: event.speed,
        speedLimit: AppConfig.speedLimitKmh,
      ));
      return;
    }

    if (event.accuracy > AppConfig.gpsAccuracyThreshold) {
      emit(GPSAccuracyWarning(
        accuracy: event.accuracy,
        requiredAccuracy: AppConfig.gpsAccuracyThreshold,
      ));
      return;
    }

    if (!_isSendingEnabled) return;

    try {
      final stats = await remoteDataSource.registerExploration(
        latitude: event.latitude,
        longitude: event.longitude,
        accuracy: event.accuracy,
        speed: event.speed,
      );

      final newPoint = ExploredAreaModel(
        latitude: event.latitude,
        longitude: event.longitude,
        exploredAt: DateTime.now(),
      );
      _lastExploredAreas = [..._lastExploredAreas, newPoint];
      _lastStats = stats;

      emit(ExplorationRegistered(
        stats: stats,
        xpEarned: stats.xpEarned,
        newAreasCleared: stats.newAreasCleared,
        userLocation: newLocation,
        exploredAreas: _lastExploredAreas,
      ));
    } catch (e) {
      if (db != null && !(connectivityService?.isOnline ?? true)) {
        await db!.queueExploration(
          latitude: event.latitude,
          longitude: event.longitude,
          accuracy: event.accuracy,
          speed: event.speed,
        );
        debugPrint('[MapBloc] GPS point queued offline');
      } else {
        debugPrint('[MapBloc] exploration sync failed: $e');
      }
    }
  }

  Future<void> _onLoadFog(
    LoadFogEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      final mapData = await remoteDataSource.getMapWithFog(
        latitude: event.latitude,
        longitude: event.longitude,
        radius: event.radius,
      );

      final stats = await remoteDataSource.getExplorationProgress();

      final userLocation = MapLocationModel(
        latitude: event.latitude,
        longitude: event.longitude,
        accuracy: AppConfig.defaultGpsAccuracyEstimate,
      );

      _lastExploredAreas = _parseExploredAreas(mapData);
      _lastStats = stats;

      await _saveFogCache(_lastExploredAreas);

      emit(MapLoaded(
        userLocation: userLocation,
        explorationStats: stats,
        mapData: mapData,
        exploredAreas: _lastExploredAreas,
      ));
    } catch (e) {
      emit(MapError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadProgress(
    LoadProgressEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      final stats = await remoteDataSource.getExplorationProgress();

      if (state is MapLoaded) {
        final mapLoaded = state as MapLoaded;
        _lastStats = stats;
        emit(MapLoaded(
          userLocation: mapLoaded.userLocation,
          explorationStats: stats,
          mapData: mapLoaded.mapData,
          exploredAreas: mapLoaded.exploredAreas,
        ));
      }
    } catch (e) {
      emit(MapError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onToggleSending(
    ToggleExplorationSendingEvent event,
    Emitter<MapState> emit,
  ) {
    _isSendingEnabled = event.isEnabled;
  }

  Future<void> _onSyncPending(
    SyncPendingExplorationsEvent event,
    Emitter<MapState> emit,
  ) async {
    await syncService?.flush();
  }

  Future<void> _onRefreshMap(
    RefreshMapEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final mapData = await remoteDataSource.getMapWithFog(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: AppConfig.defaultSearchRadiusMeters.toDouble(),
      );

      final stats = await remoteDataSource.getExplorationProgress();

      final userLocation = MapLocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      _lastExploredAreas = _parseExploredAreas(mapData);
      _lastStats = stats;

      await _saveFogCache(_lastExploredAreas);

      emit(MapLoaded(
        userLocation: userLocation,
        explorationStats: stats,
        mapData: mapData,
        exploredAreas: _lastExploredAreas,
      ));
    } catch (e) {
      emit(MapError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
