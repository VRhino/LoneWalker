import '../../domain/entities/map_state.dart';

class MapLocationModel extends MapLocation {
  const MapLocationModel({
    required super.latitude,
    required super.longitude,
    required super.accuracy,
  });

  factory MapLocationModel.fromJson(Map<String, dynamic> json) {
    return MapLocationModel(
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
      accuracy:
          double.tryParse(json['accuracy_meters']?.toString() ?? '') ?? 10.0,
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
    required super.explorationPercent,
    required super.totalXp,
    required super.newAreasCleared,
    required super.xpEarned,
    required super.districts,
  });

  factory ExplorationStatsModel.fromJson(Map<String, dynamic> json) {
    return ExplorationStatsModel(
      explorationPercent:
          double.tryParse(json['exploration_percent']?.toString() ?? '') ?? 0.0,
      totalXp: json['total_xp'] as int? ?? 0,
      newAreasCleared:
          double.tryParse(json['new_areas_cleared']?.toString() ?? '') ?? 0.0,
      xpEarned: json['xp_earned'] as int? ?? 0,
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
    required super.districtId,
    required super.name,
    required super.explorationPercent,
    required super.masteryLevel,
  });

  factory DistrictExplorationModel.fromJson(Map<String, dynamic> json) {
    return DistrictExplorationModel(
      districtId: json['district_id'] as String,
      name: json['name'] as String,
      explorationPercent:
          double.tryParse(json['exploration_percent']?.toString() ?? '') ?? 0.0,
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
