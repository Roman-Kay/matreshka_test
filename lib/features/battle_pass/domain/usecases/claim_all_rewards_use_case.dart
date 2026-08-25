import '../models/battle_pass_models.dart';
import 'claim_reward_use_case.dart';

final class ClaimAllRewardsUseCase {
  const ClaimAllRewardsUseCase();

  ClaimRewardResult call(BattlePass pass) {
    var claimedCount = 0;
    var nextPass = pass;

    for (final level in pass.season.levels) {
      for (final reward in [...level.freeRewards, ...level.premiumRewards]) {
        final premiumLocked = reward.track == BattlePassTrack.premium && pass.premiumStatus == PremiumStatus.locked;
        if (pass.rewardStatus(reward.id) != RewardStatus.available || premiumLocked) {
          continue;
        }
        claimedCount += 1;
        nextPass = nextPass.withRewardStatus(reward.id, RewardStatus.received);
      }
    }

    return ClaimRewardResult(pass: nextPass, message: claimedCount > 0 ? 'Получено наград: $claimedCount' : 'Нет доступных наград');
  }
}
