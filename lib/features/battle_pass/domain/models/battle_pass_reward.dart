import 'battle_pass_enums.dart';

final class BattlePassReward {
  const BattlePassReward({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.track,
    required this.assetPath,
    this.rarity = RewardRarity.common,
    this.status = RewardStatus.locked,
  });

  final int id;
  final RewardType type;
  final String title;
  final int amount;
  final BattlePassTrack track;
  final String? assetPath;
  final RewardRarity rarity;
  final RewardStatus status;

  BattlePassReward copyWith({RewardStatus? status}) {
    return BattlePassReward(
      id: id,
      type: type,
      title: title,
      amount: amount,
      track: track,
      assetPath: assetPath,
      rarity: rarity,
      status: status ?? this.status,
    );
  }
}
