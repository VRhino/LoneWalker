enum MedalRarity { common, uncommon, rare, epic, legendary }

enum MedalCategory { exploration, treasure, social, special }

class Medal {
  final String id;
  final String key;
  final String name;
  final String description;
  final String? iconUrl;
  final MedalRarity rarity;
  final MedalCategory category;
  final String unlockCondition;
  final int xpReward;
  final bool unlocked;
  final DateTime? unlockedAt;

  const Medal({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.rarity,
    required this.category,
    required this.unlockCondition,
    required this.xpReward,
    required this.unlocked,
    this.unlockedAt,
  });
}
