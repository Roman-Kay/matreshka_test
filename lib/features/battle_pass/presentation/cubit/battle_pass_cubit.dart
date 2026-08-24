import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/battle_pass_models.dart';
import '../../domain/repositories/battle_pass_repository.dart';
import 'battle_pass_state.dart';

final class BattlePassCubit extends Cubit<BattlePassState> {
  BattlePassCubit(this._repository) : super(const BattlePassState.initial());

  final BattlePassRepository _repository;

  Future<void> load({BattlePassDemoMode? mode}) async {
    final nextMode = mode ?? state.demoMode;
    emit(
      state.copyWith(status: BattlePassViewStatus.loading, demoMode: nextMode),
    );
    try {
      final battlePass = await _repository.load(nextMode);
      emit(
        BattlePassState(
          status: BattlePassViewStatus.loaded,
          demoMode: nextMode,
          battlePass: _withComputedStatuses(battlePass),
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
        battlePass: _withComputedStatuses(
          BattlePass(
            season: pass.season,
            progress: pass.progress,
            premiumStatus: PremiumStatus.purchased,
          ),
        ),
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
    String? blockedReason;
    final levels = pass.season.levels
        .map((level) {
          List<BattlePassReward> update(List<BattlePassReward> rewards) {
            return rewards
                .map((reward) {
                  if (reward.id != rewardId) return reward;
                  if (reward.status == RewardStatus.received) {
                    blockedReason = 'Награда уже получена';
                    return reward;
                  }
                  if (reward.track == BattlePassTrack.premium &&
                      pass.premiumStatus == PremiumStatus.locked) {
                    blockedReason = 'Нужна прокачка';
                    return reward;
                  }
                  if (reward.status != RewardStatus.available) {
                    blockedReason = 'Награда пока заблокирована';
                    return reward;
                  }
                  return reward.copyWith(status: RewardStatus.received);
                })
                .toList(growable: false);
          }

          return BattlePassLevel(
            number: level.number,
            requiredXp: level.requiredXp,
            freeRewards: update(level.freeRewards),
            premiumRewards: update(level.premiumRewards),
          );
        })
        .toList(growable: false);
    emit(
      state.copyWith(
        battlePass: BattlePass(
          season: BattlePassSeason(
            id: pass.season.id,
            title: pass.season.title,
            startsAt: pass.season.startsAt,
            endsAt: pass.season.endsAt,
            maxLevel: pass.season.maxLevel,
            levels: levels,
          ),
          progress: pass.progress,
          premiumStatus: pass.premiumStatus,
        ),
        message: blockedReason ?? 'Награда получена',
      ),
    );
  }

  void claimAllAvailableRewards() {
    final pass = state.battlePass;
    if (pass == null) return;

    var claimedCount = 0;
    final levels = pass.season.levels
        .map((level) {
          List<BattlePassReward> update(List<BattlePassReward> rewards) {
            return rewards
                .map((reward) {
                  final premiumLocked =
                      reward.track == BattlePassTrack.premium &&
                      pass.premiumStatus == PremiumStatus.locked;
                  if (reward.status != RewardStatus.available ||
                      premiumLocked) {
                    return reward;
                  }
                  claimedCount += 1;
                  return reward.copyWith(status: RewardStatus.received);
                })
                .toList(growable: false);
          }

          return BattlePassLevel(
            number: level.number,
            requiredXp: level.requiredXp,
            freeRewards: update(level.freeRewards),
            premiumRewards: update(level.premiumRewards),
          );
        })
        .toList(growable: false);

    emit(
      state.copyWith(
        battlePass: BattlePass(
          season: BattlePassSeason(
            id: pass.season.id,
            title: pass.season.title,
            startsAt: pass.season.startsAt,
            endsAt: pass.season.endsAt,
            maxLevel: pass.season.maxLevel,
            levels: levels,
          ),
          progress: pass.progress,
          premiumStatus: pass.premiumStatus,
        ),
        message: claimedCount > 0
            ? 'Получено наград: $claimedCount'
            : 'Нет доступных наград',
      ),
    );
  }

  BattlePass _withComputedStatuses(BattlePass pass) {
    final levels = pass.season.levels
        .map((level) {
          List<BattlePassReward> compute(List<BattlePassReward> rewards) {
            return rewards
                .map((reward) {
                  if (reward.status == RewardStatus.received) return reward;
                  final levelReached =
                      level.number <= pass.progress.currentLevel;
                  final premiumAllowed =
                      reward.track == BattlePassTrack.free ||
                      pass.premiumStatus == PremiumStatus.purchased;
                  return reward.copyWith(
                    status: levelReached && premiumAllowed
                        ? RewardStatus.available
                        : RewardStatus.locked,
                  );
                })
                .toList(growable: false);
          }

          return BattlePassLevel(
            number: level.number,
            requiredXp: level.requiredXp,
            freeRewards: compute(level.freeRewards),
            premiumRewards: compute(level.premiumRewards),
          );
        })
        .toList(growable: false);
    return BattlePass(
      season: BattlePassSeason(
        id: pass.season.id,
        title: pass.season.title,
        startsAt: pass.season.startsAt,
        endsAt: pass.season.endsAt,
        maxLevel: pass.season.maxLevel,
        levels: levels,
      ),
      progress: pass.progress,
      premiumStatus: pass.premiumStatus,
    );
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
