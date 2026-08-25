import 'battle_pass_reward.dart';

final class BattlePassLevel {
  const BattlePassLevel({required this.number, required this.requiredXp, required this.freeRewards, required this.premiumRewards});

  final int number;
  final int requiredXp;
  final List<BattlePassReward> freeRewards;
  final List<BattlePassReward> premiumRewards;

  BattlePassLevel copyWith({int? number, int? requiredXp, List<BattlePassReward>? freeRewards, List<BattlePassReward>? premiumRewards}) {
    return BattlePassLevel(
      number: number ?? this.number,
      requiredXp: requiredXp ?? this.requiredXp,
      freeRewards: freeRewards ?? this.freeRewards,
      premiumRewards: premiumRewards ?? this.premiumRewards,
    );
  }
}
