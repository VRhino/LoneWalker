class RankingEntry {
  final int rank;
  final String userId;
  final String username;
  final String? avatarUrl;
  final double explorationPercent;
  final int treasuresFound;
  final int xpTotal;
  final int medalsCount;
  final double score;
  final bool isCurrentUser;
  final DateTime updatedAt;

  const RankingEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.explorationPercent,
    required this.treasuresFound,
    required this.xpTotal,
    required this.medalsCount,
    required this.score,
    required this.isCurrentUser,
    required this.updatedAt,
  });
}

class UserPosition {
  final int rank;
  final double score;
  final int totalPlayers;
  final double explorationPercent;
  final int treasuresFound;
  final int xpTotal;
  final int medalsCount;

  const UserPosition({
    required this.rank,
    required this.score,
    required this.totalPlayers,
    required this.explorationPercent,
    required this.treasuresFound,
    required this.xpTotal,
    required this.medalsCount,
  });
}
