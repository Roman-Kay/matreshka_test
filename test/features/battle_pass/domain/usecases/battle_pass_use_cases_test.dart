import 'package:flutter_test/flutter_test.dart';
import 'package:romankaygo_test_rp/features/battle_pass/domain/models/battle_pass_models.dart';
import 'package:romankaygo_test_rp/features/battle_pass/domain/usecases/claim_all_rewards_use_case.dart';
import 'package:romankaygo_test_rp/features/battle_pass/domain/usecases/claim_battle_pass_task_use_case.dart';
import 'package:romankaygo_test_rp/features/battle_pass/domain/usecases/claim_reward_use_case.dart';
import 'package:romankaygo_test_rp/features/battle_pass/domain/usecases/compute_reward_statuses_use_case.dart';
import 'package:romankaygo_test_rp/features/battle_pass/domain/usecases/purchase_premium_use_case.dart';
import 'package:romankaygo_test_rp/features/tasks/domain/models/task.dart';

void main() {
  group(ComputeRewardStatusesUseCase, () {
    test('marks reached free rewards available and keeps premium locked', () {
      final result = const ComputeRewardStatusesUseCase()(_pass());

      final level = result.season.levels.first;
      expect(level.freeRewards.first.status, RewardStatus.available);
      expect(level.premiumRewards.first.status, RewardStatus.locked);
    });
  });

  group(PurchasePremiumUseCase, () {
    test('unlocks reached premium rewards', () {
      final result = PurchasePremiumUseCase(
        const ComputeRewardStatusesUseCase(),
      )(_pass());

      expect(result.premiumStatus, PremiumStatus.purchased);
      expect(
        result.season.levels.first.premiumRewards.first.status,
        RewardStatus.available,
      );
    });
  });

  group(ClaimRewardUseCase, () {
    test('claims available reward', () {
      final pass = const ComputeRewardStatusesUseCase()(_pass());

      final result = const ClaimRewardUseCase()(pass, 10);

      expect(result.message, 'Награда получена');
      expect(
        result.pass.season.levels.first.freeRewards.first.status,
        RewardStatus.received,
      );
    });

    test('does not claim locked premium reward', () {
      final pass = const ComputeRewardStatusesUseCase()(_pass());

      final result = const ClaimRewardUseCase()(pass, 11);

      expect(result.message, 'Нужна прокачка');
      expect(
        result.pass.season.levels.first.premiumRewards.first.status,
        RewardStatus.locked,
      );
    });
  });

  group(ClaimAllRewardsUseCase, () {
    test('claims only available rewards', () {
      final pass = const ComputeRewardStatusesUseCase()(_pass());

      final result = const ClaimAllRewardsUseCase()(pass);

      expect(result.message, 'Получено наград: 1');
      expect(
        result.pass.season.levels.first.freeRewards.first.status,
        RewardStatus.received,
      );
      expect(
        result.pass.season.levels.first.premiumRewards.first.status,
        RewardStatus.locked,
      );
    });
  });

  group(ClaimBattlePassTaskUseCase, () {
    test('claims task and adds battle pass xp', () {
      final pass = _pass(
        tasks: const [
          Task(
            id: 1,
            title: 'Task',
            rewardTitle: 'XP',
            rewardAmount: 25,
            currentProgress: 1,
            requiredProgress: 1,
            rewardAssetPath: 'xp.png',
            status: TaskStatus.readyToClaim,
          ),
        ],
      );

      final result = const ClaimBattlePassTaskUseCase()(pass, 1);

      expect(result, isNotNull);
      expect(result!.pass.tasks.first.status, TaskStatus.claimed);
      expect(result.pass.progress.currentXp, 45);
      expect(result.message, '+25 опыта Battle Pass');
    });

    test('levels up when task xp reaches threshold', () {
      final pass = _pass(
        tasks: const [
          Task(
            id: 1,
            title: 'Task',
            rewardTitle: 'XP',
            rewardAmount: 90,
            currentProgress: 1,
            requiredProgress: 1,
            rewardAssetPath: 'xp.png',
            status: TaskStatus.readyToClaim,
          ),
        ],
      );

      final result = const ClaimBattlePassTaskUseCase()(pass, 1);

      expect(result, isNotNull);
      expect(result!.pass.progress.currentLevel, 2);
      expect(result.pass.progress.currentXp, 10);
    });

    test('ignores unavailable task', () {
      final pass = _pass(
        tasks: const [
          Task(
            id: 1,
            title: 'Task',
            rewardTitle: 'XP',
            rewardAmount: 25,
            currentProgress: 0,
            requiredProgress: 1,
            rewardAssetPath: 'xp.png',
          ),
        ],
      );

      final result = const ClaimBattlePassTaskUseCase()(pass, 1);

      expect(result, isNull);
    });
  });
}

BattlePass _pass({List<Task> tasks = const []}) {
  return BattlePass(
    season: BattlePassSeason(
      id: 'season',
      title: 'Season',
      startsAt: DateTime.utc(2026),
      endsAt: DateTime.utc(2026, 2),
      maxLevel: 2,
      levels: const [
        BattlePassLevel(
          number: 1,
          requiredXp: 100,
          freeRewards: [
            BattlePassReward(
              id: 10,
              type: RewardType.xp,
              title: 'XP',
              amount: 100,
              track: BattlePassTrack.free,
              assetPath: null,
            ),
          ],
          premiumRewards: [
            BattlePassReward(
              id: 11,
              type: RewardType.outfit,
              title: 'Skin',
              amount: 1,
              track: BattlePassTrack.premium,
              assetPath: null,
            ),
          ],
        ),
        BattlePassLevel(
          number: 2,
          requiredXp: 200,
          freeRewards: [
            BattlePassReward(
              id: 20,
              type: RewardType.xp,
              title: 'XP',
              amount: 100,
              track: BattlePassTrack.free,
              assetPath: null,
            ),
          ],
          premiumRewards: [],
        ),
      ],
    ),
    progress: const BattlePassProgress(
      currentLevel: 1,
      currentXp: 20,
      nextLevelXp: 100,
    ),
    premiumStatus: PremiumStatus.locked,
    tasks: tasks,
  );
}
