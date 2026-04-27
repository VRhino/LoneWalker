import 'package:flutter/material.dart';
import '../../domain/entities/medal.dart';

class MedalCardWidget extends StatelessWidget {
  final Medal medal;

  const MedalCardWidget({super.key, required this.medal});

  Color get _rarityColor {
    switch (medal.rarity) {
      case MedalRarity.common:
        return Colors.grey;
      case MedalRarity.uncommon:
        return Colors.green;
      case MedalRarity.rare:
        return Colors.blue;
      case MedalRarity.epic:
        return Colors.purple;
      case MedalRarity.legendary:
        return Colors.orange;
    }
  }

  IconData get _categoryIcon {
    switch (medal.category) {
      case MedalCategory.exploration:
        return Icons.map;
      case MedalCategory.treasure:
        return Icons.search;
      case MedalCategory.social:
        return Icons.people;
      case MedalCategory.special:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = medal.unlocked;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: _rarityColor, width: 3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: _rarityColor.withValues(alpha: 0.15),
                      child: Icon(
                        _categoryIcon,
                        color: _rarityColor,
                        size: 28,
                      ),
                    ),
                    if (isUnlocked)
                      const Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.green,
                          child:
                              Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  medal.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isUnlocked ? '+${medal.xpReward} XP' : medal.unlockCondition,
                  style: TextStyle(
                    fontSize: 10,
                    color: isUnlocked ? Colors.green : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
