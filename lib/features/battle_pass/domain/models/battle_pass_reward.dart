import 'battle_pass_enums.dart';

final class BattlePassReward {
  const BattlePassReward({required this.id, required this.type, required this.title, required this.amount, required this.track, required this.assetPath, this.rarity = RewardRarity.common});

  final int id;
  final RewardType type;
  final String title;
  final int amount;
  final BattlePassTrack track;
  final String? assetPath;
  final RewardRarity rarity;
}
