import 'package:flutter/material.dart';
import '../../domain/entities/ranking_entry.dart';

class UserPositionWidget extends StatelessWidget {
  final UserPosition position;

  const UserPositionWidget({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border(
          top: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.person_pin, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Tu posición: #${position.rank} de ${position.totalPlayers}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const Spacer(),
          Text(
            '${position.score.toStringAsFixed(1)} pts',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
