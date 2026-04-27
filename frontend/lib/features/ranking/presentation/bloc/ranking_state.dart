import 'package:equatable/equatable.dart';
import '../../domain/entities/ranking_entry.dart';

enum RankingType { global, weekly }

abstract class RankingState extends Equatable {
  const RankingState();

  @override
  List<Object?> get props => [];
}

class RankingInitial extends RankingState {
  const RankingInitial();
}

class RankingLoading extends RankingState {
  const RankingLoading();
}

class RankingLoaded extends RankingState {
  final List<RankingEntry> entries;
  final UserPosition? userPosition;
  final RankingType type;

  const RankingLoaded({
    required this.entries,
    this.userPosition,
    required this.type,
  });

  @override
  List<Object?> get props => [entries, userPosition, type];
}

class RankingError extends RankingState {
  final String message;

  const RankingError({required this.message});

  @override
  List<Object?> get props => [message];
}
