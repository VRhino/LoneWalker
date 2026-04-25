import 'package:equatable/equatable.dart';
import '../../domain/entities/map_state.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  final MapLocation userLocation;
  final ExplorationStats explorationStats;
  final Map<String, dynamic> mapData;
  final List<ExploredArea> exploredAreas;

  const MapLoaded({
    required this.userLocation,
    required this.explorationStats,
    required this.mapData,
    required this.exploredAreas,
  });

  @override
  List<Object?> get props =>
      [userLocation, explorationStats, mapData, exploredAreas];
}

class ExplorationRegistered extends MapState {
  final ExplorationStats stats;
  final int xpEarned;
  final double newAreasCleared;
  final MapLocation userLocation;
  final List<ExploredArea> exploredAreas;

  const ExplorationRegistered({
    required this.stats,
    required this.xpEarned,
    required this.newAreasCleared,
    required this.userLocation,
    required this.exploredAreas,
  });

  @override
  List<Object?> get props =>
      [stats, xpEarned, newAreasCleared, userLocation, exploredAreas];
}

class LocationUpdated extends MapState {
  final MapLocation location;
  final ExplorationStats stats;

  const LocationUpdated({
    required this.location,
    required this.stats,
  });

  @override
  List<Object?> get props => [location, stats];
}

class SpeedLimitExceeded extends MapState {
  final double currentSpeed;
  final double speedLimit;

  const SpeedLimitExceeded({
    required this.currentSpeed,
    required this.speedLimit,
  });

  @override
  List<Object?> get props => [currentSpeed, speedLimit];
}

class GPSAccuracyWarning extends MapState {
  final double accuracy;
  final double requiredAccuracy;

  const GPSAccuracyWarning({
    required this.accuracy,
    required this.requiredAccuracy,
  });

  @override
  List<Object?> get props => [accuracy, requiredAccuracy];
}

class MapError extends MapState {
  final String message;

  const MapError({required this.message});

  @override
  List<Object?> get props => [message];
}
