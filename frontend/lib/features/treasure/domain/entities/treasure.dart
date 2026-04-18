import 'package:equatable/equatable.dart';

enum TreasureRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

enum TreasureStatus {
  active,
  depleted,
  archived,
}

class Treasure extends Equatable {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final TreasureStatus status;
  final TreasureRarity rarity;
  final int? maxUses;
  final int currentUses;
  final int? usesRemaining;
  final String? photoUrl;
  final String? stlFileUrl;
  final bool claimedByUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Treasure({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.rarity,
    this.maxUses,
    required this.currentUses,
    this.usesRemaining,
    this.photoUrl,
    this.stlFileUrl,
    required this.claimedByUser,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        latitude,
        longitude,
        status,
        rarity,
        claimedByUser,
      ];
}

class RadarTreasure extends Equatable {
  final String treasureId;
  final String title;
  final double latitude;
  final double longitude;
  final TreasureRarity rarity;
  final double distanceMeters;
  final double bearingDegrees;
  final double proximityPercent;
  final bool canClaim;

  const RadarTreasure({
    required this.treasureId,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.rarity,
    required this.distanceMeters,
    required this.bearingDegrees,
    required this.proximityPercent,
    required this.canClaim,
  });

  @override
  List<Object?> get props => [
        treasureId,
        bearingDegrees,
        proximityPercent,
        canClaim,
      ];
}

class TreasureWallOfFame extends Equatable {
  final String userId;
  final String username;
  final DateTime claimedAt;
  final int xpEarned;
  final double distanceMeters;
  final int gpsValidationTimeMs;

  const TreasureWallOfFame({
    required this.userId,
    required this.username,
    required this.claimedAt,
    required this.xpEarned,
    required this.distanceMeters,
    required this.gpsValidationTimeMs,
  });

  @override
  List<Object?> get props => [userId, claimedAt];
}

class TreasureClaimsStats extends Equatable {
  final int totalClaimed;
  final int totalXp;
  final Map<TreasureRarity, int> byRarity;

  const TreasureClaimsStats({
    required this.totalClaimed,
    required this.totalXp,
    required this.byRarity,
  });

  @override
  List<Object?> get props => [totalClaimed, totalXp, byRarity];
}
