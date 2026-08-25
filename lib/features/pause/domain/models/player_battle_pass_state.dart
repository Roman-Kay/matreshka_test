import '../../../battle_pass/domain/models/battle_pass_enums.dart';
import 'player_battle_pass_progress.dart';
import 'player_reward_state.dart';

final class PlayerBattlePassState {
  const PlayerBattlePassState({required this.userId, required this.progress, required this.premiumStatus, required this.rewardStates});

  final String userId;
  final PlayerBattlePassProgress progress;
  final PremiumStatus premiumStatus;
  final List<PlayerRewardState> rewardStates;

  PlayerBattlePassState copyWith({String? userId, PlayerBattlePassProgress? progress, PremiumStatus? premiumStatus, List<PlayerRewardState>? rewardStates}) {
    return PlayerBattlePassState(
      userId: userId ?? this.userId,
      progress: progress ?? this.progress,
      premiumStatus: premiumStatus ?? this.premiumStatus,
      rewardStates: rewardStates ?? this.rewardStates,
    );
  }
}
