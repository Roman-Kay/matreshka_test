import '../../../../core/constants/app_assets.dart';
import '../../../battle_pass/domain/models/battle_pass_models.dart';
import '../../../battle_pass/domain/repositories/battle_pass_repository.dart';
import '../../../pause/data/repositories/mock_pause_profile_repository.dart';
import '../../../pause/domain/repositories/pause_profile_repository.dart';
import '../../../tasks/data/repositories/mock_tasks_repository.dart';
import '../../../tasks/domain/models/task.dart';
import '../../../tasks/domain/repositories/tasks_repository.dart';

final class MockBattlePassRepository implements BattlePassRepository {
  MockBattlePassRepository({
    this.delay = const Duration(milliseconds: 350),
    TasksRepository? tasksRepository,
    PauseProfileRepository? pauseProfileRepository,
    DateTime Function()? now,
  }) : _tasksRepository = tasksRepository ?? const MockTasksRepository(),
       _pauseProfileRepository =
           pauseProfileRepository ?? const MockPauseProfileRepository(),
       _now = now ?? DateTime.now;

  final Duration delay;
  final TasksRepository _tasksRepository;
  final PauseProfileRepository _pauseProfileRepository;
  final DateTime Function() _now;

  @override
  Future<BattlePass> load(BattlePassDemoMode mode) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final playerState = await _pauseProfileRepository.loadBattlePassState(
      mode: mode,
    );
    final now = _now();
    final startedAt = DateTime.utc(now.year, now.month, now.day);

    return BattlePass(
      season: BattlePassSeason(
        id: 'birthday-${startedAt.year}',
        title: 'Дай пять!',
        startsAt: startedAt,
        endsAt: startedAt.add(const Duration(days: 16, hours: 12, minutes: 42)),
        maxLevel: 200,
        backgroundAssetPath: AppAssets.bg,
        instantPremiumRewards: _instantPremiumRewards(),
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
                assetPath: _freeRewardAssetForLevel(level),
                rarity: _rarityForLevel(level),
              ),
            ],
            premiumRewards: _premiumRewardsForLevel(level),
          );
        }),
      ),
      playerState: playerState,
      tasks: _tasksWithPremiumBonus(
        await _tasksRepository.loadBattlePassTasks(),
        mode,
      ),
    );
  }

  List<Task> _tasksWithPremiumBonus(List<Task> tasks, BattlePassDemoMode mode) {
    if (mode != BattlePassDemoMode.premiumWithXpBonus) return tasks;
    return tasks
        .map((task) => task.copyWith(xpBonusPercent: 100))
        .toList(growable: false);
  }

  List<BattlePassReward> _instantPremiumRewards() {
    return [
      BattlePassReward(
        id: 9001,
        type: RewardType.outfit,
        title: 'Маска именинника',
        amount: 16,
        track: BattlePassTrack.premium,
        assetPath: AppAssets.railBirthdayMask,
        rarity: RewardRarity.rare,
      ),
      BattlePassReward(
        id: 9002,
        type: RewardType.currency,
        title: 'Премиум XP-буст',
        amount: 16,
        track: BattlePassTrack.premium,
        assetPath: AppAssets.railCanister,
        rarity: RewardRarity.epic,
      ),
      BattlePassReward(
        id: 9003,
        type: RewardType.outfit,
        title: 'Праздничный сет',
        amount: 16,
        track: BattlePassTrack.premium,
        assetPath: AppAssets.railOutfit,
        rarity: RewardRarity.rare,
      ),
    ];
  }

  RewardRarity _rarityForLevel(int level) {
    if (level % 10 == 0) return RewardRarity.legendary;
    if (level % 5 == 0) return RewardRarity.epic;
    if (level % 3 == 0) return RewardRarity.rare;
    return RewardRarity.common;
  }

  List<BattlePassReward> _premiumRewardsForLevel(int level) {
    if (level == 4) {
      return [
        BattlePassReward(
          id: level * 10 + 1,
          type: RewardType.outfit,
          title: '«Роковая женщина»',
          amount: 1,
          track: BattlePassTrack.premium,
          assetPath: AppAssets.railWhiteMask,
          rarity: RewardRarity.rare,
        ),
        BattlePassReward(
          id: level * 10 + 2,
          type: RewardType.outfit,
          title: '«Босс мафии»',
          amount: 1,
          track: BattlePassTrack.premium,
          assetPath: AppAssets.railOutfit,
          rarity: RewardRarity.rare,
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
        assetPath: _premiumRewardAssetForLevel(level),
        rarity: level % 10 == 0
            ? RewardRarity.legendary
            : _rarityForLevel(level + 1),
      ),
    ];
  }

  String _freeRewardAssetForLevel(int level) {
    const assets = [
      AppAssets.railBag,
      AppAssets.railCandy,
      AppAssets.railPassport,
      AppAssets.railWristband,
      AppAssets.railGreenMask,
    ];
    return assets[(level - 1) % assets.length];
  }

  String _premiumRewardAssetForLevel(int level) {
    if (level % 10 == 0) return AppAssets.railVehicle;
    const assets = [
      AppAssets.railBirthdayMask,
      AppAssets.railCanister,
      AppAssets.railWhiteMask,
      AppAssets.railOutfit,
    ];
    return assets[(level - 1) % assets.length];
  }
}
