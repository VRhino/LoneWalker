import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/medals_remote_datasource.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final MedalsRemoteDataSource remoteDataSource;

  ProfileBloc({required this.remoteDataSource})
      : super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final medals = await remoteDataSource.getAllMedals();
      emit(ProfileLoaded(medals: medals));
    } catch (e) {
      emit(ProfileError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
