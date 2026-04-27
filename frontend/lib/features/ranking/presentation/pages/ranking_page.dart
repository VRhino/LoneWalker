import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ranking_bloc.dart';
import '../bloc/ranking_event.dart';
import '../bloc/ranking_state.dart';
import '../widgets/ranking_item_widget.dart';
import '../widgets/user_position_widget.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          context.read<RankingBloc>().add(const LoadGlobalRankingEvent());
        } else {
          context.read<RankingBloc>().add(const LoadWeeklyRankingEvent());
        }
      }
    });
    context.read<RankingBloc>().add(const LoadGlobalRankingEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Semanal'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_tabController.index == 0) {
                context.read<RankingBloc>().add(const LoadGlobalRankingEvent());
              } else {
                context.read<RankingBloc>().add(const LoadWeeklyRankingEvent());
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<RankingBloc, RankingState>(
        builder: (context, state) {
          if (state is RankingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RankingError) {
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
                        .read<RankingBloc>()
                        .add(const LoadGlobalRankingEvent()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is RankingLoaded) {
            if (state.entries.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.leaderboard_outlined, size: 64),
                    SizedBox(height: 16),
                    Text(
                        'No hay datos de ranking aún.\nExplora para aparecer aquí.',
                        textAlign: TextAlign.center),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (_tabController.index == 0) {
                        context
                            .read<RankingBloc>()
                            .add(const LoadGlobalRankingEvent());
                      } else {
                        context
                            .read<RankingBloc>()
                            .add(const LoadWeeklyRankingEvent());
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.entries.length,
                      itemBuilder: (context, index) =>
                          RankingItemWidget(entry: state.entries[index]),
                    ),
                  ),
                ),
                if (state.userPosition != null)
                  UserPositionWidget(position: state.userPosition!),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
