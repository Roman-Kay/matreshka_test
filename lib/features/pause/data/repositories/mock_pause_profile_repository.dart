import '../../../battle_pass/domain/models/battle_pass_enums.dart';
import '../../domain/models/player_battle_pass_state.dart';
import '../../domain/models/player_battle_pass_progress.dart';
import '../../domain/models/player_reward_state.dart';
import '../../domain/repositories/pause_profile_repository.dart';

final class MockPauseProfileRepository implements PauseProfileRepository {
  const MockPauseProfileRepository();

  static const _maxBattlePassLevel = 200;
  static const _choiceRewardLevel = 4;
  static const _instantPremiumRewardIds = [9001, 9002, 9003];

  @override
  Future<PlayerBattlePassState> loadBattlePassState({required BattlePassDemoMode mode}) async {
    final premium = mode == BattlePassDemoMode.premiumLocked ? PremiumStatus.locked : PremiumStatus.purchased;
    final progress = _progressForMode(mode);

    return PlayerBattlePassState(
      userId: 'demo-player-42',
      progress: progress,
      premiumStatus: premium,
      rewardStates: _rewardStatesFor(currentLevel: progress.currentLevel, premium: premium),
    );
  }

  PlayerBattlePassProgress _progressForMode(BattlePassDemoMode mode) {
    return switch (mode) {
      BattlePassDemoMode.premiumLocked => const PlayerBattlePassProgress(currentLevel: 10, currentXp: 900, nextLevelXp: 1600),
      BattlePassDemoMode.premiumUnlocked => const PlayerBattlePassProgress(currentLevel: 108, currentXp: 900, nextLevelXp: 1600),
      BattlePassDemoMode.premiumWithXpBonus => const PlayerBattlePassProgress(currentLevel: 108, currentXp: 900, nextLevelXp: 1600),
      BattlePassDemoMode.maxLevel => const PlayerBattlePassProgress(currentLevel: 200, currentXp: 1600, nextLevelXp: 1600),
      BattlePassDemoMode.completed => const PlayerBattlePassProgress(currentLevel: 108, currentXp: 900, nextLevelXp: 1600),
    };
  }

  List<PlayerRewardState> _rewardStatesFor({required int currentLevel, required PremiumStatus premium}) {
    final states = <PlayerRewardState>[];
    for (var level = 1; level <= _maxBattlePassLevel; level += 1) {
      states.add(PlayerRewardState(rewardId: level * 10, status: _rewardStatusFor(level, BattlePassTrack.free, currentLevel, premium)));

      final premiumRewardsCount = level == _choiceRewardLevel ? 2 : 1;
      for (var index = 1; index <= premiumRewardsCount; index += 1) {
        states.add(PlayerRewardState(rewardId: level * 10 + index, status: _rewardStatusFor(level, BattlePassTrack.premium, currentLevel, premium)));
      }
    }

    for (final rewardId in _instantPremiumRewardIds) {
      states.add(PlayerRewardState(rewardId: rewardId, status: premium == PremiumStatus.purchased ? RewardStatus.received : RewardStatus.locked));
    }
    return states;
  }

  RewardStatus _rewardStatusFor(int level, BattlePassTrack track, int currentLevel, PremiumStatus premium) {
    if (level > currentLevel) return RewardStatus.locked;
    if (track == BattlePassTrack.premium && premium == PremiumStatus.locked) {
      return RewardStatus.locked;
    }
    if (level == currentLevel || level == currentLevel - 1) {
      return RewardStatus.available;
    }
    return RewardStatus.received;
  }
}
