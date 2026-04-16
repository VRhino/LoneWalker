import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../widgets/fog_of_war_widget.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  double currentZoom = 15;

  @override
  void initState() {
    super.initState();
    // Initialize map
    context.read<MapBloc>().add(const InitMapEvent());
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoneWalker Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MapBloc>().add(const RefreshMapEvent());
            },
          ),
        ],
      ),
      body: BlocListener<MapBloc, MapState>(
        listener: (context, state) {
          if (state is SpeedLimitExceeded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Slow down! Speed: ${state.currentSpeed.toStringAsFixed(1)} km/h (Max: ${state.speedLimit})',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is GPSAccuracyWarning) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'GPS accuracy low: ${state.accuracy.toStringAsFixed(1)}m',
                ),
                backgroundColor: Colors.yellow,
              ),
            );
          } else if (state is MapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Stack(
          children: [
            // Google Maps
            BlocBuilder<MapBloc, MapState>(
              builder: (context, state) {
                if (state is MapInitial || state is MapLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is MapLoaded ||
                    state is ExplorationRegistered ||
                    state is LocationUpdated) {
                  final mapLoaded = state as MapLoaded? ??
                      (state as ExplorationRegistered?)?.stats as dynamic ??
                      (state as LocationUpdated?)?.stats as dynamic;

                  final userLat = (state is MapLoaded)
                      ? (state as MapLoaded).userLocation.latitude
                      : (state is LocationUpdated)
                          ? (state as LocationUpdated).location.latitude
                          : 40.4168;

                  final userLng = (state is MapLoaded)
                      ? (state as MapLoaded).userLocation.longitude
                      : (state is LocationUpdated)
                          ? (state as LocationUpdated).location.longitude
                          : -3.7038;

                  return GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(userLat, userLng),
                      zoom: currentZoom,
                    ),
                    onCameraMove: (CameraPosition position) {
                      currentZoom = position.zoom;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                  );
                }

                if (state is MapError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<MapBloc>().add(const InitMapEvent());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            // Exploration Stats Card
            Positioned(
              top: 16,
              right: 16,
              child: BlocBuilder<MapBloc, MapState>(
                builder: (context, state) {
                  double explorationPercent = 0;
                  int totalXp = 0;

                  if (state is MapLoaded) {
                    explorationPercent =
                        (state as MapLoaded).explorationStats.explorationPercent;
                    totalXp = (state as MapLoaded).explorationStats.totalXp;
                  } else if (state is ExplorationRegistered) {
                    explorationPercent =
                        (state as ExplorationRegistered).stats.explorationPercent;
                    totalXp = (state as ExplorationRegistered).stats.totalXp;
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.explore,
                                color: Color(0xFF667BC6),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${explorationPercent.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: explorationPercent / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF667BC6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${totalXp} XP',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Speed Warning Badge
            Positioned(
              bottom: 32,
              left: 16,
              child: BlocBuilder<MapBloc, MapState>(
                builder: (context, state) {
                  if (state is SpeedLimitExceeded) {
                    return Card(
                      color: Colors.orange,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.speed, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              '⚠️ Slow Down (${state.currentSpeed.toStringAsFixed(1)} km/h)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
