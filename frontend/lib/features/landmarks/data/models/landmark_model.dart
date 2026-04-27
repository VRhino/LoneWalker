import '../../domain/entities/landmark.dart';

LandmarkStatus _parseStatus(String s) {
  switch (s.toUpperCase()) {
    case 'VOTING':
      return LandmarkStatus.voting;
    case 'APPROVED':
      return LandmarkStatus.approved;
    case 'REJECTED':
      return LandmarkStatus.rejected;
    default:
      return LandmarkStatus.draft;
  }
}

LandmarkCategory _parseCategory(String s) {
  switch (s.toUpperCase()) {
    case 'MONUMENT':
      return LandmarkCategory.monument;
    case 'MURAL':
      return LandmarkCategory.mural;
    case 'ARCHITECTURE':
      return LandmarkCategory.architecture;
    case 'NATURE':
      return LandmarkCategory.nature;
    case 'CULTURE':
      return LandmarkCategory.culture;
    case 'GASTRONOMY':
      return LandmarkCategory.gastronomy;
    case 'HISTORY':
      return LandmarkCategory.history;
    default:
      return LandmarkCategory.other;
  }
}

class LandmarkModel extends Landmark {
  const LandmarkModel({
    required super.id,
    required super.creatorId,
    required super.creatorUsername,
    required super.title,
    required super.description,
    required super.category,
    required super.latitude,
    required super.longitude,
    required super.status,
    required super.votesPositive,
    required super.votesNegative,
    required super.netVotes,
    super.photoUrl,
    required super.daysRemaining,
    required super.createdAt,
    super.approvedAt,
    super.comments = const [],
    super.userVote,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    final commentsList = (json['comments'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map((c) => LandmarkComment(
              id: c['id'] as String,
              userId: c['user_id'] as String,
              username: c['username'] as String,
              vote: c['vote'] as int,
              comment: c['comment'] as String,
              createdAt: DateTime.parse(c['created_at'] as String),
            ))
        .toList();

    return LandmarkModel(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      creatorUsername: json['creator_username'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: _parseCategory(json['category'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: _parseStatus(json['status'] as String),
      votesPositive: json['votes_positive'] as int,
      votesNegative: json['votes_negative'] as int,
      netVotes: json['net_votes'] as int,
      photoUrl: json['photo_url'] as String?,
      daysRemaining: json['days_remaining'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      comments: commentsList,
      userVote: json['user_vote'] as int?,
    );
  }
}
