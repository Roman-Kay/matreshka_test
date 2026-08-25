import '../models/battle_pass_models.dart';
import 'compute_reward_statuses_use_case.dart';

final class PurchasePremiumUseCase {
  const PurchasePremiumUseCase(this._computeRewardStatuses);

  final ComputeRewardStatusesUseCase _computeRewardStatuses;

  BattlePass call(BattlePass pass) {
    if (pass.premiumStatus == PremiumStatus.purchased) return pass;
    return _computeRewardStatuses(
      pass.copyWith(
        playerState: pass.playerState.copyWith(
          premiumStatus: PremiumStatus.purchased,
        ),
      ),
    );
  }
}
