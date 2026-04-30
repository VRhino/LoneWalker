import 'package:equatable/equatable.dart';

const double kFullExploredLevel = 1.0;

class MapLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double accuracy;

  const MapLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy];
}

class ExploredArea extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime exploredAt;
  final double exploredLevel;

  const ExploredArea({
    required this.latitude,
    required this.longitude,
    required this.exploredAt,
    this.exploredLevel = kFullExploredLevel,
  });

  @override
  List<Object?> get props => [latitude, longitude, exploredAt, exploredLevel];
}

class ExplorationStats extends Equatable {
  final double explorationPercent;
  final int totalXp;
  final double newAreasCleared;
  final int xpEarned;
  final List<DistrictExploration> districts;

  const ExplorationStats({
    required this.explorationPercent,
    required this.totalXp,
    required this.newAreasCleared,
    required this.xpEarned,
    required this.districts,
  });

  @override
  List<Object?> get props => [
        explorationPercent,
        totalXp,
        newAreasCleared,
        xpEarned,
        districts,
      ];
}

class DistrictExploration extends Equatable {
  final String districtId;
  final String name;
  final double explorationPercent;
  final String masteryLevel;

  const DistrictExploration({
    required this.districtId,
    required this.name,
    required this.explorationPercent,
    required this.masteryLevel,
  });

  @override
  List<Object?> get props =>
      [districtId, name, explorationPercent, masteryLevel];
}
