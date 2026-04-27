import '../../domain/entities/medal.dart';

MedalRarity _parseRarity(String s) {
  switch (s.toUpperCase()) {
    case 'UNCOMMON':
      return MedalRarity.uncommon;
    case 'RARE':
      return MedalRarity.rare;
    case 'EPIC':
      return MedalRarity.epic;
    case 'LEGENDARY':
      return MedalRarity.legendary;
    default:
      return MedalRarity.common;
  }
}

MedalCategory _parseCategory(String s) {
  switch (s.toUpperCase()) {
    case 'TREASURE':
      return MedalCategory.treasure;
    case 'SOCIAL':
      return MedalCategory.social;
    case 'SPECIAL':
      return MedalCategory.special;
    default:
      return MedalCategory.exploration;
  }
}

class MedalModel extends Medal {
  const MedalModel({
    required super.id,
    required super.key,
    required super.name,
    required super.description,
    super.iconUrl,
    required super.rarity,
    required super.category,
    required super.unlockCondition,
    required super.xpReward,
    required super.unlocked,
    super.unlockedAt,
  });

  factory MedalModel.fromJson(Map<String, dynamic> json) {
    return MedalModel(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String?,
      rarity: _parseRarity(json['rarity'] as String),
      category: _parseCategory(json['category'] as String),
      unlockCondition: json['unlock_condition'] as String,
      xpReward: json['xp_reward'] as int,
      unlocked: json['unlocked'] as bool,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
    );
  }
}
