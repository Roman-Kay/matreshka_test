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

  BattlePassLevel copyWith({
    int? number,
    int? requiredXp,
    List<BattlePassReward>? freeRewards,
    List<BattlePassReward>? premiumRewards,
  }) {
    return BattlePassLevel(
      number: number ?? this.number,
      requiredXp: requiredXp ?? this.requiredXp,
      freeRewards: freeRewards ?? this.freeRewards,
      premiumRewards: premiumRewards ?? this.premiumRewards,
    );
  }
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

  BattlePassSeason copyWith({
    String? id,
    String? title,
    DateTime? startsAt,
    DateTime? endsAt,
    int? maxLevel,
    List<BattlePassLevel>? levels,
  }) {
    return BattlePassSeason(
      id: id ?? this.id,
      title: title ?? this.title,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      maxLevel: maxLevel ?? this.maxLevel,
      levels: levels ?? this.levels,
    );
  }
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

  BattlePassProgress copyWith({
    int? currentLevel,
    int? currentXp,
    int? nextLevelXp,
  }) {
    return BattlePassProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      currentXp: currentXp ?? this.currentXp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
    );
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

  BattlePassTask copyWith({
    int? id,
    String? title,
    String? rewardTitle,
    int? rewardAmount,
    int? currentProgress,
    int? requiredProgress,
    String? rewardAssetPath,
    BattlePassTaskStatus? status,
  }) {
    return BattlePassTask(
      id: id ?? this.id,
      title: title ?? this.title,
      rewardTitle: rewardTitle ?? this.rewardTitle,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      currentProgress: currentProgress ?? this.currentProgress,
      requiredProgress: requiredProgress ?? this.requiredProgress,
      rewardAssetPath: rewardAssetPath ?? this.rewardAssetPath,
      status: status ?? this.status,
    );
  }
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

  BattlePass copyWith({
    BattlePassSeason? season,
    BattlePassProgress? progress,
    PremiumStatus? premiumStatus,
    List<BattlePassTask>? tasks,
  }) {
    return BattlePass(
      season: season ?? this.season,
      progress: progress ?? this.progress,
      premiumStatus: premiumStatus ?? this.premiumStatus,
      tasks: tasks ?? this.tasks,
    );
  }
}
