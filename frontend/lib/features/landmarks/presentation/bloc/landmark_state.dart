import 'package:equatable/equatable.dart';
import '../../domain/entities/landmark.dart';

abstract class LandmarkState extends Equatable {
  const LandmarkState();

  @override
  List<Object?> get props => [];
}

class LandmarkInitial extends LandmarkState {
  const LandmarkInitial();
}

class LandmarkLoading extends LandmarkState {
  const LandmarkLoading();
}

class LandmarksLoaded extends LandmarkState {
  final List<Landmark> landmarks;

  const LandmarksLoaded({required this.landmarks});

  @override
  List<Object?> get props => [landmarks];
}

class LandmarkDetailLoaded extends LandmarkState {
  final Landmark landmark;

  const LandmarkDetailLoaded({required this.landmark});

  @override
  List<Object?> get props => [landmark];
}

class LandmarkProposed extends LandmarkState {
  final Landmark landmark;

  const LandmarkProposed({required this.landmark});

  @override
  List<Object?> get props => [landmark];
}

class LandmarkVoted extends LandmarkState {
  final Landmark landmark;

  const LandmarkVoted({required this.landmark});

  @override
  List<Object?> get props => [landmark];
}

class ApprovedLandmarksLoaded extends LandmarkState {
  final List<Landmark> approvedLandmarks;

  const ApprovedLandmarksLoaded({required this.approvedLandmarks});

  @override
  List<Object?> get props => [approvedLandmarks];
}

class LandmarkError extends LandmarkState {
  final String message;

  const LandmarkError({required this.message});

  @override
  List<Object?> get props => [message];
}
