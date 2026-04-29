import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../config/app_config.dart';
import '../../../../core/services/location_service.dart';
import '../../data/datasources/map_remote_datasource.dart';
import '../../data/models/map_models.dart';
import '../../domain/entities/map_state.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapRemoteDataSource remoteDataSource;
  final LocationService locationService;

  List<ExploredArea> _lastExploredAreas = [];
  ExplorationStats? _lastStats;
  StreamSubscription<Position>? _gpsSub;

  MapBloc({
    required this.remoteDataSource,
    required this.locationService,
  }) : super(const MapInitial()) {
    on<InitMapEvent>(_onInitMap);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<LoadFogEvent>(_onLoadFog);
    on<LoadProgressEvent>(_onLoadProgress);
    on<RefreshMapEvent>(_onRefreshMap);

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
  }

  @override
  Future<void> close() {
    _gpsSub?.cancel();
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

  Future<void> _onInitMap(
    InitMapEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    try {
      final granted = await locationService.requestPermission();
      if (!granted) throw Exception('Location permission denied');

      // getCurrentPosition primero: establece sesión de ubicación activa
      // antes de iniciar el foreground service (requerido en Android 14+)
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: AppConfig.positionRequestTimeout,
      );

      locationService.startTracking();

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

  Future<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    final newLocation = MapLocationModel(
      latitude: event.latitude,
      longitude: event.longitude,
      accuracy: event.accuracy,
    );

    if (_lastStats != null) {
      emit(LocationUpdated(
        location: newLocation,
        stats: _lastStats!,
        exploredAreas: _lastExploredAreas,
      ));
    }

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
      emit(MapError(message: e.toString().replaceFirst('Exception: ', '')));
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
