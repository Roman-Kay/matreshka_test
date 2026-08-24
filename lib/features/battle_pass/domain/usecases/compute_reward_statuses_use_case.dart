import '../models/battle_pass_models.dart';

final class ComputeRewardStatusesUseCase {
  const ComputeRewardStatusesUseCase();

  BattlePass call(BattlePass pass) {
    final levels = pass.season.levels
        .map((level) {
          List<BattlePassReward> compute(List<BattlePassReward> rewards) {
            return rewards
                .map((reward) {
                  if (reward.status == RewardStatus.received) return reward;
                  final levelReached =
                      level.number <= pass.progress.currentLevel;
                  final premiumAllowed =
                      reward.track == BattlePassTrack.free ||
                      pass.premiumStatus == PremiumStatus.purchased;

                  return reward.copyWith(
                    status: levelReached && premiumAllowed
                        ? RewardStatus.available
                        : RewardStatus.locked,
                  );
                })
                .toList(growable: false);
          }

          return level.copyWith(
            freeRewards: compute(level.freeRewards),
            premiumRewards: compute(level.premiumRewards),
          );
        })
        .toList(growable: false);

    return pass.copyWith(season: pass.season.copyWith(levels: levels));
  }
}
