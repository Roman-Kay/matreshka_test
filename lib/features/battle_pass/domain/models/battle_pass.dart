import '../../../tasks/domain/models/task.dart';
import '../../../pause/domain/models/player_battle_pass_state.dart';
import '../../../pause/domain/models/player_battle_pass_progress.dart';
import '../../../pause/domain/models/player_reward_state.dart';
import 'battle_pass_enums.dart';
import 'battle_pass_season.dart';

final class BattlePass {
  const BattlePass({required this.season, required this.playerState, required this.tasks});

  final BattlePassSeason season;
  final PlayerBattlePassState playerState;
  final List<Task> tasks;

  PlayerBattlePassProgress get progress => playerState.progress;
  PremiumStatus get premiumStatus => playerState.premiumStatus;

  RewardStatus rewardStatus(int rewardId) {
    for (final state in playerState.rewardStates) {
      if (state.rewardId == rewardId) return state.status;
    }
    return RewardStatus.locked;
  }

  BattlePass withRewardStatus(int rewardId, RewardStatus status, {DateTime? receivedAt}) {
    final states = [...playerState.rewardStates];
    final index = states.indexWhere((state) => state.rewardId == rewardId);
    final nextState = PlayerRewardState(rewardId: rewardId, status: status, receivedAt: receivedAt);

    if (index == -1) {
      states.add(nextState);
    } else {
      states[index] = states[index].copyWith(status: status, receivedAt: receivedAt, clearReceivedAt: status != RewardStatus.received);
    }

    return copyWith(playerState: playerState.copyWith(rewardStates: states));
  }

  BattlePass copyWith({BattlePassSeason? season, PlayerBattlePassState? playerState, List<Task>? tasks}) {
    return BattlePass(season: season ?? this.season, playerState: playerState ?? this.playerState, tasks: tasks ?? this.tasks);
  }
}
