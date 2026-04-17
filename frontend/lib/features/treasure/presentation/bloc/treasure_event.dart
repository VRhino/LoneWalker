import 'package:equatable/equatable.dart';

abstract class TreasureEvent extends Equatable {
  const TreasureEvent();

  @override
  List<Object?> get props => [];
}

class ActivateRadarEvent extends TreasureEvent {
  final double latitude;
  final double longitude;

  const ActivateRadarEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class LoadNearbyTreasuresEvent extends TreasureEvent {
  final double latitude;
  final double longitude;
  final int radius;

  const LoadNearbyTreasuresEvent({
    required this.latitude,
    required this.longitude,
    this.radius = 5000,
  });

  @override
  List<Object?> get props => [latitude, longitude, radius];
}

class LoadTreasureDetailsEvent extends TreasureEvent {
  final String treasureId;

  const LoadTreasureDetailsEvent({required this.treasureId});

  @override
  List<Object?> get props => [treasureId];
}

class ClaimTreasureEvent extends TreasureEvent {
  final String treasureId;
  final double latitude;
  final double longitude;
  final double accuracyMeters;

  const ClaimTreasureEvent({
    required this.treasureId,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  @override
  List<Object?> get props => [treasureId, latitude, longitude, accuracyMeters];
}

class LoadWallOfFameEvent extends TreasureEvent {
  final String treasureId;

  const LoadWallOfFameEvent({required this.treasureId});

  @override
  List<Object?> get props => [treasureId];
}

class LoadClaimsStatsEvent extends TreasureEvent {
  const LoadClaimsStatsEvent();
}

class UpdateRadarPositionEvent extends TreasureEvent {
  final double latitude;
  final double longitude;

  const UpdateRadarPositionEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}
