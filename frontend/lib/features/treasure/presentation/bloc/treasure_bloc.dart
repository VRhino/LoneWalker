import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/app_config.dart';
import '../../data/datasources/treasure_remote_datasource.dart';
import '../../data/models/treasure_model.dart';
import 'treasure_event.dart';
import 'treasure_state.dart';

class TreasureBloc extends Bloc<TreasureEvent, TreasureState> {
  final TreasureRemoteDataSource remoteDataSource;

  TreasureBloc({required this.remoteDataSource}) : super(const TreasureInitial()) {
    on<ActivateRadarEvent>(_onActivateRadar);
    on<UpdateRadarPositionEvent>(_onUpdateRadarPosition);
    on<LoadNearbyTreasuresEvent>(_onLoadNearbyTreasures);
    on<LoadTreasureDetailsEvent>(_onLoadTreasureDetails);
    on<ClaimTreasureEvent>(_onClaimTreasure);
    on<LoadWallOfFameEvent>(_onLoadWallOfFame);
    on<LoadClaimsStatsEvent>(_onLoadClaimsStats);
  }

  Future<void> _onActivateRadar(
    ActivateRadarEvent event,
    Emitter<TreasureState> emit,
  ) async {
    emit(const TreasureLoading());

    try {
      final radarData = await remoteDataSource.getRadarData(
        event.latitude,
        event.longitude,
      );

      final activeTreasures = radarData
          .where((t) => t.distanceMeters <= AppConfig.radarDisplayRadiusMeters)
          .toList();

      if (activeTreasures.isEmpty) {
        emit(const RadarActive(
          treasures: [],
          userLatitude: 0,
          userLongitude: 0,
        ));
      } else {
        emit(RadarActive(
          treasures: activeTreasures,
          userLatitude: event.latitude,
          userLongitude: event.longitude,
        ));
      }
    } catch (e) {
      emit(TreasureError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRadarPosition(
    UpdateRadarPositionEvent event,
    Emitter<TreasureState> emit,
  ) async {
    if (state is! RadarActive) return;

    try {
      final radarData = await remoteDataSource.getRadarData(
        event.latitude,
        event.longitude,
      );

      final activeTreasures = radarData
          .where((t) => t.distanceMeters <= AppConfig.radarDisplayRadiusMeters)
          .toList();

      emit(RadarActive(
        treasures: activeTreasures,
        userLatitude: event.latitude,
        userLongitude: event.longitude,
      ));
    } catch (e) {
      emit(TreasureError(message: e.toString()));
    }
  }

  Future<void> _onLoadNearbyTreasures(
    LoadNearbyTreasuresEvent event,
    Emitter<TreasureState> emit,
  ) async {
    emit(const TreasureLoading());

    try {
      final treasures = await remoteDataSource.getNearby(
        event.latitude,
        event.longitude,
        radius: event.radius,
      );

      emit(NearbyTreasuresLoaded(treasures: treasures));
    } catch (e) {
      emit(TreasureError(message: e.toString()));
    }
  }

  Future<void> _onLoadTreasureDetails(
    LoadTreasureDetailsEvent event,
    Emitter<TreasureState> emit,
  ) async {
    emit(const TreasureLoading());

    try {
      final treasure = await remoteDataSource.getTreasureById(event.treasureId);
      final wallOfFame = await remoteDataSource.getWallOfFame(event.treasureId);

      emit(TreasureDetailsLoaded(
        treasure: treasure,
        wallOfFame: wallOfFame,
      ));
    } catch (e) {
      emit(TreasureError(message: e.toString()));
    }
  }

  Future<void> _onClaimTreasure(
    ClaimTreasureEvent event,
    Emitter<TreasureState> emit,
  ) async {
    try {
      if (event.accuracyMeters > AppConfig.gpsAccuracyThreshold) {
        emit(TreasureError(
          message: 'GPS accuracy insufficient: ${event.accuracyMeters.toStringAsFixed(1)}m',
        ));
        return;
      }

      emit(GPSValidationInProgress(
        treasureId: event.treasureId,
        distance: 0,
        validationTimeMs: 0,
      ));

      final result = await remoteDataSource.claimTreasure(
        event.treasureId,
        event.latitude,
        event.longitude,
        event.accuracyMeters,
      );

      final treasure = result['treasure'] as Map<String, dynamic>;
      final xpEarned = result['xp_earned'] as int;

      emit(TreasureClaimSuccess(
        treasure: _mapToTreasure(treasure),
        xpEarned: xpEarned,
        message: result['message'] as String? ?? 'Treasure claimed successfully!',
      ));
    } catch (e) {
      emit(TreasureError(message: e.toString()));
    }
  }

  Future<void> _onLoadWallOfFame(
    LoadWallOfFameEvent event,
    Emitter<TreasureState> emit,
  ) async {
    try {
      final wallOfFame = await remoteDataSource.getWallOfFame(event.treasureId);
      emit(TreasureDetailsLoaded(
        treasure: (state as TreasureDetailsLoaded?)?.treasure ??
            (throw Exception('Treasure not loaded')),
        wallOfFame: wallOfFame,
      ));
    } catch (e) {
      emit(TreasureError(message: e.toString()));
    }
  }

  Future<void> _onLoadClaimsStats(
    LoadClaimsStatsEvent event,
    Emitter<TreasureState> emit,
  ) async {
    try {
      final stats = await remoteDataSource.getClaimsStats();
      emit(ClaimsStatsLoaded(stats: stats));
    } catch (e) {
      emit(TreasureError(message: e.toString()));
    }
  }

  TreasureModel _mapToTreasure(Map<String, dynamic> json) {
    return TreasureModel.fromJson(json);
  }
}
