import 'package:flutter/material.dart';
import '../../domain/entities/treasure.dart';
import '../../../../core/theme/app_dimensions.dart';

class TreasureRarityColors {
  static Color baseColor(TreasureRarity rarity) {
    switch (rarity) {
      case TreasureRarity.common:
        return Colors.grey;
      case TreasureRarity.uncommon:
        return Colors.green;
      case TreasureRarity.rare:
        return Colors.blue;
      case TreasureRarity.epic:
        return Colors.purple;
      case TreasureRarity.legendary:
        return Colors.orange;
    }
  }

  // Returns a cold-to-hot interpolated color based on proximity (0–100%)
  static Color proximityColor(double proximityPercent) {
    if (proximityPercent < AppDimensions.proximityThreshold) {
      return Color.lerp(
        Colors.blue,
        Colors.cyan,
        proximityPercent / AppDimensions.proximityThreshold,
      )!;
    }
    return Color.lerp(
      Colors.yellow,
      Colors.red,
      (proximityPercent - AppDimensions.proximityThreshold) /
          AppDimensions.proximityThreshold,
    )!;
  }
}
