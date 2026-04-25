import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../config/app_config.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/treasure_model.dart';
import '../bloc/treasure_bloc.dart';
import '../bloc/treasure_event.dart';
import '../bloc/treasure_state.dart';
import '../utils/treasure_rarity_colors.dart';
import '../widgets/radar_widget.dart';

class TreasurePage extends StatefulWidget {
  const TreasurePage({super.key});

  @override
  State<TreasurePage> createState() => _TreasurePageState();
}

class _TreasurePageState extends State<TreasurePage> {
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    _initLocationStream();
  }

  void _initLocationStream() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      if (!mounted) return;
      setState(() => _lastPosition = position);
      context.read<TreasureBloc>().add(
            ActivateRadarEvent(
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasure Hunt 🏴‍☠️'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: BlocListener<TreasureBloc, TreasureState>(
        listener: (context, state) {
          if (state is TreasureClaimSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is TreasureError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<TreasureBloc, TreasureState>(
          builder: (context, state) {
            if (state is TreasureInitial || state is TreasureLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is RadarActive) {
              return _buildRadarView(context, state);
            }

            if (state is NearbyTreasuresLoaded) {
              return _buildTreasureListView(context, state);
            }

            if (state is TreasureDetailsLoaded) {
              return _buildDetailView(context, state);
            }

            if (state is TreasureClaimSuccess) {
              return _buildClaimSuccessView(context, state);
            }

            if (state is GPSValidationInProgress) {
              return _buildGPSValidationView(context, state);
            }

            if (state is TreasureError) {
              return _buildErrorView(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRadarView(BuildContext context, RadarActive state) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Treasure Radar',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${state.treasures.length} treasures nearby',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                RadarWidget(
                  treasures: state.treasures,
                  userLatitude: state.userLatitude,
                  userLongitude: state.userLongitude,
                  onTreasureTap: (treasure) {
                    context.read<TreasureBloc>().add(
                          LoadTreasureDetailsEvent(
                              treasureId: treasure.treasureId),
                        );
                  },
                ),
              ],
            ),
          ),
          if (state.treasures.isNotEmpty)
            _buildTreasuresList(context, state.treasures),
        ],
      ),
    );
  }

  Widget _buildTreasuresList(
      BuildContext context, List<RadarTreasureModel> treasures) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: treasures.length,
      itemBuilder: (context, index) {
        final treasure = treasures[index];
        final proximityColor =
            treasure.proximityPercent < AppDimensions.proximityThreshold
                ? Colors.blue
                : Colors.red;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            onTap: treasure.canClaim && _lastPosition != null
                ? () {
                    context.read<TreasureBloc>().add(ClaimTreasureEvent(
                          treasureId: treasure.treasureId,
                          latitude: _lastPosition!.latitude,
                          longitude: _lastPosition!.longitude,
                          accuracyMeters: _lastPosition!.accuracy,
                        ));
                  }
                : null,
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: proximityColor,
                shape: BoxShape.circle,
              ),
            ),
            title: Text(treasure.title),
            subtitle: Text(
              '${treasure.distanceMeters.toStringAsFixed(1)}m away • ${treasure.rarity.name}',
            ),
            trailing: treasure.canClaim
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Claim',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Text(
                    '${treasure.proximityPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTreasureListView(
    BuildContext context,
    NearbyTreasuresLoaded state,
  ) {
    return ListView.builder(
      itemCount: state.treasures.length,
      itemBuilder: (context, index) {
        final treasure = state.treasures[index];

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(treasure.title),
            subtitle: Text(treasure.description),
            onTap: () {
              context.read<TreasureBloc>().add(
                    LoadTreasureDetailsEvent(treasureId: treasure.id),
                  );
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailView(
    BuildContext context,
    TreasureDetailsLoaded state,
  ) {
    final treasure = state.treasure;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (treasure.photoUrl != null)
            Image.network(
              treasure.photoUrl!,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  treasure.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: TreasureRarityColors.baseColor(treasure.rarity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    treasure.rarity.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(treasure.description),
                const SizedBox(height: 24),
                if (state.wallOfFame.isNotEmpty) ...[
                  Text(
                    'Wall of Fame',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.wallOfFame.length
                        .clamp(0, AppDimensions.wallOfFameMaxItems),
                    itemBuilder: (context, index) {
                      final claim = state.wallOfFame[index];
                      return ListTile(
                        title: Text(claim.username),
                        trailing: Text('+${claim.xpEarned} XP'),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimSuccessView(
    BuildContext context,
    TreasureClaimSuccess state,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Treasure Claimed!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '+${state.xpEarned} XP',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<TreasureBloc>().add(ActivateRadarEvent(
                    latitude:
                        _lastPosition?.latitude ?? AppConfig.defaultLatitude,
                    longitude:
                        _lastPosition?.longitude ?? AppConfig.defaultLongitude,
                  ));
            },
            child: const Text('Back to Radar'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, TreasureError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(state.message),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<TreasureBloc>().add(ActivateRadarEvent(
                    latitude:
                        _lastPosition?.latitude ?? AppConfig.defaultLatitude,
                    longitude:
                        _lastPosition?.longitude ?? AppConfig.defaultLongitude,
                  ));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildGPSValidationView(
      BuildContext context, GPSValidationInProgress state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Validating GPS...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Hold still near the treasure'),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Hunt Treasures'),
        content: const Text(
          'The radar shows nearby treasures in a 360° view. '
          'Blue = Cold (far away), Red = Hot (nearby). '
          'Get within 10 meters and maintain GPS accuracy below 50m to claim.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
