import 'package:flutter/material.dart';
import '../../domain/entities/landmark.dart';

class LandmarkCardWidget extends StatelessWidget {
  final Landmark landmark;
  final VoidCallback onTap;

  const LandmarkCardWidget({
    super.key,
    required this.landmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(
                      landmark.category.label,
                      style: const TextStyle(fontSize: 11),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Spacer(),
                  Text(
                    '${landmark.daysRemaining}d restantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: landmark.daysRemaining <= 3
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                landmark.title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                landmark.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.thumb_up_outlined,
                      size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('${landmark.votesPositive}',
                      style: const TextStyle(color: Colors.green)),
                  const SizedBox(width: 12),
                  const Icon(Icons.thumb_down_outlined,
                      size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('${landmark.votesNegative}',
                      style: const TextStyle(color: Colors.red)),
                  const Spacer(),
                  Text(
                    'por ${landmark.creatorUsername}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
