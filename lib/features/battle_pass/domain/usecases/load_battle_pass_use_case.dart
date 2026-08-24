import '../models/battle_pass_models.dart';
import '../repositories/battle_pass_repository.dart';
import 'compute_reward_statuses_use_case.dart';

final class LoadBattlePassUseCase {
  const LoadBattlePassUseCase(this._repository, this._computeRewardStatuses);

  final BattlePassRepository _repository;
  final ComputeRewardStatusesUseCase _computeRewardStatuses;

  Future<BattlePass> call(BattlePassDemoMode mode) async {
    final pass = await _repository.load(mode);
    return _computeRewardStatuses(pass);
  }
}
