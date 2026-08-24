enum TaskStatus { inProgress, readyToClaim, claimed }

final class Task {
  const Task({
    required this.id,
    required this.title,
    required this.rewardTitle,
    required this.rewardAmount,
    required this.currentProgress,
    required this.requiredProgress,
    required this.rewardAssetPath,
    this.xpBonusPercent = 0,
    this.status = TaskStatus.inProgress,
  });

  final int id;
  final String title;
  final String rewardTitle;
  final int rewardAmount;
  final int currentProgress;
  final int requiredProgress;
  final String rewardAssetPath;
  final int xpBonusPercent;
  final TaskStatus status;

  bool get completed => currentProgress >= requiredProgress;
  bool get canClaim => status == TaskStatus.readyToClaim;
  bool get claimed => status == TaskStatus.claimed;
  bool get hasXpBonus => xpBonusPercent > 0;
  int get totalRewardAmount =>
      rewardAmount + (rewardAmount * xpBonusPercent / 100).round();

  Task copyWith({
    int? id,
    String? title,
    String? rewardTitle,
    int? rewardAmount,
    int? currentProgress,
    int? requiredProgress,
    String? rewardAssetPath,
    int? xpBonusPercent,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      rewardTitle: rewardTitle ?? this.rewardTitle,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      currentProgress: currentProgress ?? this.currentProgress,
      requiredProgress: requiredProgress ?? this.requiredProgress,
      rewardAssetPath: rewardAssetPath ?? this.rewardAssetPath,
      xpBonusPercent: xpBonusPercent ?? this.xpBonusPercent,
      status: status ?? this.status,
    );
  }
}
