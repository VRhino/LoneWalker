import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../config/app_config.dart';
import '../../data/datasources/map_remote_datasource.dart';
import '../../data/models/map_models.dart';
import '../../domain/entities/map_state.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapRemoteDataSource remoteDataSource;

  MapBloc({required this.remoteDataSource}) : super(const MapInitial()) {
    on<InitMapEvent>(_onInitMap);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<LoadFogEvent>(_onLoadFog);
    on<LoadProgressEvent>(_onLoadProgress);
    on<RefreshMapEvent>(_onRefreshMap);
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
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: AppConfig.positionRequestTimeout,
      );

      // Load map data
      final mapData = await remoteDataSource.getMapWithFog(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: AppConfig.defaultSearchRadiusMeters.toDouble(),
      );

      // Load progress
      final stats = await remoteDataSource.getExplorationProgress();

      final userLocation = MapLocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      emit(MapLoaded(
        userLocation: userLocation,
        explorationStats: stats,
        mapData: mapData,
        exploredAreas: _parseExploredAreas(mapData),
      ));
    } catch (e) {
      emit(MapError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      // Check speed limit
      if (event.speed > AppConfig.speedLimitKmh) {
        emit(SpeedLimitExceeded(
          currentSpeed: event.speed,
          speedLimit: AppConfig.speedLimitKmh,
        ));
        return;
      }

      // Check GPS accuracy
      if (event.accuracy > AppConfig.gpsAccuracyThreshold) {
        emit(GPSAccuracyWarning(
          accuracy: event.accuracy,
          requiredAccuracy: AppConfig.gpsAccuracyThreshold,
        ));
        return;
      }

      // Register exploration
      final stats = await remoteDataSource.registerExploration(
        latitude: event.latitude,
        longitude: event.longitude,
        accuracy: event.accuracy,
        speed: event.speed,
      );

      final prevAreas = (state is MapLoaded)
          ? (state as MapLoaded).exploredAreas
          : <ExploredArea>[];
      final userLocation = MapLocationModel(
        latitude: event.latitude,
        longitude: event.longitude,
        accuracy: event.accuracy,
      );
      final newPoint = ExploredAreaModel(
        latitude: event.latitude,
        longitude: event.longitude,
        exploredAt: DateTime.now(),
      );

      emit(ExplorationRegistered(
        stats: stats,
        xpEarned: stats.xpEarned,
        newAreasCleared: stats.newAreasCleared,
        userLocation: userLocation,
        exploredAreas: [...prevAreas, newPoint],
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

      emit(MapLoaded(
        userLocation: userLocation,
        explorationStats: stats,
        mapData: mapData,
        exploredAreas: _parseExploredAreas(mapData),
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

      emit(MapLoaded(
        userLocation: userLocation,
        explorationStats: stats,
        mapData: mapData,
        exploredAreas: _parseExploredAreas(mapData),
      ));
    } catch (e) {
      emit(MapError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
