import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String privacyMode;
  final double explorationPercent;
  final int totalXp;
  final int medalsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.privacyMode,
    required this.explorationPercent,
    required this.totalXp,
    required this.medalsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    avatarUrl,
    privacyMode,
    explorationPercent,
    totalXp,
    medalsCount,
    createdAt,
    updatedAt,
  ];
}
