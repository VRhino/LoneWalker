import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lonewalker/features/treasure/data/models/treasure_model.dart';
import 'package:lonewalker/features/treasure/domain/entities/treasure.dart';
import 'package:lonewalker/features/treasure/presentation/bloc/treasure_bloc.dart';
import 'package:lonewalker/features/treasure/presentation/bloc/treasure_event.dart';
import 'package:lonewalker/features/treasure/presentation/bloc/treasure_state.dart';

import '../../../../helpers/test_fakes.dart';

void main() {
  late FakeTreasureRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeTreasureRemoteDataSource();
  });

  group('TreasureBloc', () {
    group('ActivateRadarEvent', () {
      blocTest<TreasureBloc, TreasureState>(
        'emite [TreasureLoading, RadarActive] con tesoros dentro del radio',
        setUp: () {
          fakeDataSource.radarData = [testRadarTreasure];
        },
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const ActivateRadarEvent(
          latitude: 40.4168,
          longitude: -3.7038,
        )),
        expect: () => [
          isA<TreasureLoading>(),
          isA<RadarActive>().having(
            (s) => s.treasures,
            'treasures',
            isNotEmpty,
          ),
        ],
      );

      blocTest<TreasureBloc, TreasureState>(
        'emite [TreasureLoading, RadarActive] vacío cuando no hay tesoros cercanos',
        setUp: () {
          fakeDataSource.radarData = [
            RadarTreasureModel(
              treasureId: 'far-1',
              title: 'Distant Treasure',
              latitude: 41.0,
              longitude: -4.0,
              rarity: TreasureRarity.common,
              distanceMeters: 2000.0, // > radarDisplayRadiusMeters (1000)
              bearingDegrees: 0.0,
              proximityPercent: 0.0,
              canClaim: false,
            ),
          ];
        },
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const ActivateRadarEvent(
          latitude: 40.4168,
          longitude: -3.7038,
        )),
        expect: () => [
          isA<TreasureLoading>(),
          isA<RadarActive>().having((s) => s.treasures, 'treasures', isEmpty),
        ],
      );

      blocTest<TreasureBloc, TreasureState>(
        'emite [TreasureLoading, TreasureError] cuando falla el servidor',
        setUp: () {
          fakeDataSource.errorToThrow = Exception('Server error');
        },
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const ActivateRadarEvent(
          latitude: 40.4168,
          longitude: -3.7038,
        )),
        expect: () => [isA<TreasureLoading>(), isA<TreasureError>()],
      );
    });

    group('LoadNearbyTreasuresEvent', () {
      blocTest<TreasureBloc, TreasureState>(
        'emite [TreasureLoading, NearbyTreasuresLoaded] con tesoros cercanos',
        setUp: () {
          fakeDataSource.nearbyTreasures = [testTreasure];
        },
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const LoadNearbyTreasuresEvent(
          latitude: 40.4168,
          longitude: -3.7038,
          radius: 1000,
        )),
        expect: () => [
          isA<TreasureLoading>(),
          isA<NearbyTreasuresLoaded>().having(
            (s) => s.treasures.length,
            'treasures.length',
            1,
          ),
        ],
      );

      blocTest<TreasureBloc, TreasureState>(
        'emite [TreasureLoading, NearbyTreasuresLoaded] lista vacía cuando no hay tesoros',
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const LoadNearbyTreasuresEvent(
          latitude: 40.4168,
          longitude: -3.7038,
        )),
        expect: () => [
          isA<TreasureLoading>(),
          isA<NearbyTreasuresLoaded>().having(
            (s) => s.treasures,
            'treasures',
            isEmpty,
          ),
        ],
      );
    });

    group('ClaimTreasureEvent', () {
      blocTest<TreasureBloc, TreasureState>(
        'emite [TreasureError] cuando precisión GPS es insuficiente',
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const ClaimTreasureEvent(
          treasureId: 'treasure-1',
          latitude: 40.4168,
          longitude: -3.7038,
          accuracyMeters: 75.0, // > AppConfig.gpsAccuracyThreshold (50m)
        )),
        expect: () => [
          isA<TreasureError>().having(
            (s) => s.message,
            'message',
            contains('GPS accuracy insufficient'),
          ),
        ],
      );

      blocTest<TreasureBloc, TreasureState>(
        'emite [GPSValidationInProgress, TreasureClaimSuccess] cuando claim es exitoso',
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const ClaimTreasureEvent(
          treasureId: 'treasure-1',
          latitude: 40.4168,
          longitude: -3.7038,
          accuracyMeters: 5.0, // < AppConfig.gpsAccuracyThreshold (50m)
        )),
        expect: () => [
          isA<GPSValidationInProgress>().having(
            (s) => s.treasureId,
            'treasureId',
            'treasure-1',
          ),
          isA<TreasureClaimSuccess>().having(
            (s) => s.xpEarned,
            'xpEarned',
            50,
          ),
        ],
      );

      blocTest<TreasureBloc, TreasureState>(
        'emite [TreasureError] cuando el servidor rechaza el claim',
        setUp: () {
          fakeDataSource.errorToThrow = Exception('Already claimed');
        },
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const ClaimTreasureEvent(
          treasureId: 'treasure-1',
          latitude: 40.4168,
          longitude: -3.7038,
          accuracyMeters: 5.0,
        )),
        expect: () => [isA<GPSValidationInProgress>(), isA<TreasureError>()],
      );
    });

    group('LoadClaimsStatsEvent', () {
      blocTest<TreasureBloc, TreasureState>(
        'emite [ClaimsStatsLoaded] con estadísticas correctas',
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const LoadClaimsStatsEvent()),
        expect: () => [
          isA<ClaimsStatsLoaded>().having(
            (s) => s.stats.totalClaimed,
            'totalClaimed',
            5,
          ),
        ],
      );

      blocTest<TreasureBloc, TreasureState>(
        'emite [TreasureError] cuando falla la carga de stats',
        setUp: () {
          fakeDataSource.errorToThrow = Exception('Network error');
        },
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const LoadClaimsStatsEvent()),
        expect: () => [isA<TreasureError>()],
      );
    });

    group('UpdateRadarPositionEvent', () {
      blocTest<TreasureBloc, TreasureState>(
        'no emite estados si el estado actual no es RadarActive',
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const UpdateRadarPositionEvent(
          latitude: 40.4168,
          longitude: -3.7038,
        )),
        expect: () => [],
      );

      blocTest<TreasureBloc, TreasureState>(
        'actualiza posición cuando el radar está activo',
        setUp: () {
          fakeDataSource.radarData = [testRadarTreasure];
        },
        build: () => TreasureBloc(remoteDataSource: fakeDataSource),
        seed: () => RadarActive(
          treasures: [testRadarTreasure],
          userLatitude: 40.4168,
          userLongitude: -3.7038,
        ),
        act: (b) => b.add(const UpdateRadarPositionEvent(
          latitude: 40.417,
          longitude: -3.704,
        )),
        expect: () => [
          isA<RadarActive>().having(
            (s) => s.userLatitude,
            'userLatitude',
            40.417,
          ),
        ],
      );
    });
  });
}
