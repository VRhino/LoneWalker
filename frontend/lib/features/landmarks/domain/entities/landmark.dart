enum LandmarkStatus { draft, voting, approved, rejected }

enum LandmarkCategory {
  monument,
  mural,
  architecture,
  nature,
  culture,
  gastronomy,
  history,
  other;

  String get label {
    switch (this) {
      case monument:
        return 'Monumento';
      case mural:
        return 'Mural';
      case architecture:
        return 'Arquitectura';
      case nature:
        return 'Naturaleza';
      case culture:
        return 'Cultura';
      case gastronomy:
        return 'Gastronomía';
      case history:
        return 'Historia';
      case other:
        return 'Otro';
    }
  }
}

class LandmarkComment {
  final String id;
  final String userId;
  final String username;
  final int vote;
  final String comment;
  final DateTime createdAt;

  const LandmarkComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.vote,
    required this.comment,
    required this.createdAt,
  });
}

class Landmark {
  final String id;
  final String creatorId;
  final String creatorUsername;
  final String title;
  final String description;
  final LandmarkCategory category;
  final double latitude;
  final double longitude;
  final LandmarkStatus status;
  final int votesPositive;
  final int votesNegative;
  final int netVotes;
  final String? photoUrl;
  final int daysRemaining;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final List<LandmarkComment> comments;
  final int? userVote;

  const Landmark({
    required this.id,
    required this.creatorId,
    required this.creatorUsername,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.votesPositive,
    required this.votesNegative,
    required this.netVotes,
    this.photoUrl,
    required this.daysRemaining,
    required this.createdAt,
    this.approvedAt,
    this.comments = const [],
    this.userVote,
  });
}
