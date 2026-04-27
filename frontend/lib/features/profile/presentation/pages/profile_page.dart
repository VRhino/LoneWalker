import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/medal.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/medal_card_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfileEvent());
  }

  String _cartographerLevel(int points) {
    if (points >= 1000) return 'Guardián del Mapa';
    if (points >= 400) return 'Maestro Cartógrafo';
    if (points >= 150) return 'Cartógrafo Confirmado';
    if (points >= 50) return 'Aprendiz Cartógrafo';
    return 'Explorador Novato';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutEvent()),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authState.user;
          final cartPoints = user.cartographerPoints;

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<ProfileBloc>().add(const LoadProfileEvent()),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ProfileHeader(
                    username: user.username,
                    avatarUrl: user.avatarUrl,
                    explorationPercent: user.explorationPercent,
                    totalXp: user.totalXp,
                    medalsCount: user.medalsCount,
                    cartographerPoints: cartPoints,
                    cartographerLevel: _cartographerLevel(cartPoints),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('Medallas', style: theme.textTheme.titleLarge),
                  ),
                ),
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, profileState) {
                    if (profileState is ProfileLoading) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (profileState is ProfileError) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text(profileState.message)),
                      );
                    }
                    if (profileState is ProfileLoaded) {
                      final byCategory = <MedalCategory, List<Medal>>{};
                      for (final m in profileState.medals) {
                        byCategory.putIfAbsent(m.category, () => []).add(m);
                      }

                      final widgets = <Widget>[];
                      for (final entry in byCategory.entries) {
                        widgets.add(_CategorySection(
                          category: entry.key,
                          medals: entry.value,
                        ));
                      }

                      return SliverList(
                        delegate: SliverChildListDelegate(widgets),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final double explorationPercent;
  final int totalXp;
  final int medalsCount;
  final int cartographerPoints;
  final String cartographerLevel;

  const _ProfileHeader({
    required this.username,
    this.avatarUrl,
    required this.explorationPercent,
    required this.totalXp,
    required this.medalsCount,
    required this.cartographerPoints,
    required this.cartographerLevel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(username[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32, color: Colors.white))
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            username,
            style: theme.textTheme.headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            cartographerLevel,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                  label: 'Explorado',
                  value: '${explorationPercent.toStringAsFixed(1)}%'),
              _StatItem(label: 'XP Total', value: '$totalXp'),
              _StatItem(label: 'Medallas', value: '$medalsCount'),
              _StatItem(label: 'Pts. Cartógrafo', value: '$cartographerPoints'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final MedalCategory category;
  final List<Medal> medals;

  const _CategorySection({required this.category, required this.medals});

  String get _categoryLabel {
    switch (category) {
      case MedalCategory.exploration:
        return 'Exploración';
      case MedalCategory.treasure:
        return 'Tesoros';
      case MedalCategory.social:
        return 'Social';
      case MedalCategory.special:
        return 'Especial';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = medals.where((m) => m.unlocked).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_categoryLabel,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              Text('$unlocked/${medals.length}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: medals.length,
            itemBuilder: (_, i) => MedalCardWidget(medal: medals[i]),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
