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
        currentLevel: 10,
        currentXp: 900,
        nextLevelXp: 1600,
      ),
      BattlePassDemoMode.premiumUnlocked => const BattlePassProgress(
        currentLevel: 108,
        currentXp: 900,
        nextLevelXp: 1600,
      ),
      BattlePassDemoMode.maxLevel => const BattlePassProgress(
        currentLevel: 200,
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
        maxLevel: 200,
        levels: List<BattlePassLevel>.generate(200, (index) {
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
                rarity: _rarityForLevel(level),
                status: _initialRewardStatus(
                  level: level,
                  track: BattlePassTrack.free,
                  premium: premium,
                ),
              ),
            ],
            premiumRewards: _premiumRewardsForLevel(level, premium),
          );
        }),
      ),
      progress: progress,
      premiumStatus: premium,
    );
  }

  RewardRarity _rarityForLevel(int level) {
    if (level % 10 == 0) return RewardRarity.legendary;
    if (level % 5 == 0) return RewardRarity.epic;
    if (level % 3 == 0) return RewardRarity.rare;
    return RewardRarity.common;
  }

  List<BattlePassReward> _premiumRewardsForLevel(
    int level,
    PremiumStatus premium,
  ) {
    final status = _initialRewardStatus(
      level: level,
      track: BattlePassTrack.premium,
      premium: premium,
    );

    if (level == 4) {
      return [
        BattlePassReward(
          id: level * 10 + 1,
          type: RewardType.outfit,
          title: '«Роковая женщина»',
          amount: 1,
          track: BattlePassTrack.premium,
          assetPath: AppAssets.rewardOne,
          rarity: RewardRarity.rare,
          status: status,
        ),
        BattlePassReward(
          id: level * 10 + 2,
          type: RewardType.outfit,
          title: '«Босс мафии»',
          amount: 1,
          track: BattlePassTrack.premium,
          assetPath: AppAssets.rewardTwo,
          rarity: RewardRarity.rare,
          status: status,
        ),
      ];
    }

    return [
      BattlePassReward(
        id: level * 10 + 1,
        type: level == 10 ? RewardType.vehicle : RewardType.outfit,
        title: level == 10 ? 'Мега пак' : 'Премиум награда $level',
        amount: level == 10 ? 1 : 16,
        track: BattlePassTrack.premium,
        assetPath: level == 10 ? AppAssets.hero : AppAssets.rewardOne,
        rarity: _rarityForLevel(level + 1),
        status: status,
      ),
    ];
  }

  RewardStatus _initialRewardStatus({
    required int level,
    required BattlePassTrack track,
    required PremiumStatus premium,
  }) {
    if (level > 5) return RewardStatus.locked;
    if (track == BattlePassTrack.free) return RewardStatus.received;
    return premium == PremiumStatus.purchased
        ? RewardStatus.received
        : RewardStatus.locked;
  }
}
