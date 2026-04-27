import 'package:equatable/equatable.dart';

abstract class RankingEvent extends Equatable {
  const RankingEvent();

  @override
  List<Object?> get props => [];
}

class LoadGlobalRankingEvent extends RankingEvent {
  const LoadGlobalRankingEvent();
}

class LoadWeeklyRankingEvent extends RankingEvent {
  const LoadWeeklyRankingEvent();
}

class LoadUserPositionEvent extends RankingEvent {
  const LoadUserPositionEvent();
}
