import '../../domain/entities/treasure.dart';

extension TreasureRarityX on TreasureRarity {
  String get stringValue {
    switch (this) {
      case TreasureRarity.common:
        return 'COMMON';
      case TreasureRarity.uncommon:
        return 'UNCOMMON';
      case TreasureRarity.rare:
        return 'RARE';
      case TreasureRarity.epic:
        return 'EPIC';
      case TreasureRarity.legendary:
        return 'LEGENDARY';
    }
  }

  static TreasureRarity fromString(String value) {
    switch (value.toUpperCase()) {
      case 'COMMON':
        return TreasureRarity.common;
      case 'UNCOMMON':
        return TreasureRarity.uncommon;
      case 'RARE':
        return TreasureRarity.rare;
      case 'EPIC':
        return TreasureRarity.epic;
      case 'LEGENDARY':
        return TreasureRarity.legendary;
      default:
        return TreasureRarity.common;
    }
  }
}

extension TreasureStatusX on TreasureStatus {
  String get stringValue {
    switch (this) {
      case TreasureStatus.active:
        return 'ACTIVE';
      case TreasureStatus.depleted:
        return 'DEPLETED';
      case TreasureStatus.archived:
        return 'ARCHIVED';
    }
  }

  static TreasureStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return TreasureStatus.active;
      case 'DEPLETED':
        return TreasureStatus.depleted;
      case 'ARCHIVED':
        return TreasureStatus.archived;
      default:
        return TreasureStatus.active;
    }
  }
}

class TreasureModel extends Treasure {
  const TreasureModel({
    required super.id,
    required super.title,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.status,
    required super.rarity,
    super.maxUses,
    required super.currentUses,
    super.usesRemaining,
    super.photoUrl,
    super.stlFileUrl,
    required super.claimedByUser,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TreasureModel.fromJson(Map<String, dynamic> json) {
    return TreasureModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: TreasureStatusX.fromString(json['status'] as String),
      rarity: TreasureRarityX.fromString(json['rarity'] as String),
      maxUses: json['max_uses'] as int?,
      currentUses: json['current_uses'] as int? ?? 0,
      usesRemaining: json['uses_remaining'] as int?,
      photoUrl: json['photo_url'] as String?,
      stlFileUrl: json['stl_file_url'] as String?,
      claimedByUser: json['claimed_by_user'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'status': status.stringValue,
        'rarity': rarity.stringValue,
        'max_uses': maxUses,
        'current_uses': currentUses,
        'uses_remaining': usesRemaining,
        'photo_url': photoUrl,
        'stl_file_url': stlFileUrl,
        'claimed_by_user': claimedByUser,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class RadarTreasureModel extends RadarTreasure {
  const RadarTreasureModel({
    required super.treasureId,
    required super.title,
    required super.latitude,
    required super.longitude,
    required super.rarity,
    required super.distanceMeters,
    required super.bearingDegrees,
    required super.proximityPercent,
    required super.canClaim,
  });

  factory RadarTreasureModel.fromJson(Map<String, dynamic> json) {
    return RadarTreasureModel(
      treasureId: json['treasure_id'] as String,
      title: json['title'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rarity: TreasureRarityX.fromString(json['rarity'] as String),
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      bearingDegrees: (json['bearing_degrees'] as num).toDouble(),
      proximityPercent: (json['proximity_percent'] as num).toDouble(),
      canClaim: json['can_claim'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'treasure_id': treasureId,
        'title': title,
        'latitude': latitude,
        'longitude': longitude,
        'rarity': rarity.stringValue,
        'distance_meters': distanceMeters,
        'bearing_degrees': bearingDegrees,
        'proximity_percent': proximityPercent,
        'can_claim': canClaim,
      };
}

class TreasureWallOfFameModel extends TreasureWallOfFame {
  const TreasureWallOfFameModel({
    required super.userId,
    required super.username,
    required super.claimedAt,
    required super.xpEarned,
    required super.distanceMeters,
    required super.gpsValidationTimeMs,
  });

  factory TreasureWallOfFameModel.fromJson(Map<String, dynamic> json) {
    return TreasureWallOfFameModel(
      userId: json['id'] as String,
      username: json['username'] as String,
      claimedAt: DateTime.parse(json['claimed_at'] as String),
      xpEarned: json['xp_earned'] as int,
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      gpsValidationTimeMs: json['gps_validation_time_ms'] as int,
    );
  }
}

class TreasureClaimsStatsModel extends TreasureClaimsStats {
  const TreasureClaimsStatsModel({
    required super.totalClaimed,
    required super.totalXp,
    required super.byRarity,
  });

  factory TreasureClaimsStatsModel.fromJson(Map<String, dynamic> json) {
    final byRarityData = json['by_rarity'] as Map<String, dynamic>? ?? {};
    final byRarity = <TreasureRarity, int>{};

    byRarityData.forEach((key, value) {
      byRarity[TreasureRarityX.fromString(key)] = value as int;
    });

    return TreasureClaimsStatsModel(
      totalClaimed: json['total_claimed'] as int,
      totalXp: json['total_xp'] as int,
      byRarity: byRarity,
    );
  }
}
