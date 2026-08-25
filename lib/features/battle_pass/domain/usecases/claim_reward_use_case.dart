import '../models/battle_pass_models.dart';

final class ClaimRewardResult {
  const ClaimRewardResult({required this.pass, required this.message});

  final BattlePass pass;
  final String message;
}

final class ClaimRewardUseCase {
  const ClaimRewardUseCase();

  ClaimRewardResult call(BattlePass pass, int rewardId) {
    var message = 'Награда получена';
    BattlePassReward? targetReward;

    for (final level in pass.season.levels) {
      for (final reward in [...level.freeRewards, ...level.premiumRewards]) {
        if (reward.id == rewardId) targetReward = reward;
      }
    }

    if (targetReward == null) {
      return ClaimRewardResult(pass: pass, message: 'Награда не найдена');
    }

    final reward = targetReward;
    final status = pass.rewardStatus(rewardId);
    if (status == RewardStatus.received) {
      message = 'Награда уже получена';
      return ClaimRewardResult(pass: pass, message: message);
    }
    if (reward.track == BattlePassTrack.premium && pass.premiumStatus == PremiumStatus.locked) {
      message = 'Нужна прокачка';
      return ClaimRewardResult(pass: pass, message: message);
    }
    if (status != RewardStatus.available) {
      message = 'Награда пока заблокирована';
      return ClaimRewardResult(pass: pass, message: message);
    }

    return ClaimRewardResult(pass: pass.withRewardStatus(rewardId, RewardStatus.received), message: message);
  }
}
