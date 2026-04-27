import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/ranking_remote_datasource.dart';
import 'ranking_event.dart';
import 'ranking_state.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  final RankingRemoteDataSource remoteDataSource;

  RankingBloc({required this.remoteDataSource})
      : super(const RankingInitial()) {
    on<LoadGlobalRankingEvent>(_onLoadGlobal);
    on<LoadWeeklyRankingEvent>(_onLoadWeekly);
    on<LoadUserPositionEvent>(_onLoadUserPosition);
  }

  Future<void> _onLoadGlobal(
    LoadGlobalRankingEvent event,
    Emitter<RankingState> emit,
  ) async {
    emit(const RankingLoading());
    try {
      final entries = await remoteDataSource.getGlobalRanking();
      final position = await remoteDataSource.getUserPosition();
      emit(RankingLoaded(
        entries: entries,
        userPosition: position,
        type: RankingType.global,
      ));
    } catch (e) {
      emit(RankingError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadWeekly(
    LoadWeeklyRankingEvent event,
    Emitter<RankingState> emit,
  ) async {
    emit(const RankingLoading());
    try {
      final entries = await remoteDataSource.getWeeklyRanking();
      final position = await remoteDataSource.getUserPosition();
      emit(RankingLoaded(
        entries: entries,
        userPosition: position,
        type: RankingType.weekly,
      ));
    } catch (e) {
      emit(RankingError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadUserPosition(
    LoadUserPositionEvent event,
    Emitter<RankingState> emit,
  ) async {
    try {
      final position = await remoteDataSource.getUserPosition();
      final current = state;
      if (current is RankingLoaded) {
        emit(RankingLoaded(
          entries: current.entries,
          userPosition: position,
          type: current.type,
        ));
      }
    } catch (_) {}
  }
}
