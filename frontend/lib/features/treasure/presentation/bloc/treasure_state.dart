import 'package:equatable/equatable.dart';
import '../../data/models/treasure_model.dart';

abstract class TreasureState extends Equatable {
  const TreasureState();

  @override
  List<Object?> get props => [];
}

class TreasureInitial extends TreasureState {
  const TreasureInitial();
}

class TreasureLoading extends TreasureState {
  const TreasureLoading();
}

class RadarActive extends TreasureState {
  final List<RadarTreasureModel> treasures;
  final double userLatitude;
  final double userLongitude;

  const RadarActive({
    required this.treasures,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  List<Object?> get props => [treasures, userLatitude, userLongitude];
}

class NearbyTreasuresLoaded extends TreasureState {
  final List<TreasureModel> treasures;

  const NearbyTreasuresLoaded({required this.treasures});

  @override
  List<Object?> get props => [treasures];
}

class TreasureDetailsLoaded extends TreasureState {
  final TreasureModel treasure;
  final List<TreasureWallOfFameModel> wallOfFame;

  const TreasureDetailsLoaded({
    required this.treasure,
    required this.wallOfFame,
  });

  @override
  List<Object?> get props => [treasure, wallOfFame];
}

class TreasureClaimSuccess extends TreasureState {
  final TreasureModel treasure;
  final int xpEarned;
  final String message;

  const TreasureClaimSuccess({
    required this.treasure,
    required this.xpEarned,
    required this.message,
  });

  @override
  List<Object?> get props => [treasure, xpEarned, message];
}

class ClaimsStatsLoaded extends TreasureState {
  final TreasureClaimsStatsModel stats;

  const ClaimsStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

class TreasureError extends TreasureState {
  final String message;

  const TreasureError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GPSValidationInProgress extends TreasureState {
  final String treasureId;
  final double distance;
  final int validationTimeMs;
  final int maxValidationTimeMs;

  const GPSValidationInProgress({
    required this.treasureId,
    required this.distance,
    required this.validationTimeMs,
    this.maxValidationTimeMs = 5000,
  });

  @override
  List<Object?> get props => [treasureId, distance, validationTimeMs];
}

class TreasureNotInRange extends TreasureState {
  final String treasureId;
  final double distance;
  final int maxDistance;

  const TreasureNotInRange({
    required this.treasureId,
    required this.distance,
    required this.maxDistance,
  });

  @override
  List<Object?> get props => [treasureId, distance, maxDistance];
}
