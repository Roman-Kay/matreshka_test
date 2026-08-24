import 'package:flutter/material.dart';

import '../../../domain/models/battle_pass_models.dart';

extension RewardRarityStyle on RewardRarity {
  List<Color> get gradientColors {
    return switch (this) {
      RewardRarity.common => const [
        Color(0xFF29292C),
        Color(0xFF2E2E31),
        Color(0xFF5A5C60),
      ],
      RewardRarity.rare => const [
        Color(0xFF222431),
        Color(0xFF1F3351),
        Color(0xFF34779B),
      ],
      RewardRarity.epic => const [
        Color(0xFF2C232A),
        Color(0xFF4A2442),
        Color(0xFF8A1B8D),
      ],
      RewardRarity.legendary => const [
        Color(0xFF2C2323),
        Color(0xFF432723),
        Color(0xFFF05A00),
      ],
    };
  }

  Color get accentColor {
    return switch (this) {
      RewardRarity.common => const Color(0xFF737478),
      RewardRarity.rare => const Color(0xFF4CA6D3),
      RewardRarity.epic => const Color(0xFFB638B9),
      RewardRarity.legendary => const Color(0xFFFF8D2B),
    };
  }
}
