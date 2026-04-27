import 'package:flutter/material.dart';
import '../../domain/entities/ranking_entry.dart';

class RankingItemWidget extends StatelessWidget {
  final RankingEntry entry;

  const RankingItemWidget({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighlighted = entry.isCurrentUser;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.colorScheme.primaryContainer
            : theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: _RankBadge(rank: entry.rank),
        title: Text(
          entry.username,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.map_outlined, size: 12),
            const SizedBox(width: 2),
            Text('${entry.explorationPercent.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 8),
            const Icon(Icons.stars_outlined, size: 12),
            const SizedBox(width: 2),
            Text('${entry.xpTotal} XP', style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 8),
            const Icon(Icons.search, size: 12),
            const SizedBox(width: 2),
            Text('${entry.treasuresFound}',
                style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              entry.score.toStringAsFixed(1),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('score', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0);
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32);
    } else {
      badgeColor = Colors.grey.shade300;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: rank > 9 ? 11 : 13,
            color: rank <= 3 ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
