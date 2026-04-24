import '../../domain/entities/map_state.dart';

class MapLocationModel extends MapLocation {
  const MapLocationModel({
    required double latitude,
    required double longitude,
    required double accuracy,
  }) : super(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
        );

  factory MapLocationModel.fromJson(Map<String, dynamic> json) {
    return MapLocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy_meters'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy_meters': accuracy,
      };
}

class ExplorationStatsModel extends ExplorationStats {
  const ExplorationStatsModel({
    required double explorationPercent,
    required int totalXp,
    required double newAreasCleared,
    required int xpEarned,
    required List<DistrictExploration> districts,
  }) : super(
          explorationPercent: explorationPercent,
          totalXp: totalXp,
          newAreasCleared: newAreasCleared,
          xpEarned: xpEarned,
          districts: districts,
        );

  factory ExplorationStatsModel.fromJson(Map<String, dynamic> json) {
    return ExplorationStatsModel(
      explorationPercent: (json['exploration_percent'] as num).toDouble(),
      totalXp: json['total_xp'] as int,
      newAreasCleared: (json['new_areas_cleared'] as num).toDouble(),
      xpEarned: json['xp_earned'] as int,
      districts: (json['districts_explored'] as List<dynamic>)
          .map((d) => DistrictExplorationModel.fromJson(d))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'exploration_percent': explorationPercent,
        'total_xp': totalXp,
        'new_areas_cleared': newAreasCleared,
        'xp_earned': xpEarned,
        'districts_explored': districts
            .map((d) => {
                  'district_id': d.districtId,
                  'name': d.name,
                  'exploration_percent': d.explorationPercent,
                  'mastery_level': d.masteryLevel,
                })
            .toList(),
      };
}

class DistrictExplorationModel extends DistrictExploration {
  const DistrictExplorationModel({
    required String districtId,
    required String name,
    required double explorationPercent,
    required String masteryLevel,
  }) : super(
          districtId: districtId,
          name: name,
          explorationPercent: explorationPercent,
          masteryLevel: masteryLevel,
        );

  factory DistrictExplorationModel.fromJson(Map<String, dynamic> json) {
    return DistrictExplorationModel(
      districtId: json['district_id'] as String,
      name: json['name'] as String,
      explorationPercent: (json['exploration_percent'] as num).toDouble(),
      masteryLevel: json['mastery_level'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'district_id': districtId,
        'name': name,
        'exploration_percent': explorationPercent,
        'mastery_level': masteryLevel,
      };
}
