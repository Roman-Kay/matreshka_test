import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/battle_pass_models.dart';
import '../../domain/repositories/battle_pass_repository.dart';
import '../../domain/usecases/claim_all_rewards_use_case.dart';
import '../../domain/usecases/claim_reward_use_case.dart';
import '../../domain/usecases/compute_reward_statuses_use_case.dart';
import '../../domain/usecases/load_battle_pass_use_case.dart';
import '../../domain/usecases/purchase_premium_use_case.dart';
import 'battle_pass_state.dart';

final class BattlePassCubit extends Cubit<BattlePassState> {
  BattlePassCubit(
    BattlePassRepository repository, {
    ComputeRewardStatusesUseCase computeRewardStatuses =
        const ComputeRewardStatusesUseCase(),
    ClaimRewardUseCase claimReward = const ClaimRewardUseCase(),
    ClaimAllRewardsUseCase claimAllRewards = const ClaimAllRewardsUseCase(),
  }) : _loadBattlePass = LoadBattlePassUseCase(
         repository,
         computeRewardStatuses,
       ),
       _purchasePremium = PurchasePremiumUseCase(computeRewardStatuses),
       _claimReward = claimReward,
       _claimAllRewards = claimAllRewards,
       super(const BattlePassState.initial());

  final LoadBattlePassUseCase _loadBattlePass;
  final PurchasePremiumUseCase _purchasePremium;
  final ClaimRewardUseCase _claimReward;
  final ClaimAllRewardsUseCase _claimAllRewards;

  Future<void> load({BattlePassDemoMode? mode}) async {
    final nextMode = mode ?? state.demoMode;
    emit(
      state.copyWith(status: BattlePassViewStatus.loading, demoMode: nextMode),
    );
    try {
      final battlePass = await _loadBattlePass(nextMode);
      emit(
        BattlePassState(
          status: BattlePassViewStatus.loaded,
          demoMode: nextMode,
          battlePass: battlePass,
          selectedRewardId: _firstRewardId(battlePass),
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: BattlePassViewStatus.failure,
          message: 'Не удалось загрузить Battle Pass',
        ),
      );
    }
  }

  Future<void> switchDemoMode(BattlePassDemoMode mode) => load(mode: mode);

  void purchasePremium() {
    final pass = state.battlePass;
    if (pass == null || pass.premiumStatus == PremiumStatus.purchased) return;
    emit(
      state.copyWith(
        battlePass: _purchasePremium(pass),
        message: 'Прокачка активирована',
      ),
    );
  }

  void selectReward(int rewardId) {
    emit(state.copyWith(selectedRewardId: rewardId, clearMessage: true));
  }

  void claimReward(int rewardId) {
    final pass = state.battlePass;
    if (pass == null) return;
    final result = _claimReward(pass, rewardId);
    emit(state.copyWith(battlePass: result.pass, message: result.message));
  }

  void claimAllAvailableRewards() {
    final pass = state.battlePass;
    if (pass == null) return;
    final result = _claimAllRewards(pass);
    emit(state.copyWith(battlePass: result.pass, message: result.message));
  }

  int? _firstRewardId(BattlePass pass) {
    if (pass.season.levels.isEmpty) return null;
    final level =
        pass.season.levels[(pass.progress.currentLevel - 1).clamp(
          0,
          pass.season.levels.length - 1,
        )];
    return level.premiumRewards.isNotEmpty
        ? level.premiumRewards.first.id
        : level.freeRewards.firstOrNull?.id;
  }
}
