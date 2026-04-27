import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/landmark_bloc.dart';
import '../bloc/landmark_event.dart';
import '../bloc/landmark_state.dart';
import '../widgets/landmark_card_widget.dart';
import 'landmark_detail_page.dart';
import 'propose_landmark_page.dart';

class LandmarksPage extends StatefulWidget {
  const LandmarksPage({super.key});

  @override
  State<LandmarksPage> createState() => _LandmarksPageState();
}

class _LandmarksPageState extends State<LandmarksPage> {
  @override
  void initState() {
    super.initState();
    context.read<LandmarkBloc>().add(const LoadLandmarksForVotingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmarks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<LandmarkBloc>()
                .add(const LoadLandmarksForVotingEvent()),
          ),
        ],
      ),
      body: BlocBuilder<LandmarkBloc, LandmarkState>(
        builder: (context, state) {
          if (state is LandmarkLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LandmarkError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<LandmarkBloc>()
                        .add(const LoadLandmarksForVotingEvent()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is LandmarksLoaded) {
            if (state.landmarks.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.place_outlined, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'No hay landmarks en votación.\n¡Propone el primero!',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => context
                  .read<LandmarkBloc>()
                  .add(const LoadLandmarksForVotingEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.landmarks.length,
                itemBuilder: (context, index) {
                  final landmark = state.landmarks[index];
                  return LandmarkCardWidget(
                    landmark: landmark,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<LandmarkBloc>(),
                          child: LandmarkDetailPage(landmarkId: landmark.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<LandmarkBloc>(),
                child: const ProposeLandmarkPage(),
              ),
            ),
          );
          if (result == true && context.mounted) {
            context
                .read<LandmarkBloc>()
                .add(const LoadLandmarksForVotingEvent());
          }
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Proponer'),
      ),
    );
  }
}
