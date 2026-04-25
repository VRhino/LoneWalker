import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lonewalker/features/map/data/models/map_models.dart';
import 'package:lonewalker/features/map/presentation/bloc/map_bloc.dart';
import 'package:lonewalker/features/map/presentation/bloc/map_event.dart';
import 'package:lonewalker/features/map/presentation/bloc/map_state.dart';

import '../../../../helpers/test_fakes.dart';

void main() {
  late FakeMapRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeMapRemoteDataSource();
  });

  group('MapBloc', () {
    group('UpdateLocationEvent', () {
      blocTest<MapBloc, MapState>(
        'emite [SpeedLimitExceeded] cuando velocidad supera el límite (20 km/h)',
        build: () => MapBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const UpdateLocationEvent(
          latitude: 40.4168,
          longitude: -3.7038,
          accuracy: 10.0,
          speed: 25.0,
        )),
        expect: () => [
          isA<SpeedLimitExceeded>().having(
            (s) => s.currentSpeed,
            'currentSpeed',
            25.0,
          ),
        ],
      );

      blocTest<MapBloc, MapState>(
        'SpeedLimitExceeded contiene el límite de velocidad correcto',
        build: () => MapBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const UpdateLocationEvent(
          latitude: 40.4168,
          longitude: -3.7038,
          accuracy: 10.0,
          speed: 30.0,
        )),
        expect: () => [
          isA<SpeedLimitExceeded>()
              .having((s) => s.speedLimit, 'speedLimit', 20.0),
        ],
      );

      blocTest<MapBloc, MapState>(
        'emite [GPSAccuracyWarning] cuando precisión GPS es insuficiente (>50m)',
        build: () => MapBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const UpdateLocationEvent(
          latitude: 40.4168,
          longitude: -3.7038,
          accuracy: 60.0,
          speed: 5.0,
        )),
        expect: () => [
          isA<GPSAccuracyWarning>().having((s) => s.accuracy, 'accuracy', 60.0),
        ],
      );

      blocTest<MapBloc, MapState>(
        'emite [ExplorationRegistered] cuando velocidad y GPS son válidos',
        build: () => MapBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const UpdateLocationEvent(
          latitude: 40.4168,
          longitude: -3.7038,
          accuracy: 10.0,
          speed: 5.0,
        )),
        expect: () => [
          isA<ExplorationRegistered>()
              .having((s) => s.xpEarned, 'xpEarned', 50),
        ],
      );

      blocTest<MapBloc, MapState>(
        'emite [MapError] cuando falla el registro en el servidor',
        setUp: () {
          fakeDataSource.errorToThrow = Exception('Server error');
        },
        build: () => MapBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const UpdateLocationEvent(
          latitude: 40.4168,
          longitude: -3.7038,
          accuracy: 10.0,
          speed: 5.0,
        )),
        expect: () => [isA<MapError>()],
      );
    });

    group('LoadFogEvent', () {
      blocTest<MapBloc, MapState>(
        'emite [MapLoaded] con datos del mapa y estadísticas',
        build: () => MapBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const LoadFogEvent(
          latitude: 40.4168,
          longitude: -3.7038,
          radius: 5000.0,
        )),
        expect: () => [
          isA<MapLoaded>().having(
            (s) => s.explorationStats.totalXp,
            'totalXp',
            100,
          ),
        ],
      );

      blocTest<MapBloc, MapState>(
        'MapLoaded contiene la ubicación del usuario',
        build: () => MapBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const LoadFogEvent(
          latitude: 40.4168,
          longitude: -3.7038,
          radius: 5000.0,
        )),
        expect: () => [
          isA<MapLoaded>().having(
            (s) => s.userLocation.latitude,
            'userLocation.latitude',
            40.4168,
          ),
        ],
      );

      blocTest<MapBloc, MapState>(
        'emite [MapError] cuando falla la carga del mapa',
        setUp: () {
          fakeDataSource.errorToThrow = Exception('Network error');
        },
        build: () => MapBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const LoadFogEvent(
          latitude: 40.4168,
          longitude: -3.7038,
          radius: 5000.0,
        )),
        expect: () => [isA<MapError>()],
      );
    });

    group('LoadProgressEvent', () {
      blocTest<MapBloc, MapState>(
        'actualiza explorationStats cuando el estado es MapLoaded',
        setUp: () {
          fakeDataSource.statsToReturn = const ExplorationStatsModel(
            explorationPercent: 15.0,
            totalXp: 300,
            newAreasCleared: 8.0,
            xpEarned: 150,
            districts: [],
          );
        },
        build: () => MapBloc(remoteDataSource: fakeDataSource),
        seed: () => const MapLoaded(
          userLocation: MapLocationModel(
            latitude: 40.4168,
            longitude: -3.7038,
            accuracy: 10.0,
          ),
          explorationStats: testStats,
          mapData: {},
          exploredAreas: [],
        ),
        act: (b) => b.add(const LoadProgressEvent()),
        expect: () => [
          isA<MapLoaded>().having(
            (s) => s.explorationStats.explorationPercent,
            'explorationPercent',
            15.0,
          ),
        ],
      );

      blocTest<MapBloc, MapState>(
        'no emite estados si el estado actual no es MapLoaded',
        build: () => MapBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const LoadProgressEvent()),
        expect: () => [],
      );
    });
  });
}
