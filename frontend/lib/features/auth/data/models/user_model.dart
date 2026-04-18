import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String username,
    required String email,
    String? avatarUrl,
    required String privacyMode,
    required double explorationPercent,
    required int totalXp,
    required int medalsCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
    id: id,
    username: username,
    email: email,
    avatarUrl: avatarUrl,
    privacyMode: privacyMode,
    explorationPercent: explorationPercent,
    totalXp: totalXp,
    medalsCount: medalsCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      privacyMode: json['privacy_mode'] as String? ?? 'PUBLIC',
      explorationPercent: (json['exploration_percent'] as num?)?.toDouble() ?? 0.0,
      totalXp: json['total_xp'] as int? ?? 0,
      medalsCount: json['medals_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'privacy_mode': privacyMode,
      'exploration_percent': explorationPercent,
      'total_xp': totalXp,
      'medals_count': medalsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
