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

    final levels = pass.season.levels
        .map((level) {
          List<BattlePassReward> update(List<BattlePassReward> rewards) {
            return rewards
                .map((reward) {
                  if (reward.id != rewardId) return reward;
                  if (reward.status == RewardStatus.received) {
                    message = 'Награда уже получена';
                    return reward;
                  }
                  if (reward.track == BattlePassTrack.premium &&
                      pass.premiumStatus == PremiumStatus.locked) {
                    message = 'Нужна прокачка';
                    return reward;
                  }
                  if (reward.status != RewardStatus.available) {
                    message = 'Награда пока заблокирована';
                    return reward;
                  }
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
      message: message,
    );
  }
}
