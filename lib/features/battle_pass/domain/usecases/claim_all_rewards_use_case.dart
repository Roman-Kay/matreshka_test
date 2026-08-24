import '../models/battle_pass_models.dart';
import 'claim_reward_use_case.dart';

final class ClaimAllRewardsUseCase {
  const ClaimAllRewardsUseCase();

  ClaimRewardResult call(BattlePass pass) {
    var claimedCount = 0;

    final levels = pass.season.levels
        .map((level) {
          List<BattlePassReward> update(List<BattlePassReward> rewards) {
            return rewards
                .map((reward) {
                  final premiumLocked =
                      reward.track == BattlePassTrack.premium &&
                      pass.premiumStatus == PremiumStatus.locked;
                  if (reward.status != RewardStatus.available ||
                      premiumLocked) {
                    return reward;
                  }
                  claimedCount += 1;
                  return reward.copyWith(status: RewardStatus.received);
                })
                .toList(growable: false);
          }

          return level.copyWith(
            freeRewards: update(level.freeRewards),
            premiumRewards: update(level.premiumRewards),
          );
        })
        .toList(growable: false);

    return ClaimRewardResult(
      pass: pass.copyWith(season: pass.season.copyWith(levels: levels)),
      message: claimedCount > 0
          ? 'Получено наград: $claimedCount'
          : 'Нет доступных наград',
    );
  }
}
