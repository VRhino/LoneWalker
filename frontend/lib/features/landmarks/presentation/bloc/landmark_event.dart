import 'package:equatable/equatable.dart';
import '../../domain/entities/landmark.dart';

abstract class LandmarkEvent extends Equatable {
  const LandmarkEvent();

  @override
  List<Object?> get props => [];
}

class LoadLandmarksForVotingEvent extends LandmarkEvent {
  const LoadLandmarksForVotingEvent();
}

class LoadLandmarkDetailEvent extends LandmarkEvent {
  final String landmarkId;

  const LoadLandmarkDetailEvent({required this.landmarkId});

  @override
  List<Object?> get props => [landmarkId];
}

class ProposeLandmarkEvent extends LandmarkEvent {
  final String title;
  final String description;
  final LandmarkCategory category;
  final double latitude;
  final double longitude;
  final double userLatitude;
  final double userLongitude;
  final String? photoUrl;

  const ProposeLandmarkEvent({
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.userLatitude,
    required this.userLongitude,
    this.photoUrl,
  });

  @override
  List<Object?> get props =>
      [title, description, category, latitude, longitude];
}

class VoteLandmarkEvent extends LandmarkEvent {
  final String landmarkId;
  final int vote;
  final String comment;

  const VoteLandmarkEvent({
    required this.landmarkId,
    required this.vote,
    required this.comment,
  });

  @override
  List<Object?> get props => [landmarkId, vote, comment];
}

class LoadApprovedLandmarksEvent extends LandmarkEvent {
  final double latitude;
  final double longitude;
  final double radius;

  const LoadApprovedLandmarksEvent({
    required this.latitude,
    required this.longitude,
    this.radius = 5000,
  });

  @override
  List<Object?> get props => [latitude, longitude, radius];
}
