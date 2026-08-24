enum PremiumStatus { locked, purchased }

enum RewardStatus { locked, available, received }

enum RewardType { xp, outfit, currency, consumable, vehicle, unknown }

enum BattlePassTrack { free, premium }

enum BattlePassDemoMode { premiumLocked, premiumUnlocked, maxLevel, completed }

enum BattlePassTaskStatus { inProgress, readyToClaim, claimed }

enum RewardRarity { common, rare, epic, legendary }

final class BattlePassReward {
  const BattlePassReward({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.track,
    required this.assetPath,
    this.rarity = RewardRarity.common,
    this.status = RewardStatus.locked,
  });

  final int id;
  final RewardType type;
  final String title;
  final int amount;
  final BattlePassTrack track;
  final String? assetPath;
  final RewardRarity rarity;
  final RewardStatus status;

  BattlePassReward copyWith({RewardStatus? status}) {
    return BattlePassReward(
      id: id,
      type: type,
      title: title,
      amount: amount,
      track: track,
      assetPath: assetPath,
      rarity: rarity,
      status: status ?? this.status,
    );
  }
}

final class BattlePassLevel {
  const BattlePassLevel({
    required this.number,
    required this.requiredXp,
    required this.freeRewards,
    required this.premiumRewards,
  });

  final int number;
  final int requiredXp;
  final List<BattlePassReward> freeRewards;
  final List<BattlePassReward> premiumRewards;
}

final class BattlePassSeason {
  const BattlePassSeason({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.maxLevel,
    required this.levels,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;
  final int maxLevel;
  final List<BattlePassLevel> levels;
}

final class BattlePassProgress {
  const BattlePassProgress({
    required this.currentLevel,
    required this.currentXp,
    required this.nextLevelXp,
  });

  final int currentLevel;
  final int currentXp;
  final int nextLevelXp;

  double get ratio {
    if (nextLevelXp <= 0) return 1;
    return (currentXp / nextLevelXp).clamp(0, 1);
  }
}

final class BattlePassTask {
  const BattlePassTask({
    required this.id,
    required this.title,
    required this.rewardTitle,
    required this.rewardAmount,
    required this.currentProgress,
    required this.requiredProgress,
    required this.rewardAssetPath,
    this.status = BattlePassTaskStatus.inProgress,
  });

  final int id;
  final String title;
  final String rewardTitle;
  final int rewardAmount;
  final int currentProgress;
  final int requiredProgress;
  final String rewardAssetPath;
  final BattlePassTaskStatus status;

  bool get completed => currentProgress >= requiredProgress;
  bool get canClaim => status == BattlePassTaskStatus.readyToClaim;
  bool get claimed => status == BattlePassTaskStatus.claimed;
}

final class BattlePass {
  const BattlePass({
    required this.season,
    required this.progress,
    required this.premiumStatus,
    required this.tasks,
  });

  final BattlePassSeason season;
  final BattlePassProgress progress;
  final PremiumStatus premiumStatus;
  final List<BattlePassTask> tasks;
}
