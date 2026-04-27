import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/landmark_remote_datasource.dart';
import 'landmark_event.dart';
import 'landmark_state.dart';

class LandmarkBloc extends Bloc<LandmarkEvent, LandmarkState> {
  final LandmarkRemoteDataSource remoteDataSource;

  LandmarkBloc({required this.remoteDataSource})
      : super(const LandmarkInitial()) {
    on<LoadLandmarksForVotingEvent>(_onLoadVoting);
    on<LoadLandmarkDetailEvent>(_onLoadDetail);
    on<ProposeLandmarkEvent>(_onPropose);
    on<VoteLandmarkEvent>(_onVote);
    on<LoadApprovedLandmarksEvent>(_onLoadApproved);
  }

  Future<void> _onLoadVoting(
    LoadLandmarksForVotingEvent event,
    Emitter<LandmarkState> emit,
  ) async {
    emit(const LandmarkLoading());
    try {
      final landmarks = await remoteDataSource.getLandmarksForVoting();
      emit(LandmarksLoaded(landmarks: landmarks));
    } catch (e) {
      emit(
          LandmarkError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadDetail(
    LoadLandmarkDetailEvent event,
    Emitter<LandmarkState> emit,
  ) async {
    emit(const LandmarkLoading());
    try {
      final landmark = await remoteDataSource.getLandmarkById(event.landmarkId);
      emit(LandmarkDetailLoaded(landmark: landmark));
    } catch (e) {
      emit(
          LandmarkError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onPropose(
    ProposeLandmarkEvent event,
    Emitter<LandmarkState> emit,
  ) async {
    emit(const LandmarkLoading());
    try {
      final landmark = await remoteDataSource.proposeLandmark(
        title: event.title,
        description: event.description,
        category: event.category,
        latitude: event.latitude,
        longitude: event.longitude,
        userLatitude: event.userLatitude,
        userLongitude: event.userLongitude,
        photoUrl: event.photoUrl,
      );
      emit(LandmarkProposed(landmark: landmark));
    } catch (e) {
      emit(
          LandmarkError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onVote(
    VoteLandmarkEvent event,
    Emitter<LandmarkState> emit,
  ) async {
    emit(const LandmarkLoading());
    try {
      final landmark = await remoteDataSource.voteLandmark(
        id: event.landmarkId,
        vote: event.vote,
        comment: event.comment,
      );
      emit(LandmarkVoted(landmark: landmark));
    } catch (e) {
      emit(
          LandmarkError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadApproved(
    LoadApprovedLandmarksEvent event,
    Emitter<LandmarkState> emit,
  ) async {
    try {
      final landmarks = await remoteDataSource.getApprovedLandmarks(
        lat: event.latitude,
        lng: event.longitude,
        radius: event.radius,
      );
      emit(ApprovedLandmarksLoaded(approvedLandmarks: landmarks));
    } catch (_) {
      // Non-critical: silently fail so map still loads
    }
  }
}
