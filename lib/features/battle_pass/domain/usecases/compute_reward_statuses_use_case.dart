import '../models/battle_pass_models.dart';
import '../../../pause/domain/models/player_reward_state.dart';

final class ComputeRewardStatusesUseCase {
  const ComputeRewardStatusesUseCase();

  BattlePass call(BattlePass pass) {
    final previousStates = {for (final state in pass.playerState.rewardStates) state.rewardId: state};
    final nextStates = <PlayerRewardState>[];

    for (final reward in pass.season.instantPremiumRewards) {
      final previous = previousStates[reward.id];
      nextStates.add(
        PlayerRewardState(
          rewardId: reward.id,
          status: previous?.status == RewardStatus.received || pass.premiumStatus == PremiumStatus.purchased ? RewardStatus.received : RewardStatus.locked,
          receivedAt: previous?.receivedAt,
        ),
      );
    }

    for (final level in pass.season.levels) {
      for (final reward in [...level.freeRewards, ...level.premiumRewards]) {
        final previous = previousStates[reward.id];
        if (previous?.status == RewardStatus.received) {
          nextStates.add(previous!);
          continue;
        }

        final levelReached = level.number <= pass.progress.currentLevel;
        final premiumAllowed = reward.track == BattlePassTrack.free || pass.premiumStatus == PremiumStatus.purchased;
        nextStates.add(PlayerRewardState(rewardId: reward.id, status: levelReached && premiumAllowed ? RewardStatus.available : RewardStatus.locked));
      }
    }

    return pass.copyWith(playerState: pass.playerState.copyWith(rewardStates: nextStates));
  }
}
