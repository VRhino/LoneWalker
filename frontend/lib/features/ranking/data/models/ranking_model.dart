import '../../domain/entities/ranking_entry.dart';

class RankingEntryModel extends RankingEntry {
  const RankingEntryModel({
    required super.rank,
    required super.userId,
    required super.username,
    super.avatarUrl,
    required super.explorationPercent,
    required super.treasuresFound,
    required super.xpTotal,
    required super.medalsCount,
    required super.score,
    required super.isCurrentUser,
    required super.updatedAt,
  });

  factory RankingEntryModel.fromJson(Map<String, dynamic> json) {
    return RankingEntryModel(
      rank: json['rank'] as int,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      explorationPercent: (json['exploration_percent'] as num).toDouble(),
      treasuresFound: json['treasures_found'] as int,
      xpTotal: json['xp_total'] as int,
      medalsCount: json['medals_count'] as int,
      score: (json['score'] as num).toDouble(),
      isCurrentUser: json['is_current_user'] as bool,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class UserPositionModel extends UserPosition {
  const UserPositionModel({
    required super.rank,
    required super.score,
    required super.totalPlayers,
    required super.explorationPercent,
    required super.treasuresFound,
    required super.xpTotal,
    required super.medalsCount,
  });

  factory UserPositionModel.fromJson(Map<String, dynamic> json) {
    return UserPositionModel(
      rank: json['rank'] as int,
      score: (json['score'] as num).toDouble(),
      totalPlayers: json['total_players'] as int,
      explorationPercent: (json['exploration_percent'] as num).toDouble(),
      treasuresFound: json['treasures_found'] as int,
      xpTotal: json['xp_total'] as int,
      medalsCount: json['medals_count'] as int,
    );
  }
}
