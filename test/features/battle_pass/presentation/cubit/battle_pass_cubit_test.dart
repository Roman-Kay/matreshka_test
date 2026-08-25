import 'package:flutter_test/flutter_test.dart';
import 'package:romankaygo_test_rp/features/battle_pass/domain/models/battle_pass_models.dart';
import 'package:romankaygo_test_rp/features/battle_pass/domain/repositories/battle_pass_repository.dart';
import 'package:romankaygo_test_rp/features/battle_pass/presentation/cubit/battle_pass_cubit.dart';
import 'package:romankaygo_test_rp/features/battle_pass/presentation/cubit/battle_pass_state.dart';
import 'package:romankaygo_test_rp/features/pause/domain/models/player_battle_pass_state.dart';
import 'package:romankaygo_test_rp/features/pause/domain/models/player_battle_pass_progress.dart';

void main() {
  test('load emits loaded state with computed reward statuses', () async {
    final cubit = BattlePassCubit(_FakeBattlePassRepository(_pass()));
    final states = <BattlePassState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.load();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    await cubit.close();

    expect(states.first.status, BattlePassViewStatus.loading);
    expect(states.last.status, BattlePassViewStatus.loaded);
    expect(states.last.battlePass, isNotNull);
    expect(
      states.last.battlePass!.rewardStatus(
        states.last.battlePass!.season.levels.first.freeRewards.first.id,
      ),
      RewardStatus.available,
    );
  });

  test('purchasePremium updates current battle pass', () async {
    final cubit = BattlePassCubit(_FakeBattlePassRepository(_pass()));

    await cubit.load();
    cubit.purchasePremium();

    expect(cubit.state.battlePass!.premiumStatus, PremiumStatus.purchased);
    expect(cubit.state.message, 'Прокачка активирована');

    await cubit.close();
  });

  test('load failure emits failure state', () async {
    final cubit = BattlePassCubit(_FailingBattlePassRepository());
    final states = <BattlePassState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.load();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    await cubit.close();

    expect(states.last.status, BattlePassViewStatus.failure);
    expect(states.last.message, 'Не удалось загрузить Battle Pass');
  });
}

final class _FakeBattlePassRepository implements BattlePassRepository {
  const _FakeBattlePassRepository(this.pass);

  final BattlePass pass;

  @override
  Future<BattlePass> load(BattlePassDemoMode mode) async => pass;
}

final class _FailingBattlePassRepository implements BattlePassRepository {
  @override
  Future<BattlePass> load(BattlePassDemoMode mode) {
    throw StateError('network');
  }
}

BattlePass _pass() {
  return BattlePass(
    season: BattlePassSeason(
      id: 'season',
      title: 'Season',
      startsAt: DateTime.utc(2026),
      endsAt: DateTime.utc(2026, 2),
      maxLevel: 1,
      instantPremiumRewards: const [],
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
      ],
    ),
    playerState: const PlayerBattlePassState(
      userId: 'test-player',
      progress: PlayerBattlePassProgress(
        currentLevel: 1,
        currentXp: 20,
        nextLevelXp: 100,
      ),
      premiumStatus: PremiumStatus.locked,
      rewardStates: [],
    ),
    tasks: const [],
  );
}
