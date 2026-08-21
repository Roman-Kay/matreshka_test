import '../../../battle_pass/domain/models/battle_pass_models.dart';
import '../../../battle_pass/domain/repositories/battle_pass_repository.dart';
import '../../../../core/constants/app_assets.dart';

final class MockBattlePassRepository implements BattlePassRepository {
  const MockBattlePassRepository({
    this.delay = const Duration(milliseconds: 350),
  });

  final Duration delay;

  @override
  Future<BattlePass> load(BattlePassDemoMode mode) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final premium = mode == BattlePassDemoMode.premiumLocked
        ? PremiumStatus.locked
        : PremiumStatus.purchased;
    final progress = switch (mode) {
      BattlePassDemoMode.premiumLocked => const BattlePassProgress(
        currentLevel: 2,
        currentXp: 500,
        nextLevelXp: 1600,
      ),
      BattlePassDemoMode.premiumUnlocked => const BattlePassProgress(
        currentLevel: 5,
        currentXp: 760,
        nextLevelXp: 1600,
      ),
      BattlePassDemoMode.maxLevel => const BattlePassProgress(
        currentLevel: 10,
        currentXp: 1600,
        nextLevelXp: 1600,
      ),
    };
    return BattlePass(
      season: BattlePassSeason(
        id: 'birthday-2025',
        title: 'Дай пять!',
        startsAt: DateTime.utc(2025, 7, 1),
        endsAt: DateTime.utc(2025, 7, 17, 12, 42),
        maxLevel: 10,
        levels: List<BattlePassLevel>.generate(10, (index) {
          final level = index + 1;
          return BattlePassLevel(
            number: level,
            requiredXp: 1600 * level,
            freeRewards: [
              BattlePassReward(
                id: level * 10,
                type: level.isEven ? RewardType.currency : RewardType.xp,
                title: level.isEven ? 'Опыт БП' : 'Набор XP',
                amount: level.isEven ? 250 : 100,
                track: BattlePassTrack.free,
                assetPath: level.isEven
                    ? AppAssets.rewardOne
                    : AppAssets.rewardTwo,
              ),
            ],
            premiumRewards: [
              BattlePassReward(
                id: level * 10 + 1,
                type: level == 10 ? RewardType.vehicle : RewardType.outfit,
                title: level == 4
                    ? '«Роковая женщина» или «Босс мафии»'
                    : level == 10
                    ? 'Мега пак'
                    : 'Премиум награда $level',
                amount: level == 10 ? 1 : 16,
                track: BattlePassTrack.premium,
                assetPath: level == 10 ? AppAssets.hero : AppAssets.rewardOne,
              ),
            ],
          );
        }),
      ),
      progress: progress,
      premiumStatus: premium,
    );
  }
}
